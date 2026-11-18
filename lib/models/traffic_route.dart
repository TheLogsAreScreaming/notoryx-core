import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' show Color;

import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

import '../connector/meshcore_protocol.dart';
import '../helpers/path_hop_resolver.dart';
import '../models/contact.dart';
import '../services/rx_log_service.dart';
import '../theme/mesh_theme.dart';

/// The six packet families the live traffic map colours routes by.
enum TrafficKind { advert, direct, channel, ack, trace, path }

/// Sorts an RX log kind into a traffic colour family. Control and unknown
/// packets share the path colour.
TrafficKind trafficKindFor(RxKind kind) => switch (kind) {
  RxKind.advert => TrafficKind.advert,
  RxKind.direct => TrafficKind.direct,
  RxKind.channel => TrafficKind.channel,
  RxKind.ack => TrafficKind.ack,
  RxKind.trace => TrafficKind.trace,
  RxKind.path || RxKind.control || RxKind.other => TrafficKind.path,
};

/// The line and dot colour for [kind].
Color trafficKindColor(TrafficKind kind) => switch (kind) {
  TrafficKind.advert => TrafficPalette.advert,
  TrafficKind.direct => TrafficPalette.direct,
  TrafficKind.channel => TrafficPalette.channel,
  TrafficKind.ack => TrafficPalette.ack,
  TrafficKind.trace => TrafficPalette.trace,
  TrafficKind.path => TrafficPalette.path,
};

/// One stop on a packet's route: the node that sent it, a repeater that
/// relayed it, or this radio.
@immutable
class TrafficHop {
  const TrafficHop({
    required this.id,
    this.name,
    this.point,
    this.role = TrafficHopRole.relay,
  });

  /// Short upper-case hex ID: the path hash, or the start of a public key.
  final String id;

  /// The contact's name, when the hop could be matched to one.
  final String? name;

  /// Where the hop is, or null when it isn't on the map.
  final LatLng? point;

  final TrafficHopRole role;

  /// The name when known, otherwise the short ID.
  String get label {
    final n = name?.trim();
    return n == null || n.isEmpty ? id : n;
  }

  bool get isOnMap => point != null;
}

enum TrafficHopRole { origin, relay, self }

/// A packet the radio heard, laid out as a route from where it started,
/// through each repeater, to this radio.
@immutable
class TrafficRoute {
  const TrafficRoute({
    required this.kind,
    required this.hops,
    required this.snr,
    required this.rssi,
    required this.hopCount,
    required this.isFlood,
    required this.receivedAt,
    required this.packetHash,
  });

  final TrafficKind kind;

  /// In travel order. Starts with the origin when it is known and ends with
  /// this radio.
  final List<TrafficHop> hops;
  final double snr;
  final int rssi;

  /// Repeaters the packet passed through, from its header.
  final int hopCount;
  final bool isFlood;
  final DateTime receivedAt;

  /// Same value for every copy of one packet, so repeats can be dropped.
  final String packetHash;

  /// The hops that are on the map, in order. Hops without a position are
  /// skipped, so the route jumps to the next known one.
  List<TrafficHop> get mappedHops => [
    for (final h in hops)
      if (h.isOnMap) h,
  ];

  /// [mappedHops] as map points.
  List<LatLng> get mapPoints => [for (final h in mappedHops) h.point!];

  /// Origin and relays that have no position. This radio is never listed.
  List<TrafficHop> get notOnMap => [
    for (final h in hops)
      if (!h.isOnMap && h.role != TrafficHopRole.self) h,
  ];

  /// Whether there is at least one leg to draw.
  bool get isDrawable => mapPoints.length >= 2;

  /// The node this radio heard the packet from: the last relay, or the
  /// origin when it came direct. Null when neither is known.
  TrafficHop? get heardFrom {
    for (final h in hops.reversed) {
      if (h.role != TrafficHopRole.self) return h;
    }
    return null;
  }

  /// Every hop except this radio, for the `A → B → C` line.
  List<TrafficHop> get pathHops => [
    for (final h in hops)
      if (h.role != TrafficHopRole.self) h,
  ];
}

