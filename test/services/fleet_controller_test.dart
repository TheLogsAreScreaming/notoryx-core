import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:meshcore_open/models/contact.dart';
import 'package:meshcore_open/models/fleet.dart';
import 'package:meshcore_open/services/fleet_controller.dart';
import 'package:meshcore_open/services/fleet_radio.dart';
import 'package:meshcore_open/services/fleet_station_client.dart';
import 'package:meshcore_open/services/fleet_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

String keyOf(int n) => n.toRadixString(16).padLeft(2, '0') * 32;

Contact contactFor(String key) => Contact(
  publicKey: Uint8List.fromList([
    for (var i = 0; i < 64; i += 2)
      int.parse(key.substring(i, i + 2), radix: 16),
  ]),
  name: 'R',
  type: 2,
  pathLength: -1,
  path: Uint8List(0),
  lastSeen: DateTime(2026),
);

/// Records every over-the-air request.
class FakeRadio implements FleetRadio {
  final calls = <String>[];
  final Map<String, String> settings = {};
  bool loginAnswer = true;

  @override
  Future<bool?> login(Contact repeater, String password) async {
    calls.add('login ${repeater.publicKeyHex.substring(0, 2)} $password');
    return loginAnswer;
  }

  @override
  Future<FleetStatusReply?> status(Contact repeater) async {
    calls.add('status ${repeater.publicKeyHex.substring(0, 2)}');
    return (
      batteryMv: 3950,
      noiseFloor: -111,
      lastRssi: -90,
      lastSnr: 8.0,
      uptimeSecs: 7200,
      errors: 0,
    );
  }

  @override
  Future<int?> neighbourCount(Contact repeater) async {
    calls.add('neighbours ${repeater.publicKeyHex.substring(0, 2)}');
    return 5;
  }

  @override
  Future<String?> command(Contact repeater, String command) async {
    final id = repeater.publicKeyHex.substring(0, 2);
    calls.add('cmd $id $command');
    if (command == 'ver') return 'v1.18.0 (Build: 1-Nov-2026)';
    final parts = command.split(' ');
    if (parts.first == 'get') return '> ${settings['$id ${parts[1]}'] ?? '0'}';
    if (parts.first == 'set') {
      settings['$id ${parts[1]}'] = parts[2];
      return 'OK';
    }
    return null;
  }
}

