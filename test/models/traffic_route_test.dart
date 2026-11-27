import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:meshcore_open/connector/meshcore_protocol.dart';
import 'package:meshcore_open/models/contact.dart';
import 'package:meshcore_open/models/radio_rx_packet.dart';
import 'package:meshcore_open/models/traffic_route.dart';
import 'package:meshcore_open/services/rx_log_service.dart';
import 'package:meshcore_open/theme/mesh_theme.dart';

const _flood = 1;
const _direct = 2;
final _t0 = DateTime.utc(2026, 11, 18, 12);
const _self = LatLng(40.0, -75.0);

Uint8List _key(int first) => Uint8List.fromList([
  first,
  ...List<int>.generate(31, (i) => (i * 7 + first) & 0xFF),
]);

Contact _repeater(
  int first,
  String name, {
  double? lat,
  double? lon,
  int type = advTypeRepeater,
}) => Contact(
  publicKey: _key(first),
  name: name,
  type: type,
  pathLength: -1,
  path: Uint8List(0),
  latitude: lat,
  longitude: lon,
  lastSeen: _t0,
);

/// `[header][path len][path][payload]` for a non-transport route.
RxLogEntry _packet({
  required int payloadType,
  int route = _flood,
  List<int> path = const [],
  int width = 1,
  List<int> payload = const [0, 0, 0, 0],
  double snr = 7.5,
  int rssi = -90,
}) {
  final raw = Uint8List.fromList([
    (payloadType << 2) | route,
    (path.length ~/ width) | ((width - 1) << 6),
    ...path,
    ...payload,
  ]);
  return RxLogEntry.from(
    RadioRxPacket(raw: raw, snr: snr, rssi: rssi, receivedAt: _t0),
  )!;
}

List<int> _advertPayload(
  Uint8List key, {
  String? name,
  double? lat,
  double? lon,
}) {
  var flags = 0x02;
  final extra = <int>[];
  if (lat != null && lon != null) {
    flags |= 0x10;
    final b = ByteData(8)
      ..setInt32(0, (lat * 1e6).round(), Endian.little)
      ..setInt32(4, (lon * 1e6).round(), Endian.little);
    extra.addAll(b.buffer.asUint8List());
  }
  if (name != null) {
    flags |= 0x80;
    extra.addAll(utf8.encode(name));
  }
  return [...key, 0, 0, 0, 0, ...List<int>.filled(64, 0), flags, ...extra];
}