/// Builds a [TrafficRoute] from a packet in the RX log.
///
/// The origin comes from the advert's public key, the source hash of a
/// direct packet, or the sender key of an anonymous request. Relays come
/// from the flood path (or a trace's route), matched to repeaters by key
/// prefix and distance. Channel messages and acks carry no sender, so their
/// route starts at the first relay.
TrafficRoute buildTrafficRoute(
  RxLogEntry entry, {
  required List<Contact> contacts,
  LatLng? selfPosition,
  String selfLabel = '',
}) {
  final info = entry.info;
  final payload = info.payload;
  final kind = trafficKindFor(entry.kind);

  final origin = _origin(info.payloadType, payload, contacts);

  // Relays the packet has passed, in travel order.
  var relayBytes = const <int>[];
  var width = info.pathHashWidth;
  if (info.payloadType == payloadTypeTRACE) {
    // A trace carries its route in the payload; the header path holds one
    // SNR byte per hop travelled so far.
    if (payload.length > 9) {
      width = 1 << (payload[8] & 0x03);
      final route = payload.sublist(9);
      final travelled = (info.hopCount * width).clamp(0, route.length);
      relayBytes = route.sublist(0, travelled - travelled % width);
    }
  } else if (!info.isDirect) {
    relayBytes = info.path;
  }

  final relays = <TrafficHop>[];
  if (relayBytes.isNotEmpty) {
    final resolved = PathHopResolver.resolve(
      pathBytes: relayBytes,
      contacts: contacts,
      endpoint: selfPosition,
      resolveFromEnd: true,
      pathHashByteWidth: width,
    );
    for (var i = 0; i < resolved.length; i++) {
      final start = i * width;
      final id = _hex(relayBytes.sublist(start, start + width));
      final c = resolved[i];
      relays.add(
        TrafficHop(id: id, name: c?.name, point: c == null ? null : _pos(c)),
      );
    }
  }

  return TrafficRoute(
    kind: kind,
    hops: [
      ?origin,
      ...relays,
      TrafficHop(
        id: selfLabel,
        name: selfLabel,
        point: selfPosition,
        role: TrafficHopRole.self,
      ),
    ],
    snr: entry.snr,
    rssi: entry.rssi,
    hopCount: info.payloadType == payloadTypeTRACE
        ? relays.length
        : (info.isDirect ? 0 : info.hopCount),
    isFlood: !info.isDirect,
    receivedAt: entry.receivedAt,
    packetHash: info.hash,
  );
}

TrafficHop? _origin(int payloadType, Uint8List payload, List<Contact> all) {
  switch (payloadType) {
    case payloadTypeADVERT:
      if (payload.length < 32) return null;
      final key = payload.sublist(0, 32);
      final contact = _byKey(all, key);
      final advert = _advertAppData(payload);
      return TrafficHop(
        id: _hex(key.sublist(0, 3)),
        name: contact?.name ?? advert.name,
        point: (contact == null ? null : _pos(contact)) ?? advert.point,
        role: TrafficHopRole.origin,
      );
    case payloadTypeANONREQ:
      if (payload.length < 33) return null;
      final key = payload.sublist(1, 33);
      final contact = _byKey(all, key);
      return TrafficHop(
        id: _hex(key.sublist(0, 3)),
        name: contact?.name,
        point: contact == null ? null : _pos(contact),
        role: TrafficHopRole.origin,
      );
    case payloadTypeTXTMSG ||
        payloadTypeREQ ||
        payloadTypeRESPONSE ||
        payloadTypePATH:
      if (payload.length < 2) return null;
      final src = payload[1];
      // A one-byte hash names a node only when exactly one contact has it.
      final matches = [
        for (final c in all)
          if (c.publicKey.isNotEmpty && c.publicKey[0] == src) c,
      ];
      final contact = matches.length == 1 ? matches.single : null;
      return TrafficHop(
        id: _hex([src]),
        name: contact?.name,
        point: contact == null ? null : _pos(contact),
        role: TrafficHopRole.origin,
      );
    default:
      return null;
  }
}

Contact? _byKey(List<Contact> all, List<int> key) {
  for (final c in all) {
    if (listEquals(c.publicKey, key)) return c;
  }
  return null;
}

LatLng? _pos(Contact c) =>
    c.hasLocation ? LatLng(c.latitude!, c.longitude!) : null;

