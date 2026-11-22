import 'dart:typed_data';

import '../connector/meshcore_protocol.dart';

/// One repeater that answered a wardrive ping, or that this radio heard
/// relaying traffic: how well it heard us, and how well we heard it. A
/// direction that wasn't measured is null (a channel echo two hops away says
/// who heard us but not how well).
class WardriveReply {
  const WardriveReply({
    required this.prefix,
    this.snrThere,
    this.snrHere,
    this.rssiHere,
  });

  /// The repeater's public key prefix, as hex.
  final String prefix;

  /// SNR (dB) the repeater heard our ping at.
  final double? snrThere;

  /// SNR (dB) and RSSI (dBm) we heard it at.
  final double? snrHere;
  final int? rssiHere;

  /// The weaker measured direction: a link is only as good as its worse
  /// side. Null when neither was measured.
  double? get link {
    final a = snrThere, b = snrHere;
    if (a == null) return b;
    if (b == null) return a;
    return a < b ? a : b;
  }

  /// Whether this reply is from the repeater with prefix [other]; either may
  /// be the shorter of the two.
  bool matches(String other) {
    final a = prefix.toLowerCase(), b = other.toLowerCase();
    if (a.isEmpty || b.isEmpty) return false;
    return a.startsWith(b) || b.startsWith(a);
  }

  Map<String, dynamic> toJson() => {
    'prefix': prefix,
    if (snrThere != null) 'snrThere': snrThere,
    if (snrHere != null) 'snrHere': snrHere,
    if (rssiHere != null) 'rssiHere': rssiHere,
  };

  factory WardriveReply.fromJson(Map<String, dynamic> j) => WardriveReply(
    prefix: j['prefix'] as String? ?? '',
    snrThere: (j['snrThere'] as num?)?.toDouble(),
    snrHere: (j['snrHere'] as num?)?.toDouble(),
    rssiHere: (j['rssiHere'] as num?)?.toInt(),
  );
}

/// How a wardrive point was made.
enum WardriveKind {
  /// A zero-hop discover request; repeaters in range answer.
  discovery,

  /// A zero-hop trace to one chosen repeater, measured both ways.
  trace,

  /// A message to the wardriving channel; repeaters that pass it on count.
  channel,

  /// Traffic the radio heard on its own. Costs no airtime.
  passive,

  /// A timed ping held back because you hadn't moved far enough, or the
  /// square was already covered.
  skipped;

  static WardriveKind fromName(String? name) => WardriveKind.values.firstWhere(
    (k) => k.name == name,
    orElse: () => discovery,
  );
}

/// A ping sent from one spot (or traffic heard there), and the repeaters
/// that answered.
class WardrivePing {
  const WardrivePing({
    required this.at,
    required this.latitude,
    required this.longitude,
    this.replies = const [],
    this.kind = WardriveKind.discovery,
    this.accuracy,
    this.noiseFloor,
  });

  final DateTime at;
  final double latitude;
  final double longitude;
  final List<WardriveReply> replies;
  final WardriveKind kind;

  /// GPS accuracy (m) of the position, when the phone gave one.
  final double? accuracy;

  /// The radio's noise floor (dBm) at the time, when it was being recorded.
  final int? noiseFloor;

  bool get heard => replies.isNotEmpty;

  /// Whether this point went out on the air (not passive, not skipped).
  bool get sent => kind != WardriveKind.passive && kind != WardriveKind.skipped;

  /// The weaker of the two directions for the best repeater: a link is only
  /// as good as its worse side. Null when nobody answered.
  double? get bestSnr {
    double? best;
    for (final r in replies) {
      final link = r.link;
      if (link != null && (best == null || link > best)) best = link;
    }
    return best;
  }

  Map<String, dynamic> toJson() => {
    'at': at.toIso8601String(),
    'lat': latitude,
    'lon': longitude,
    'replies': [for (final r in replies) r.toJson()],
    if (kind != WardriveKind.discovery) 'kind': kind.name,
    if (accuracy != null) 'acc': accuracy,
    if (noiseFloor != null) 'nf': noiseFloor,
  };

  factory WardrivePing.fromJson(Map<String, dynamic> j) => WardrivePing(
    at: DateTime.parse(j['at'] as String),
    latitude: (j['lat'] as num).toDouble(),
    longitude: (j['lon'] as num).toDouble(),
    replies: [
      for (final r in j['replies'] as List? ?? const [])
        WardriveReply.fromJson(Map<String, dynamic>.from(r as Map)),
    ],
    kind: WardriveKind.fromName(j['kind'] as String?),
    accuracy: (j['acc'] as num?)?.toDouble(),
    noiseFloor: (j['nf'] as num?)?.toInt(),
  );
}

/// One noise floor reading during a drive.
class NoiseSample {
  const NoiseSample(this.at, this.dbm);

  final DateTime at;
  final int dbm;

  Map<String, dynamic> toJson() => {'at': at.toIso8601String(), 'dbm': dbm};

  factory NoiseSample.fromJson(Map<String, dynamic> j) =>
      NoiseSample(DateTime.parse(j['at'] as String), (j['dbm'] as num).toInt());
}

/// One drive: its pings, in order, and its noise floor readings.
class WardriveSession {
  const WardriveSession({
    required this.id,
    required this.startedAt,
    this.endedAt,
    this.pings = const [],
    this.noise = const [],
  });

  final String id;
  final DateTime startedAt;
  final DateTime? endedAt;
  final List<WardrivePing> pings;
  final List<NoiseSample> noise;