void main() {
  final a = _repeater(0xA1, 'Alpha', lat: 40.30, lon: -75.30);
  final b = _repeater(0xB2, 'Bravo', lat: 40.20, lon: -75.20);
  final c = _repeater(0xC3, 'Charlie'); // no position
  final d = _repeater(0xD4, 'Delta', lat: 40.10, lon: -75.10);
  final contacts = [a, b, c, d];

  group('colour by type', () {
    test('each RX kind maps to one of six colours', () {
      expect(trafficKindFor(RxKind.advert), TrafficKind.advert);
      expect(trafficKindFor(RxKind.direct), TrafficKind.direct);
      expect(trafficKindFor(RxKind.channel), TrafficKind.channel);
      expect(trafficKindFor(RxKind.ack), TrafficKind.ack);
      expect(trafficKindFor(RxKind.trace), TrafficKind.trace);
      expect(trafficKindFor(RxKind.path), TrafficKind.path);
      expect(trafficKindFor(RxKind.control), TrafficKind.path);
      expect(trafficKindFor(RxKind.other), TrafficKind.path);
    });

    test('colours are distinct and follow the legend', () {
      expect(trafficKindColor(TrafficKind.advert), TrafficPalette.advert);
      expect(trafficKindColor(TrafficKind.direct), TrafficPalette.direct);
      expect(trafficKindColor(TrafficKind.channel), TrafficPalette.channel);
      expect(trafficKindColor(TrafficKind.ack), TrafficPalette.ack);
      expect(trafficKindColor(TrafficKind.trace), TrafficPalette.trace);
      expect(trafficKindColor(TrafficKind.path), TrafficPalette.path);
      final all = TrafficKind.values.map(trafficKindColor).toSet();
      expect(all, hasLength(6));
    });
  });

  group('buildTrafficRoute', () {
    test('flood advert: origin, relays in order, then us', () {
      final origin = _repeater(0x11, 'Origin', lat: 40.40, lon: -75.40);
      final route = buildTrafficRoute(
        _packet(
          payloadType: payloadTypeADVERT,
          path: [0xA1, 0xB2, 0xD4],
          payload: _advertPayload(origin.publicKey),
        ),
        contacts: [...contacts, origin],
        selfPosition: _self,
        selfLabel: 'You',
      );
      expect(route.kind, TrafficKind.advert);
      expect(route.hops.map((h) => h.label), [
        'Origin',
        'Alpha',
        'Bravo',
        'Delta',
        'You',
      ]);
      expect(route.hops.first.role, TrafficHopRole.origin);
      expect(route.hops.last.role, TrafficHopRole.self);
      expect(route.mapPoints, [
        const LatLng(40.40, -75.40),
        const LatLng(40.30, -75.30),
        const LatLng(40.20, -75.20),
        const LatLng(40.10, -75.10),
        _self,
      ]);
      expect(route.hopCount, 3);
      expect(route.isFlood, isTrue);
      expect(route.heardFrom?.label, 'Delta');
      expect(route.notOnMap, isEmpty);
    });

    test('hops without a position are skipped on the map', () {
      final route = buildTrafficRoute(
        _packet(payloadType: payloadTypeGRPTXT, path: [0xA1, 0xC3, 0xD4]),
        contacts: contacts,
        selfPosition: _self,
      );
      expect(route.kind, TrafficKind.channel);
      // Channel messages carry no sender: route starts at the first relay.
      expect(route.hops.first.role, TrafficHopRole.relay);
      expect(route.pathHops.map((h) => h.label), ['Alpha', 'Charlie', 'Delta']);
      expect(route.mapPoints, [
        const LatLng(40.30, -75.30),
        const LatLng(40.10, -75.10),
        _self,
      ]);
      expect(route.notOnMap.map((h) => h.label), ['Charlie']);
      expect(route.isDrawable, isTrue);
    });

    test('unknown hashes keep their hex ID and are not on the map', () {
      final route = buildTrafficRoute(
        _packet(payloadType: payloadTypeACK, path: [0x5E, 0xD4]),
        contacts: contacts,
        selfPosition: _self,
      );
      expect(route.kind, TrafficKind.ack);
      expect(route.pathHops.map((h) => h.label), ['5E', 'Delta']);
      expect(route.notOnMap.single.id, '5E');
      expect(route.mapPoints, [const LatLng(40.10, -75.10), _self]);
    });

    test('two-byte path hashes', () {
      final route = buildTrafficRoute(
        _packet(
          payloadType: payloadTypeGRPTXT,
          width: 2,
          path: [0xA1, a.publicKey[1], 0xD4, d.publicKey[1]],
        ),
        contacts: contacts,
        selfPosition: _self,
      );
      expect(route.pathHops.map((h) => h.label), ['Alpha', 'Delta']);
      expect(route.pathHops.first.id.length, 4);
    });

    test('advert from a stranger uses the position and name it carries', () {
      final key = _key(0x77);
      final route = buildTrafficRoute(
        _packet(
          payloadType: payloadTypeADVERT,
          path: [0xD4],
          payload: _advertPayload(key, name: 'Hilltop', lat: 40.5, lon: -75.5),
        ),
        contacts: contacts,
        selfPosition: _self,
      );
      final origin = route.hops.first;
      expect(origin.role, TrafficHopRole.origin);
      expect(origin.label, 'Hilltop');
      expect(origin.id, '77777E');
      expect(origin.point, const LatLng(40.5, -75.5));
    });

    test('an advert name that is not valid text falls back to the ID', () {
      final key = _key(0x78);
      final payload = _advertPayload(key, name: 'x');
      payload
        ..removeLast()
        ..addAll([0xFF, 0x65, 0x21, 0x01, 0x6B]);
      final route = buildTrafficRoute(
        _packet(payloadType: payloadTypeADVERT, path: [0xD4], payload: payload),
        contacts: contacts,
        selfPosition: _self,
      );
      expect(route.hops.first.name, isNull);
      expect(route.hops.first.label, route.hops.first.id);
    });

    test('direct message: origin from a unique source hash, no relays', () {
      final sender = _repeater(
        0x42,
        'Sender',
        lat: 40.05,
        lon: -75.05,
        type: advTypeChat,
      );
      final route = buildTrafficRoute(
        _packet(
          payloadType: payloadTypeTXTMSG,
          route: _direct,
          path: [0xA1],
          payload: [0x99, 0x42, 1, 2, 3],
        ),
        contacts: [...contacts, sender],
        selfPosition: _self,
      );
      expect(route.kind, TrafficKind.direct);
      expect(route.isFlood, isFalse);
      expect(route.hopCount, 0);
      // A direct packet's path is the route still ahead, not hops taken.
      expect(route.hops.map((h) => h.label), ['Sender', '']);
      expect(route.mapPoints, [const LatLng(40.05, -75.05), _self]);
    });

    test('an ambiguous one-byte source hash is not given a name', () {
      final x = _repeater(0x42, 'X', type: advTypeChat);
      final y = _repeater(0x42, 'Y', type: advTypeChat)..publicKey[5] ^= 0xFF;
      final route = buildTrafficRoute(
        _packet(
          payloadType: payloadTypeTXTMSG,
          path: [0xD4],
          payload: [0x99, 0x42, 1, 2],
        ),
        contacts: [...contacts, x, y],
        selfPosition: _self,
      );
      expect(route.hops.first.label, '42');
      expect(route.hops.first.point, isNull);
      expect(route.notOnMap.map((h) => h.id), ['42']);
    });

    test('trace takes its route from the payload', () {
      final route = buildTrafficRoute(
        _packet(
          payloadType: payloadTypeTRACE,
          route: _direct,
          path: [20, 18], // SNR bytes: two hops travelled
          payload: [1, 2, 3, 4, 5, 6, 7, 8, 0, 0xA1, 0xB2, 0xD4],
        ),
        contacts: contacts,
        selfPosition: _self,
      );
      expect(route.kind, TrafficKind.trace);
      expect(route.pathHops.map((h) => h.label), ['Alpha', 'Bravo']);
      expect(route.hopCount, 2);
    });

    test('without our position the route still ends at us, off the map', () {
      final route = buildTrafficRoute(
        _packet(payloadType: payloadTypeGRPTXT, path: [0xA1, 0xD4]),
        contacts: contacts,
      );
      expect(route.mapPoints, hasLength(2));
      expect(route.notOnMap, isEmpty);
      expect(route.hops.last.isOnMap, isFalse);
    });

    test('one known point is not drawable', () {
      final route = buildTrafficRoute(
        _packet(payloadType: payloadTypeGRPTXT, path: [0x5E]),
        contacts: contacts,
        selfPosition: _self,
      );
      expect(route.isDrawable, isFalse);
    });
  });

  group('channelSenderHop', () {
    Contact chat(int first, String name, {double? lat}) => _repeater(
      first,
      name,
      lat: lat,
      lon: lat == null ? null : -75.4,
      type: advTypeChat,
    );

    test('places the one located companion with that name', () {
      final hop = channelSenderHop(' Walker ', [
        chat(0x11, 'Walker', lat: 40.4),
        _repeater(0x22, 'Walker', lat: 40.6, lon: -75),
      ])!;
      expect(hop.role, TrafficHopRole.origin);
      expect(hop.point, const LatLng(40.4, -75.4));
      expect(hop.id, startsWith('11'));
      expect(hop.name, 'Walker');
    });

    test('shared, unknown or unplaced names give no start', () {
      expect(
        channelSenderHop('Walker', [
          chat(0x11, 'Walker', lat: 40.4),
          chat(0x12, 'Walker', lat: 40.5),
        ]),
        isNull,
      );
      expect(channelSenderHop('Walker', [chat(0x11, 'Walker')]), isNull);
      expect(channelSenderHop('Nobody', contacts), isNull);
      expect(channelSenderHop('', contacts), isNull);
    });
  });

  group('TrafficQueue', () {
    TrafficRoute route(String hash, {int legs = 2}) => TrafficRoute(
      kind: TrafficKind.channel,
      hops: [
        for (var i = 0; i <= legs; i++)
          TrafficHop(id: '$i', point: LatLng(40 + i / 10, -75)),
      ],
      snr: 0,
      rssi: 0,
      hopCount: legs,
      isFlood: true,
      receivedAt: _t0,
      packetHash: hash,
    );

    TrafficRoute via(String hash, List<double> lats) => TrafficRoute(
      kind: TrafficKind.channel,
      hops: [
        for (final lat in lats) TrafficHop(id: '$lat', point: LatLng(lat, -75)),
      ],
      snr: 0,
      rssi: 0,
      hopCount: lats.length - 1,
      isFlood: true,
      receivedAt: _t0,
      packetHash: hash,
    );

    test('a copy by another route becomes a branch of the same packet', () {
      final q = TrafficQueue(maxActive: 1);
      expect(q.add(via('p', [40.3, 40.2, 40]), _t0), isTrue);
      expect(q.add(via('p', [40.3, 40.1, 40]), _t0), isTrue);
      expect(q.add(via('p', [40.3, 40.1, 40]), _t0), isFalse);
      // Branches don't count against the packet cap.
      expect(q.active, hasLength(2));
      expect(q.activePackets, 1);
      // A new packet waits for a free slot.
      expect(q.add(via('q', [40.4, 40]), _t0), isTrue);
      expect(q.pendingCount, 1);
    });

    test('late copies and copies past the branch cap are dropped', () {
      final q = TrafficQueue(maxBranches: 2);
      q.add(via('p', [40.3, 40]), _t0);
      q.add(via('p', [40.2, 40]), _t0);
      expect(q.add(via('p', [40.1, 40]), _t0), isFalse);
      final r = TrafficQueue();
      r.add(via('p', [40.3, 40]), _t0);
      final later = _t0.add(
        TrafficQueue.branchWindow + const Duration(seconds: 1),
      );
      expect(r.add(via('p', [40.2, 40]), later), isFalse);
    });

    test('travel fraction runs 0 to 1, and is 1 with reduce motion', () {
      final q = TrafficQueue()..add(route('a', legs: 2), _t0);
      final r = q.active.single;
      expect(r.travelFraction(_t0), 0);
      expect(r.travelFraction(_t0.add(r.travel ~/ 2)), closeTo(0.5, 1e-6));
      expect(r.travelFraction(_t0.add(r.travel * 3)), 1);
      final still = TrafficQueue()..add(route('b'), _t0, reduceMotion: true);
      expect(still.active.single.travelFraction(_t0), 1);
    });

    test('caps concurrent routes and queues the rest', () {
      final q = TrafficQueue(maxActive: 3);
      for (var i = 0; i < 5; i++) {
        q.add(route('h$i'), _t0);
      }
      expect(q.active, hasLength(3));
      expect(q.pendingCount, 2);
      final done = _t0.add(q.active.first.lifetime);
      q.tick(done);
      expect(q.active.map((r) => r.route.packetHash), ['h3', 'h4']);
      expect(q.pendingCount, 0);
    });

    test('drops repeats of the same packet and undrawable routes', () {
      final q = TrafficQueue();
      expect(q.add(route('same'), _t0), isTrue);
      expect(q.add(route('same'), _t0), isFalse);
      expect(q.add(route('flat', legs: 0), _t0), isFalse);
      expect(q.active, hasLength(1));
    });

    test('dot travels leg by leg, then the route fades out', () {
      final q = TrafficQueue()..add(route('a', legs: 2), _t0);
      final r = q.active.single;
      expect(r.travel, TrafficQueue.perLeg * 2);
      expect(r.legProgress(_t0), 0);
      expect(r.legProgress(_t0.add(TrafficQueue.perLeg)), closeTo(1, 1e-9));
      expect(r.legProgress(_t0.add(r.travel * 2)), 2);
      expect(r.opacity(_t0.add(r.travel)), 1);
      final halfFade = _t0.add(r.travel + TrafficQueue.fade ~/ 2);
      expect(r.opacity(halfFade), closeTo(0.5, 1e-9));
      expect(r.isDone(_t0.add(r.lifetime)), isTrue);
    });

    test('reduce motion draws the whole line at once', () {
      final q = TrafficQueue()..add(route('a'), _t0, reduceMotion: true);
      final r = q.active.single;
      expect(r.travel, Duration.zero);
      expect(r.legProgress(_t0), 2);
    });

    test('long routes travel no longer than the cap', () {
      expect(
        TrafficQueue.travelFor(40, reduceMotion: false),
        TrafficQueue.maxTravel,
      );
    });
  });
}
