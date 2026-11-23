import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:meshcore_open/models/firmware_release.dart';
import 'package:meshcore_open/models/fleet.dart';
import 'package:meshcore_open/services/fleet_station_client.dart';

void main() {
  final now = DateTime(2026, 11, 23, 12);

  FleetHealth health({
    Duration? heardAgo,
    int? mv,
    String? fw,
    bool polled = true,
  }) => FleetHealth(
    lastHeard: heardAgo == null ? null : now.subtract(heardAgo),
    batteryMv: mv,
    firmware: fw,
    lastPoll: polled ? FleetSample(at: now, ok: false) : null,
  );

  group('fleetStatusFor', () {
    test('healthy when heard recently with a good battery', () {
      expect(
        fleetStatusFor(
          health(heardAgo: const Duration(minutes: 5), mv: 4100),
          now: now,
        ),
        FleetStatus.healthy,
      );
    });

    test('quiet when not heard for more than 3 hours', () {
      expect(
        fleetStatusFor(
          health(heardAgo: const Duration(hours: 4), mv: 3300),
          now: now,
        ),
        FleetStatus.quiet,
      );
    });

    test('quiet when polled but never answered, unknown when never polled', () {
      expect(fleetStatusFor(health(), now: now), FleetStatus.quiet);
      expect(
        fleetStatusFor(health(polled: false), now: now),
        FleetStatus.unknown,
      );
    });

    test('low battery below 3.6 V', () {
      expect(
        fleetStatusFor(
          health(heardAgo: const Duration(minutes: 1), mv: 3550),
          now: now,
        ),
        FleetStatus.lowBattery,
      );
    });

    test('firmware behind the newest in the fleet', () {
      final newest = newestFirmwareOf([
        'v1.17.0 (Build: 1-Oct-2025)',
        'v1.18.0 (Build: 2-Nov-2026)',
        null,
      ]);
      expect(newest, const FirmwareVersion(1, 18, 0));
      expect(
        fleetStatusFor(
          health(heardAgo: Duration.zero, mv: 4000, fw: 'v1.17.0'),
          now: now,
          newestFirmware: newest,
        ),
        FleetStatus.firmwareBehind,
      );
      expect(
        fleetStatusFor(
          health(heardAgo: Duration.zero, mv: 4000, fw: 'v1.18.0'),
          now: now,
          newestFirmware: newest,
        ),
        FleetStatus.healthy,
      );
    });
  });

  test('FleetHealth keeps the newest value of each field', () {
    final h = FleetHealth.from([
      FleetSample(
        at: now.subtract(const Duration(days: 1)),
        ok: true,
        batteryMv: 3900,
        firmware: 'v1.18.0',
        neighbours: 4,
      ),
      FleetSample(
        at: now.subtract(const Duration(hours: 1)),
        ok: true,
        batteryMv: 3800,
        noiseFloor: -110,
      ),
      FleetSample(at: now, ok: false, error: 'timeout'),
    ]);
    expect(h.batteryMv, 3800);
    expect(h.noiseFloor, -110);
    expect(h.firmware, 'v1.18.0');
    expect(h.neighbours, 4);
    expect(h.lastHeard, now.subtract(const Duration(hours: 1)));
    expect(h.lastPoll!.ok, isFalse);
  });

  test('keys are normalised and checked', () {
    final key = 'AB' * 32;
    expect(FleetRepeater.normalizeKey(key), 'ab' * 32);
    expect(
      FleetRepeater.normalizeKey(List.generate(32, (_) => 'ab').join(':')),
      'ab' * 32,
    );
    expect(FleetRepeater.normalizeKey('abcd'), isNull);
    expect(FleetRepeater.normalizeKey('zz' * 32), isNull);
  });

  test('only allow-listed settings with valid values pass', () {
    expect(isAllowedBulkSetting('flood.max', '6'), isTrue);
    expect(isAllowedBulkSetting('repeat', 'off'), isTrue);
    expect(isAllowedBulkSetting('repeat', 'maybe'), isFalse);
    expect(isAllowedBulkSetting('txdelay', '0.5'), isTrue);
    expect(isAllowedBulkSetting('name', 'x'), isFalse);
    expect(isAllowedBulkSetting('password', 'x'), isFalse);
    expect(isAllowedBulkSetting('flood.max', '6; reboot'), isFalse);
  });

  test('get replies are unwrapped', () {
    expect(parseGetReply('> 300'), '300');
    expect(parseGetReply('-> on'), 'on');
    expect(parseGetReply('  12 '), '12');
  });

  test('a diff with the same value changes nothing', () {
    final rep = FleetRepeater(publicKeyHex: 'ab' * 32, name: 'R', addedAt: now);
    expect(
      FleetSettingDiff(repeater: rep, current: '6', target: '6').changes,
      isFalse,
    );
    expect(
      FleetSettingDiff(repeater: rep, current: '5', target: '6').changes,
      isTrue,
    );
    expect(
      FleetSettingDiff(repeater: rep, current: null, target: '6').changes,
      isTrue,
    );
  });

  test('binary status frames are read', () {
    final frame = Uint8List(60);
    final d = ByteData.sublistView(frame, 8);
    d.setUint16(0, 3987, Endian.little);
    d.setInt16(4, -112, Endian.little);
    d.setInt16(6, -95, Endian.little);
    d.setUint32(20, 90061, Endian.little);
    d.setUint16(40, 2, Endian.little);
    d.setInt16(42, 29, Endian.little);
    final st = parseRepeaterStatusFrame(frame)!;
    expect(st.batteryMv, 3987);
    expect(st.noiseFloor, -112);
    expect(st.lastRssi, -95);
    expect(st.uptimeSecs, 90061);
    expect(st.errors, 2);
    expect(st.lastSnr, 7.25);
    expect(parseRepeaterStatusFrame(Uint8List(40)), isNull);
  });

  test('samples survive JSON', () {
    final s = FleetSample(
      at: now,
      ok: true,
      source: FleetSource.station,
      batteryMv: 4000,
      lastSnr: 6.5,
      firmware: 'v1.18.0',
      neighbours: 3,
    );
    final back = FleetSample.fromJson(s.toJson())!;
    expect(back.source, FleetSource.station);
    expect(back.lastSnr, 6.5);
    expect(back.neighbours, 3);
  });

  group('station rows', () {
    test('map onto samples', () {
      final s = sampleFromStation({
        'polled_at': 1763899200.5,
        'ok': 1,
        'battery_mv': 4012,
        'noise_floor': -108,
        'last_snr': 9.25,
        'uptime_s': 3600,
        'firmware': 'v1.18.0',
        'neighbours': [
          {'key': 'aa'},
          {'key': 'bb'},
        ],
      })!;
      expect(s.ok, isTrue);
      expect(s.source, FleetSource.station);
      expect(s.batteryMv, 4012);
      expect(s.neighbours, 2);
      expect(s.at.millisecondsSinceEpoch, 1763899200500);
      expect(sampleFromStation({'ok': 1}), isNull);
    });

    test('addresses default to port 8484', () {
      expect(
        FleetStationClient.parseAddress('192.168.1.20').toString(),
        'http://192.168.1.20:8484',
      );
      expect(
        FleetStationClient.parseAddress('ops.local:9000').toString(),
        'http://ops.local:9000',
      );
      expect(FleetStationClient.parseAddress('ftp://x'), isNull);
      expect(FleetStationClient.parseAddress(' '), isNull);
    });
  });
}