void main() {
  late FleetStore store;
  late FakeRadio radio;
  late MemoryFleetPasswordStore passwords;
  late List<Duration> waits;
  late DateTime now;
  late Set<String> inRadio;

  FleetController controller() => FleetController(
    store: store,
    passwords: passwords,
    radio: radio,
    contactFor: (k) => inRadio.contains(k) ? contactFor(k) : null,
    wait: (d) async => waits.add(d),
    clock: () => now,
  );

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    now = DateTime(2026, 11, 23, 12);
    store = FleetStore(await SharedPreferences.getInstance(), clock: () => now);
    radio = FakeRadio();
    passwords = MemoryFleetPasswordStore();
    waits = [];
    inRadio = {keyOf(1), keyOf(2), keyOf(3)};
    for (final n in [1, 2, 3]) {
      store.add(keyOf(n), 'R$n');
    }
    await passwords.write(keyOf(1), 'secret1');
  });

  test('polls one at a time, at least 20 s apart', () async {
    final fleet = FleetController(
      store: store,
      passwords: passwords,
      radio: radio,
      contactFor: contactFor,
      stagger: const Duration(seconds: 5),
      wait: (d) async => waits.add(d),
      clock: () => now,
    );
    await fleet.pollAll();
    expect(waits, [const Duration(seconds: 20), const Duration(seconds: 20)]);
    expect(radio.calls.where((c) => c.startsWith('status')), hasLength(3));
    expect(radio.calls.first, 'login 01 secret1');
    expect(radio.calls, contains('login 02 '));
    final h = store.healthFor(keyOf(1));
    expect(h.batteryMv, 3950);
    expect(h.firmware, startsWith('v1.18.0'));
    expect(h.neighbours, 5);
    expect(fleet.busy, isFalse);
  });

  test('firmware and neighbours are asked only when due', () async {
    final fleet = controller();
    await fleet.pollOne(keyOf(1));
    radio.calls.clear();
    now = now.add(const Duration(hours: 1));
    await fleet.pollOne(keyOf(1));
    expect(radio.calls, ['login 01 secret1', 'status 01']);
    now = now.add(const Duration(hours: 6));
    radio.calls.clear();
    await fleet.pollOne(keyOf(1));
    expect(radio.calls, contains('neighbours 01'));
    expect(radio.calls.where((c) => c.contains('ver')), isEmpty);
  });

  test(
    'a repeater the radio does not hold is skipped without airtime',
    () async {
      inRadio.remove(keyOf(2));
      final s = await controller().pollOne(keyOf(2));
      expect(s.ok, isFalse);
      expect(s.error, 'no_contact');
      expect(radio.calls, isEmpty);
    },
  );

  test('a refused login records an error and asks nothing else', () async {
    radio.loginAnswer = false;
    final s = await controller().pollOne(keyOf(1));
    expect(s.error, 'login');
    expect(radio.calls, ['login 01 secret1']);
  });

  test('stop ends a poll round after the current repeater', () async {
    late FleetController fleet;
    fleet = FleetController(
      store: store,
      passwords: passwords,
      radio: radio,
      contactFor: contactFor,
      wait: (d) async => fleet.stop(),
      clock: () => now,
    );
    await fleet.pollAll();
    expect(radio.calls.where((c) => c.startsWith('status')), hasLength(1));
  });

  group('bulk settings', () {
    test('preview only reads, apply only sets what changes', () async {
      radio.settings['01 flood.max'] = '6';
      radio.settings['02 flood.max'] = '3';
      final fleet = controller();
      final diff = await fleet.preview([keyOf(1), keyOf(2)], 'flood.max', '6');
      expect(radio.calls.where((c) => c.contains(' set ')), isEmpty);
      expect(diff.map((d) => d.changes), [false, true]);
      expect(diff[1].current, '3');

      radio.calls.clear();
      final results = await fleet.apply(diff, 'flood.max');
      expect(radio.calls.where((c) => c.contains(' set ')), [
        'cmd 02 set flood.max 6',
      ]);
      expect(results, {keyOf(2): 'OK'});
      expect(radio.settings['02 flood.max'], '6');
    });

    test('settings off the allow-list are never sent', () async {
      final fleet = controller();
      expect(await fleet.preview([keyOf(1)], 'name', 'x'), isEmpty);
      final forged = [
        FleetSettingDiff(
          repeater: store.byKey(keyOf(1))!,
          current: 'a',
          target: 'x',
        ),
      ];
      expect(await fleet.apply(forged, 'password'), isEmpty);
      expect(await fleet.apply(forged, 'flood.max'), isEmpty);
      expect(radio.calls, isEmpty);
    });
  });

  test('station sync only GETs and never sends passwords', () async {
    final requests = <http.Request>[];
    final client = MockClient((req) async {
      requests.add(req);
      if (req.url.path == '/api/fleet') {
        return http.Response(
          jsonEncode([
            {
              'id': 7,
              'public_key': keyOf(1),
              'name': 'R1',
              'has_password': true,
            },
            {'id': 9, 'public_key': keyOf(4), 'name': 'Hilltop'},
            {'id': 10, 'public_key': 'bad', 'name': 'Bad'},
          ]),
          200,
        );
      }
      return http.Response(
        jsonEncode([
          {'polled_at': 1700000000, 'ok': 1, 'battery_mv': 3900},
          {'polled_at': 1795348800, 'ok': 1, 'battery_mv': 4000},
          {'polled_at': 1795352400, 'ok': 0, 'error': 'timeout'},
        ]),
        200,
      );
    });
    final fleet = controller();
    final station = FleetStationClient(
      FleetStationClient.parseAddress('10.0.0.5')!,
      client: client,
    );
    // Two repeaters with two recent rows each; the 2023 row is too old.
    expect(await fleet.syncFromStation(station), 4);
    expect(await fleet.syncFromStation(station), 0, reason: 'no duplicates');
    expect(store.contains(keyOf(4)), isTrue);
    expect(store.byKey(keyOf(1))!.stationId, 7);
    for (final r in requests) {
      expect(r.method, 'GET');
      expect(r.body, isEmpty);
      expect(r.url.toString(), isNot(contains('secret')));
      expect(r.url.port, 8484);
    }
    expect(
      requests.map((r) => r.url.path),
      containsAll([
        '/api/fleet',
        '/api/fleet/7/history',
        '/api/fleet/9/history',
      ]),
    );
    expect(radio.calls, isEmpty);
  });

  test('the list and history survive a restart', () async {
    await controller().pollOne(keyOf(1));
    await store.flush();
    final again = FleetStore(
      await SharedPreferences.getInstance(),
      clock: () => now,
    );
    expect(again.repeaters.map((r) => r.name), ['R1', 'R2', 'R3']);
    expect(again.historyFor(keyOf(1)), hasLength(1));
    final prefs = await SharedPreferences.getInstance();
    for (final k in prefs.getKeys()) {
      expect('${prefs.get(k)}', isNot(contains('secret1')));
    }
  });
}