/// Name and position from an advert's app data:
/// `[key x32][time x4][signature x64][flags][lat x4, lon x4 if 0x10]
/// [x2 if 0x20][x2 if 0x40][name if 0x80]`.
({String? name, LatLng? point}) _advertAppData(Uint8List payload) {
  if (payload.length < 101) return (name: null, point: null);
  final flags = payload[100];
  var i = 101;
  LatLng? point;
  if (flags & 0x10 != 0) {
    if (payload.length < i + 8) return (name: null, point: null);
    final data = ByteData.sublistView(payload, i, i + 8);
    final lat = data.getInt32(0, Endian.little) / 1e6;
    final lon = data.getInt32(4, Endian.little) / 1e6;
    final valid =
        (lat.abs() > 1e-6 || lon.abs() > 1e-6) &&
        lat.abs() <= 90 &&
        lon.abs() <= 180;
    if (valid) point = LatLng(lat, lon);
    i += 8;
  }
  if (flags & 0x20 != 0) i += 2;
  if (flags & 0x40 != 0) i += 2;
  String? name;
  if (flags & 0x80 != 0 && i < payload.length) {
    final bytes = payload.sublist(i).takeWhile((b) => b != 0).toList();
    name = utf8.decode(bytes, allowMalformed: true).trim();
    if (name.isEmpty) name = null;
  }
  return (name: name, point: point);
}

String _hex(List<int> bytes) =>
    bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join().toUpperCase();

/// A route on screen, with the moment it started animating.
@immutable
class ActiveTrafficRoute {
  const ActiveTrafficRoute(this.route, this.startedAt, {required this.travel});

  final TrafficRoute route;
  final DateTime startedAt;

  /// How long the dot takes to travel the whole route. Zero with reduce
  /// motion: the line is drawn at once and fades.
  final Duration travel;

  /// The whole time on screen: travel, then the fade.
  Duration get lifetime => travel + TrafficQueue.fade;

  /// 0..legs: how far along the route the dot is at [now].
  double legProgress(DateTime now) {
    final legs = route.mapPoints.length - 1;
    if (legs <= 0) return 0;
    if (travel == Duration.zero) return legs.toDouble();
    final t = now.difference(startedAt).inMicroseconds / travel.inMicroseconds;
    return (t.clamp(0.0, 1.0)) * legs;
  }

  /// 1 while travelling, then down to 0 over [TrafficQueue.fade].
  double opacity(DateTime now) {
    final sinceArrival = now.difference(startedAt) - travel;
    if (sinceArrival <= Duration.zero) return 1;
    final f = sinceArrival.inMicroseconds / TrafficQueue.fade.inMicroseconds;
    return (1 - f).clamp(0.0, 1.0);
  }

  bool isDone(DateTime now) => now.difference(startedAt) >= lifetime;
}

/// Keeps at most [maxActive] routes animating at once and queues the rest,
/// dropping the oldest waiting ones when the queue is full.
class TrafficQueue {
  TrafficQueue({this.maxActive = 3, this.maxPending = 12});

  static const fade = Duration(milliseconds: 3500);
  static const perLeg = Duration(milliseconds: 550);
  static const maxTravel = Duration(seconds: 4);

  final int maxActive;
  final int maxPending;
  final List<ActiveTrafficRoute> _active = [];
  final List<TrafficRoute> _pending = [];
  final List<String> _recentHashes = [];

  List<ActiveTrafficRoute> get active => List.unmodifiable(_active);
  int get pendingCount => _pending.length;
  bool get isIdle => _active.isEmpty && _pending.isEmpty;

  /// How long the dot takes over a route with [legs] legs.
  static Duration travelFor(int legs, {required bool reduceMotion}) {
    if (reduceMotion || legs <= 0) return Duration.zero;
    final t = perLeg * legs;
    return t > maxTravel ? maxTravel : t;
  }

  /// Adds [route] unless it can't be drawn or the same packet was just
  /// shown (a flood is heard once per repeater in range).
  /// Returns whether it was taken.
  bool add(TrafficRoute route, DateTime now, {bool reduceMotion = false}) {
    if (!route.isDrawable) return false;
    if (_recentHashes.contains(route.packetHash)) return false;
    _recentHashes.add(route.packetHash);
    if (_recentHashes.length > 64) _recentHashes.removeAt(0);
    _pending.add(route);
    while (_pending.length > maxPending) {
      _pending.removeAt(0);
    }
    tick(now, reduceMotion: reduceMotion);
    return true;
  }

  /// Drops finished routes and starts waiting ones in their place.
  void tick(DateTime now, {bool reduceMotion = false}) {
    _active.removeWhere((r) => r.isDone(now));
    while (_active.length < maxActive && _pending.isNotEmpty) {
      final next = _pending.removeAt(0);
      _active.add(
        ActiveTrafficRoute(
          next,
          now,
          travel: travelFor(
            next.mapPoints.length - 1,
            reduceMotion: reduceMotion,
          ),
        ),
      );
    }
  }

  void clear() {
    _active.clear();
    _pending.clear();
  }
}
