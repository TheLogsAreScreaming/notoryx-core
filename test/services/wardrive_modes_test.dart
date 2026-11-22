import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart' as crypto;
import 'package:flutter_test/flutter_test.dart';
import 'package:meshcore_open/connector/meshcore_connector.dart';
import 'package:meshcore_open/connector/meshcore_protocol.dart';
import 'package:meshcore_open/models/channel.dart';
import 'package:meshcore_open/models/companion_radio_stats.dart';
import 'package:meshcore_open/models/radio_rx_packet.dart';
import 'package:meshcore_open/models/wardrive.dart';
import 'package:meshcore_open/models/wardrive_grid.dart';
import 'package:meshcore_open/services/coverage_hex_service.dart';
import 'package:meshcore_open/services/trace_pinger.dart';
import 'package:meshcore_open/services/wardrive_service.dart';
import 'package:meshcore_open/storage/prefs_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A discover reply from the repeater with [prefix] to the request [tag].
Uint8List _reply(int tag, List<int> prefix, {int rssi = -92}) {
  final b = BytesBuilder()
    ..add([pushCodeControlData, 24, rssi & 0xFF, 0])
    ..addByte((controlSubtypeDiscoverResp << 4) | advTypeRepeater)
    ..addByte(12);
  final t = ByteData(4)..setUint32(0, tag, Endian.little);
  b
    ..add(t.buffer.asUint8List())
    ..add(prefix);
  return b.toBytes();
}

/// A flood packet of [payloadType] that came through [path] (1-byte hops).
Uint8List _flood(int payloadType, List<int> path, List<int> payload) =>
    Uint8List.fromList([
      (payloadType << 2) | 0x01,
      path.length,
      ...path,
      ...payload,
    ]);

final _wardrivePsk = Uint8List.fromList(List.generate(16, (i) => i + 1));
final _wardriveHash = crypto.sha256.convert(_wardrivePsk).bytes[0];

class _Radio extends MeshCoreConnector {
  final frames = StreamController<Uint8List>.broadcast();
  final rx = StreamController<RadioRxPacket>.broadcast();
  double? lat = 41.328, lon = -73.094;
  List<Channel> channelList = [];
  int discovers = 0;
  int channelSends = 0;
  List<List<int>> answering = [
    [0xFA, 0x01, 0x02, 0x03],
  ];

  /// Repeats of our channel message the radio "hears": (path, snr).
  List<(List<int>, double)> echoes = [];

  @override
  bool get isConnected => true;
  @override
  double? get selfLatitude => lat;
  @override
  double? get selfLongitude => lon;
  @override
  List<Channel> get channels => channelList;
  @override
  Stream<Uint8List> get receivedFrames => frames.stream;
  @override
  Stream<RadioRxPacket> get rxPackets => rx.stream;
  @override
  Future<void> requestRadioStats() async {}
  @override
  Future<void> sendFrame(
    Uint8List data, {
    String? channelSendQueueId,
    bool expectsGenericAck = false,
    bool waitForGenericAck = false,
  }) async {
    discovers++;
    final tag = ByteData.sublistView(data).getUint32(3, Endian.little);
    for (final p in answering) {
      scheduleMicrotask(() => frames.add(_reply(tag, p)));
    }
  }

  @override
  Future<void> sendChannelMessage(
    Channel channel,
    String text, {
    String? originalText,
    String? translatedLanguageCode,
    String? translationModelId,
    bool sign = false,
  }) async {
    channelSends++;
    for (final (path, snr) in echoes) {
      scheduleMicrotask(
        () => rx.add(
          RadioRxPacket(
            raw: _flood(0x05, path, [_wardriveHash, 1, 2, 3]),
            snr: snr,
            rssi: -90,
            receivedAt: DateTime.now(),
            fromSelf: true,
          ),
        ),
      );
    }
  }
}

class _Tracer extends TracePinger {
  _Tracer(super.connector);
  PingResult? result = const PingResult(Duration(milliseconds: 400), 3, -2);
  Uint8List? lastKey;

  @override
  Future<PingResult?> ping(
    Uint8List repeaterKey, {
    Duration timeout = const Duration(seconds: 8),
  }) async {
    lastKey = repeaterKey;
    return result;
  }
}