  /// Pings that went out on the air.
  Iterable<WardrivePing> get sentPings => pings.where((p) => p.sent);

  int get sentCount => sentPings.length;
  int get heardCount => sentPings.where((p) => p.heard).length;
  int get skippedCount =>
      pings.where((p) => p.kind == WardriveKind.skipped).length;

  /// Distinct repeaters seen in this drive, by prefix.
  int get repeaterCount {
    final seen = <String>[];
    for (final p in pings) {
      for (final r in p.replies) {
        if (!seen.any(r.matches)) seen.add(r.prefix);
      }
    }
    return seen.length;
  }

  WardriveSession copyWith({
    DateTime? endedAt,
    List<WardrivePing>? pings,
    List<NoiseSample>? noise,
  }) => WardriveSession(
    id: id,
    startedAt: startedAt,
    endedAt: endedAt ?? this.endedAt,
    pings: pings ?? this.pings,
    noise: noise ?? this.noise,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'startedAt': startedAt.toIso8601String(),
    if (endedAt != null) 'endedAt': endedAt!.toIso8601String(),
    'pings': [for (final p in pings) p.toJson()],
    if (noise.isNotEmpty) 'noise': [for (final n in noise) n.toJson()],
  };

  factory WardriveSession.fromJson(Map<String, dynamic> j) => WardriveSession(
    id: j['id'] as String,
    startedAt: DateTime.parse(j['startedAt'] as String),
    endedAt: j['endedAt'] == null
        ? null
        : DateTime.parse(j['endedAt'] as String),
    pings: [
      for (final p in j['pings'] as List? ?? const [])
        WardrivePing.fromJson(Map<String, dynamic>.from(p as Map)),
    ],
    noise: [
      for (final n in j['noise'] as List? ?? const [])
        NoiseSample.fromJson(Map<String, dynamic>.from(n as Map)),
    ],
  );
}

/// A repeater's answer to the discover request tagged [tag], from a
/// PUSH_CODE_CONTROL_DATA frame:
/// `[code][snr×4][rssi][path len][type][snr there×4][tag u32][key prefix]`.
/// Null for anything else.
WardriveReply? parseDiscoverReply(Uint8List frame, int tag) {
  if (frame.length < 11 || frame[0] != pushCodeControlData) return null;
  final type = frame[4];
  if (((type >> 4) & 0x0F) != controlSubtypeDiscoverResp ||
      (type & 0x0F) != advTypeRepeater) {
    return null;
  }
  final data = ByteData.sublistView(frame);
  if (data.getUint32(6, Endian.little) != tag) return null;
  final prefix = frame.sublist(10);
  if (prefix.isEmpty) return null;
  return WardriveReply(
    prefix: _hex(prefix),
    snrThere: data.getInt8(5) / 4,
    snrHere: data.getInt8(1) / 4,
    rssiHere: data.getInt8(2),
  );
}

String _hex(List<int> bytes) =>
    bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

/// Mesh packet payload types this file reads.
const int _payloadAdvert = 0x04;
const int _payloadGroupText = 0x05;

/// The repeater this radio heard [raw] from directly, and whether that
/// repeater relayed it (as opposed to sending its own zero-hop advert).
/// Flood packets name the last repeater in their path; a zero-hop repeater
/// advert names its sender. Null for anything else, including direct-routed
/// packets, whose path is the route still ahead rather than hops taken.
String? directlyHeardRepeater(Uint8List raw) {
  final p = _parse(raw);
  if (p == null) return null;
  if (p.flood && p.hops > 0) {
    return _hex(p.path.sublist(p.path.length - p.width));
  }
  if (p.payloadType == _payloadAdvert &&
      p.hops == 0 &&
      p.payload.length > 100) {
    final flags = p.payload[100];
    if ((flags & 0x0F) == advTypeRepeater) return _hex(p.payload.sublist(0, 4));
  }
  return null;
}

/// For a group-text packet on the channel with hash [channelHash] that has
/// been repeated at least once: the repeater that first passed it on (the
/// first hop) and how many hops it had taken. Null otherwise.
({String firstHop, int hops})? channelEcho(Uint8List raw, int channelHash) {
  final p = _parse(raw);
  if (p == null || !p.flood || p.hops == 0) return null;
  if (p.payloadType != _payloadGroupText || p.payload.isEmpty) return null;
  if (p.payload[0] != channelHash) return null;
  return (firstHop: _hex(p.path.sublist(0, p.width)), hops: p.hops);
}

typedef _Packet = ({
  int payloadType,
  bool flood,
  int hops,
  int width,
  Uint8List path,
  Uint8List payload,
});

_Packet? _parse(Uint8List raw) {
  if (raw.length < 2) return null;
  final header = raw[0];
  final route = header & 0x03;
  var i = 1;
  if (route == 0 || route == 3) i += 4; // transport codes
  if (i >= raw.length) return null;
  final pathLen = raw[i++];
  final hops = pathLen == 0xFF ? 0 : pathLen & 0x3F;
  final width = pathLen == 0xFF ? 1 : ((pathLen >> 6) & 0x03) + 1;
  final end = i + hops * width;
  if (end > raw.length) return null;
  return (
    payloadType: (header >> 2) & 0x0F,
    flood: route == 0 || route == 1,
    hops: hops,
    width: width,
    path: Uint8List.sublistView(raw, i, end),
    payload: Uint8List.sublistView(raw, end),
  );
}
