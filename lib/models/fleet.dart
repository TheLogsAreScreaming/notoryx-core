import 'package:flutter/foundation.dart';

import 'firmware_release.dart';

/// A repeater the user owns and wants to watch in Fleet.
@immutable
class FleetRepeater {
  const FleetRepeater({
    required this.publicKeyHex,
    required this.name,
    required this.addedAt,
    this.stationId,
  });

  /// 64 lowercase hex characters.
  final String publicKeyHex;
  final String name;
  final DateTime addedAt;

  /// The id this repeater has on a synced station, when it has one.
  final int? stationId;

  static final _keyPattern = RegExp(r'^[0-9a-f]{64}$');

  /// Whether [key] is a full 32-byte public key in hex.
  static bool isValidKey(String key) =>
      _keyPattern.hasMatch(key.trim().toLowerCase());

  /// The key in [text] with spaces, colons and dashes removed, or null.
  static String? normalizeKey(String text) {
    final key = text.replaceAll(RegExp(r'[\s:\-]'), '').toLowerCase();
    return isValidKey(key) ? key : null;
  }

  FleetRepeater copyWith({String? name, int? stationId}) => FleetRepeater(
    publicKeyHex: publicKeyHex,
    name: name ?? this.name,
    addedAt: addedAt,
    stationId: stationId ?? this.stationId,
  );

  Map<String, Object> toJson() => {
    'key': publicKeyHex,
    'name': name,
    'added': addedAt.millisecondsSinceEpoch,
    'sid': ?stationId,
  };

  static FleetRepeater? fromJson(Object? json) {
    if (json is! Map) return null;
    final key = json['key'], name = json['name'], added = json['added'];
    if (key is! String || !isValidKey(key) || name is! String) return null;
    final sid = json['sid'];
    return FleetRepeater(
      publicKeyHex: key.toLowerCase(),
      name: name,
      addedAt: DateTime.fromMillisecondsSinceEpoch(added is int ? added : 0),
      stationId: sid is int ? sid : null,
    );
  }
}

/// Where a [FleetSample] came from.
enum FleetSource { phone, station }

/// One poll of one repeater: what came back, or why nothing did.
@immutable
class FleetSample {
  const FleetSample({
    required this.at,
    required this.ok,
    this.source = FleetSource.phone,
    this.error,
    this.batteryMv,
    this.noiseFloor,
    this.lastRssi,
    this.lastSnr,
    this.uptimeSecs,
    this.firmware,
    this.neighbours,
  });

  final DateTime at;
  final bool ok;
  final FleetSource source;

  /// A short machine code such as `timeout`, `login`, `no_contact`.
  final String? error;
  final int? batteryMv;
  final int? noiseFloor;
  final int? lastRssi;
  final double? lastSnr;
  final int? uptimeSecs;
  final String? firmware;
  final int? neighbours;

  Map<String, Object> toJson() => {
    'at': at.millisecondsSinceEpoch,
    'ok': ok,
    if (source == FleetSource.station) 'src': 's',
    'err': ?error,
    'mv': ?batteryMv,
    'nf': ?noiseFloor,
    'rssi': ?lastRssi,
    'snr': ?lastSnr,
    'up': ?uptimeSecs,
    'fw': ?firmware,
    'nb': ?neighbours,
  };

  static FleetSample? fromJson(Object? json) {
    if (json is! Map) return null;
    final at = json['at'];
    if (at is! int) return null;
    int? i(Object? v) => v is int ? v : null;
    String? s(Object? v) => v is String ? v : null;
    final snr = json['snr'];
    return FleetSample(
      at: DateTime.fromMillisecondsSinceEpoch(at),
      ok: json['ok'] == true,
      source: json['src'] == 's' ? FleetSource.station : FleetSource.phone,
      error: s(json['err']),
      batteryMv: i(json['mv']),
      noiseFloor: i(json['nf']),
      lastRssi: i(json['rssi']),
      lastSnr: snr is num ? snr.toDouble() : null,
      uptimeSecs: i(json['up']),
      firmware: s(json['fw']),
      neighbours: i(json['nb']),
    );
  }
}

/// The latest known value of each health field, gathered from the newest
/// samples (a poll that skipped firmware still shows the last firmware).
@immutable
class FleetHealth {
  const FleetHealth({
    this.batteryMv,
    this.noiseFloor,
    this.lastSnr,
    this.uptimeSecs,
    this.firmware,
    this.neighbours,
    this.lastHeard,
    this.lastPoll,
  });

  final int? batteryMv;
  final int? noiseFloor;
  final double? lastSnr;
  final int? uptimeSecs;
  final String? firmware;
  final int? neighbours;

  /// When the repeater last answered (or was heard advertising).
  final DateTime? lastHeard;

  /// The newest poll, answered or not.
  final FleetSample? lastPoll;