void main() {
  late _Radio radio;
  late _Tracer tracer;
  late WardriveService service;
  late StreamController<PositionFix> gps;

  Future<void> moveTo(double lat, double lon, {double acc = 5}) async {
    gps.add(PositionFix(lat, lon, acc, DateTime.now()));
    await Future<void>.delayed(Duration.zero);
  }

  void hear(
    List<int> path, {
    double snr = 4,
    int rssi = -95,
    bool self = false,
  }) => radio.rx.add(
    RadioRxPacket(
      raw: _flood(0x02, path, [9, 9, 9]),
      snr: snr,
      rssi: rssi,
      receivedAt: DateTime.now(),
      fromSelf: self,
    ),
  );

  setUp(() async {
    gps = StreamController<PositionFix>.broadcast();
    SharedPreferences.setMockInitialValues({});
    PrefsManager.reset();
    await PrefsManager.initialize();
    radio = _Radio();
    tracer = _Tracer(radio);
    service = WardriveService(
      radio,
      listenWindow: const Duration(milliseconds: 20),
      fixes: () => gps.stream,
      tracePinger: tracer,
    )..load();
  });
  tearDown(() {
    service.dispose();
    unawaited(gps.close());
    PrefsManager.reset();
  });

  group('packet helpers', () {
    test('the repeater heard directly is the last hop of a flood', () {
      expect(directlyHeardRepeater(_flood(0x02, [0x11, 0x22], [1])), '22');
      expect(directlyHeardRepeater(_flood(0x02, [], [1])), isNull);
      // Direct-routed: the path is the route ahead, not hops taken.
      expect(
        directlyHeardRepeater(Uint8List.fromList([0x02 << 2 | 0x02, 1, 7, 1])),
        isNull,
      );
    });

    test('a zero-hop repeater advert names its sender', () {
      final payload = [
        0xAB, 0xCD, 0xEF, 0x01, ...List.filled(28, 0), // key
        ...List.filled(4, 0), // time
        ...List.filled(64, 0), // signature
        advTypeRepeater, // flags
      ];
      expect(directlyHeardRepeater(_flood(0x04, [], payload)), 'abcdef01');
    });

    test('a channel echo gives the first hop and only for that channel', () {
      final raw = _flood(0x05, [0x33, 0x44], [_wardriveHash, 1]);
      expect(channelEcho(raw, _wardriveHash), (firstHop: '33', hops: 2));
      expect(channelEcho(raw, (_wardriveHash + 1) & 0xFF), isNull);
      expect(
        channelEcho(_flood(0x05, [], [_wardriveHash]), _wardriveHash),
        isNull,
      );
    });

    test('old saved pings still load as discovery pings', () {
      final ping = WardrivePing.fromJson(
        jsonDecode(
              '{"at":"2026-11-01T10:00:00.000Z","lat":1,"lon":2,'
              '"replies":[{"prefix":"ab","snrThere":2,"snrHere":5,"rssiHere":-90}]}',
            )
            as Map<String, dynamic>,
      );
      expect(ping.kind, WardriveKind.discovery);
      expect(ping.sent, isTrue);
      expect(ping.bestSnr, 2);
    });

    test('grid squares are stable and about the right size', () {
      final a = GridSquare.at(41.3280, -73.0940, 300);
      expect(GridSquare.at(41.3281, -73.0941, 300), a);
      final b = a.bounds;
      final height = metresBetween(b.south, b.west, b.north, b.west);
      final width = metresBetween(b.south, b.west, b.south, b.east);
      expect(height, closeTo(300, 5));
      expect(width, closeTo(300, 5));
    });
  });

  group('timed pings', () {
    test('wait until you move 25 m; a ping by hand still goes out', () async {
      await moveTo(41.3280, -73.0940);
      await service.start();
      expect(radio.discovers, 1);
      await moveTo(41.32805, -73.0940); // ~6 m
      await service.debugTimedPing();
      expect(radio.discovers, 1);
      expect(service.wait, WardriveWait.notMoved);
      await service.pingNow();
      expect(radio.discovers, 2);
      await moveTo(41.3290, -73.0940); // ~110 m
      service.update(service.settings.copyWith(skipCovered: false));
      await service.debugTimedPing();
      expect(radio.discovers, 3);
    });

    test('skip squares already covered, leaving a marker', () async {
      await moveTo(41.3280, -73.0940);
      await service.start();
      await service.stop();
      // A new drive over the same ground: the start ping goes out, the
      // timed one is held, even after moving within the square.
      await service.start();
      await moveTo(41.3283, -73.0943); // ~40 m, same 300 m square
      final before = radio.discovers;
      await service.debugTimedPing();
      expect(radio.discovers, before);
      expect(service.wait, WardriveWait.covered);
      expect(service.active!.skippedCount, 1);
      expect(service.active!.sentCount, 1);
    });

    test('an unheard square is not counted as covered', () async {
      radio.answering = [];
      await moveTo(41.3280, -73.0940);
      await service.start();
      await moveTo(41.3283, -73.0943);
      await service.debugTimedPing();
      expect(radio.discovers, 2);
    });
  });

  group('filters', () {
    test('the car repeater and very strong signals are left out', () async {
      service.update(service.settings.copyWith(carRepeater: 'fa01'));
      radio.answering = [
        [0xFA, 0x01, 0x02, 0x03],
        [0xBB, 0x01],
      ];
      await service.start();
      expect(service.active!.pings.single.replies.map((r) => r.prefix), [
        'bb01',
      ]);
    });
  });

  group('passive logging', () {
    test('logs the repeater heard, once per square', () async {
      await service.start();
      await moveTo(41.3280, -73.0940);
      hear([0x10, 0xAB], snr: 6.5);
      hear([0xAB]);
      hear([0xAB], self: true); // our own traffic
      hear([0xCC], rssi: -20); // beside us
      await Future<void>.delayed(Duration.zero);
      final passive = service.active!.pings
          .where((p) => p.kind == WardriveKind.passive)
          .toList();
      expect(passive, hasLength(1));
      expect(passive.single.replies.single.prefix, 'ab');
      expect(passive.single.replies.single.snrHere, 6.5);
      expect(passive.single.accuracy, 5);
      expect(service.active!.sentCount, 1, reason: 'passive is not a ping');
    });

    test('off means nothing is logged', () async {
      service.update(service.settings.copyWith(passive: false));
      await service.start();
      hear([0xAB]);
      await Future<void>.delayed(Duration.zero);
      expect(
        service.active!.pings.where((p) => p.kind == WardriveKind.passive),
        isEmpty,
      );
    });
  });

  group('modes', () {
    test('channel mode needs the wardriving channel', () async {
      service.update(service.settings.copyWith(mode: WardriveMode.channel));
      await service.start();
      expect(service.wait, WardriveWait.noChannel);
      expect(radio.channelSends, 0);
      expect(service.active!.pings, isEmpty);
    });

    test('channel mode records the repeaters that pass the ping on', () async {
      radio.channelList = [
        Channel(index: 3, name: '#wardriving', psk: _wardrivePsk),
      ];
      radio.echoes = [
        ([0x5A], 7.25),
        ([0x6B, 0x77], -3),
      ];
      service.update(service.settings.copyWith(mode: WardriveMode.channel));
      await service.start();
      final ping = service.active!.pings.single;
      expect(ping.kind, WardriveKind.channel);
      expect(radio.discovers, 0);
      final byPrefix = {for (final r in ping.replies) r.prefix: r};
      expect(byPrefix.keys, unorderedEquals(['5a', '6b']));
      expect(byPrefix['5a']!.snrHere, 7.25);
      expect(byPrefix['6b']!.snrHere, isNull, reason: 'heard two hops away');
    });

    test('trace mode needs a repeater, then measures both ways', () async {
      service.update(service.settings.copyWith(mode: WardriveMode.trace));
      await service.start();
      expect(service.wait, WardriveWait.noTraceTarget);
      await service.stop();

      service.update(
        service.settings.copyWith(traceTarget: 'a1b2c3d4e5f60708'),
      );
      await service.start();
      final r = service.active!.pings.single.replies.single;
      expect(tracer.lastKey, [0xA1, 0xB2, 0xC3, 0xD4]);
      expect(r.prefix, 'a1b2c3d4');
      expect(r.snrThere, 3);
      expect(r.snrHere, -2);
    });

    test('hybrid takes turns between discovery and channel', () async {
      radio.channelList = [
        Channel(index: 3, name: '#wardriving', psk: _wardrivePsk),
      ];
      service.update(service.settings.copyWith(mode: WardriveMode.hybrid));
      await service.start();
      await service.pingNow();
      await service.pingNow();
      expect(service.active!.pings.map((p) => p.kind), [
        WardriveKind.discovery,
        WardriveKind.channel,
        WardriveKind.discovery,
      ]);
    });
  });

  test('noise floor readings are kept and stamped on pings', () async {
    radio.radioStatsNotifier.value = CompanionRadioStats(
      noiseFloorDbm: -110,
      lastRssiDbm: -90,
      lastSnrDb: 5,
      txAirSecs: 0,
      rxAirSecs: 0,
      receivedAt: DateTime.now(),
    );
    await service.start();
    radio.radioStatsNotifier.value = CompanionRadioStats(
      noiseFloorDbm: -104,
      lastRssiDbm: -90,
      lastSnrDb: 5,
      txAirSecs: 0,
      rxAirSecs: 0,
      receivedAt: DateTime.now(),
    );
    expect(service.noiseFloor, -104);
    expect(service.active!.noise.single.dbm, -104);
    await service.pingNow();
    expect(service.active!.pings.last.noiseFloor, -104);
  });

  test('settings are kept between launches', () async {
    service.update(
      service.settings.copyWith(
        mode: WardriveMode.hybrid,
        skipDays: 7,
        carRepeater: 'abcd',
        background: true,
      ),
    );
    await Future<void>.delayed(Duration.zero);
    final again = WardriveService(radio)..load();
    expect(again.settings.mode, WardriveMode.hybrid);
    expect(again.settings.skipDays, 7);
    expect(again.settings.carRepeater, 'abcd');
    expect(again.settings.background, isTrue);
    again.dispose();
  });

  test('an imported drive joins the history once', () async {
    final drive = WardriveSession(
      id: 'x',
      startedAt: DateTime.utc(2026, 11, 1),
      pings: [
        WardrivePing(at: DateTime.utc(2026, 11, 1), latitude: 1, longitude: 2),
      ],
    );
    expect(await service.importSession(drive), isTrue);
    expect(await service.importSession(drive), isFalse);
    expect(service.sessions.single.id, 'x');
    final again = WardriveService(radio)..load();
    expect(again.sessions.single.id, 'x');
    again.dispose();
  });
}