  /// Builds the health from [samples] (any order) and the time the radio
  /// last heard the repeater's advert, if known.
  factory FleetHealth.from(List<FleetSample> samples, {DateTime? advertAt}) {
    final sorted = [...samples]..sort((a, b) => b.at.compareTo(a.at));
    int? mv, nf, up, nb;
    double? snr;
    String? fw;
    DateTime? heard = advertAt;
    for (final s in sorted) {
      if (!s.ok) continue;
      if (heard == null || s.at.isAfter(heard)) heard = s.at;
      mv ??= s.batteryMv;
      nf ??= s.noiseFloor;
      up ??= s.uptimeSecs;
      nb ??= s.neighbours;
      snr ??= s.lastSnr;
      fw ??= s.firmware;
    }
    return FleetHealth(
      batteryMv: mv,
      noiseFloor: nf,
      lastSnr: snr,
      uptimeSecs: up,
      firmware: fw,
      neighbours: nb,
      lastHeard: heard,
      lastPoll: sorted.isEmpty ? null : sorted.first,
    );
  }
}

/// The pill on a repeater's health card, worst first.
enum FleetStatus { quiet, lowBattery, firmwareBehind, healthy, unknown }

/// Thresholds for [fleetStatusFor]; they match the station's defaults.
abstract final class FleetThresholds {
  /// Below this the battery is low.
  static const lowBatteryMv = 3600;

  /// Not heard for longer than this means quiet.
  static const quietAfter = Duration(hours: 3);
}

/// Picks the status pill for [health] at [now]. [newestFirmware] is the
/// newest firmware seen across the fleet; a repeater on an older one is
/// behind.
FleetStatus fleetStatusFor(
  FleetHealth health, {
  required DateTime now,
  FirmwareVersion? newestFirmware,
}) {
  final heard = health.lastHeard;
  if (heard == null) {
    return health.lastPoll == null ? FleetStatus.unknown : FleetStatus.quiet;
  }
  if (now.difference(heard) > FleetThresholds.quietAfter) {
    return FleetStatus.quiet;
  }
  final mv = health.batteryMv;
  if (mv != null && mv > 0 && mv < FleetThresholds.lowBatteryMv) {
    return FleetStatus.lowBattery;
  }
  final fw = FirmwareVersion.parse(health.firmware);
  if (fw != null && newestFirmware != null && fw < newestFirmware) {
    return FleetStatus.firmwareBehind;
  }
  return FleetStatus.healthy;
}

/// The newest firmware among [firmwares], or null.
FirmwareVersion? newestFirmwareOf(Iterable<String?> firmwares) {
  FirmwareVersion? best;
  for (final f in firmwares) {
    final v = FirmwareVersion.parse(f);
    if (v != null && (best == null || best < v)) best = v;
  }
  return best;
}

/// The settings Fleet may push to several repeaters at once, with the shape
/// each value must have. Names follow the repeater command line.
const Map<String, String> fleetBulkSettings = {
  'advert.interval': r'^\d{1,4}$',
  'flood.advert.interval': r'^\d{1,3}$',
  'flood.max': r'^\d{1,2}$',
  'txdelay': r'^\d+(\.\d+)?$',
  'direct.txdelay': r'^\d+(\.\d+)?$',
  'rxdelay': r'^\d+(\.\d+)?$',
  'af': r'^\d+(\.\d+)?$',
  'repeat': r'^(on|off)$',
  'allow.read.only': r'^(on|off)$',
};

/// Whether [key] = [value] may be sent by bulk settings.
bool isAllowedBulkSetting(String key, String value) {
  final pattern = fleetBulkSettings[key];
  if (pattern == null) return false;
  return RegExp(pattern).hasMatch(value.trim());
}

/// The value in a repeater's reply to `get <key>`: `> 300` or `-> 300`.
String parseGetReply(String reply) {
  final t = reply.trim();
  for (final p in const ['->', '>']) {
    if (t.startsWith(p)) return t.substring(p.length).trim();
  }
  return t;
}

/// One row of a bulk change preview.
@immutable
class FleetSettingDiff {
  const FleetSettingDiff({
    required this.repeater,
    required this.current,
    required this.target,
    this.error,
  });

  final FleetRepeater repeater;

  /// The value read with `get`, or null when it couldn't be read.
  final String? current;
  final String target;
  final String? error;

  /// Whether a `set` would change anything. Unreadable values count as a
  /// change so the user can still choose to send them.
  bool get changes => current == null || current!.trim() != target.trim();
}

/// What a binary status reply carries (REQ_TYPE_GET_STATUS, 52 bytes after
/// an 8-byte header). Null when [frame] is too short.
({
  int batteryMv,
  int noiseFloor,
  int lastRssi,
  double lastSnr,
  int uptimeSecs,
  int errors,
})?
parseRepeaterStatusFrame(Uint8List frame) {
  const offset = 8, size = 52;
  if (frame.length < offset + size) return null;
  final d = ByteData.sublistView(frame, offset, offset + size);
  return (
    batteryMv: d.getUint16(0, Endian.little),
    noiseFloor: d.getInt16(4, Endian.little),
    lastRssi: d.getInt16(6, Endian.little),
    uptimeSecs: d.getUint32(20, Endian.little),
    errors: d.getUint16(40, Endian.little),
    lastSnr: d.getInt16(42, Endian.little) / 4.0,
  );
}
