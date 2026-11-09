import 'dart:convert';
import 'dart:io' show gzip;
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart' show listEquals;

import 'channel.dart';
import 'waypoint.dart';

/// Radio settings, in the units the radio itself reports.
class TeamRadioSettings {
  const TeamRadioSettings({
    required this.freq,
    required this.bandwidth,
    required this.spreadingFactor,
    required this.codingRate,
    this.txPower,
  });

  final int freq;
  final int bandwidth;
  final int spreadingFactor;
  final int codingRate;
  final int? txPower;
}

class TeamChannel {
  const TeamChannel(this.name, this.psk);
  final String name;
  final Uint8List psk;
}

/// What one team member hands to another.
class TeamConfig {
  const TeamConfig({
    this.radio,
    this.channels = const [],
    this.waypoints = const [],
    this.routes = const [],
  });

  final TeamRadioSettings? radio;
  final List<TeamChannel> channels;
  final List<Waypoint> waypoints;
  final List<WaypointRoute> routes;

  Map<String, Object?> toJson() => {
    if (radio case final r?)
      'r': [r.freq, r.bandwidth, r.spreadingFactor, r.codingRate, r.txPower],
    if (channels.isNotEmpty)
      'c': [
        for (final c in channels) [c.name, base64Encode(c.psk)],
      ],
    if (waypoints.isNotEmpty) 'w': [for (final w in waypoints) w.toJson()],
    if (routes.isNotEmpty) 'p': [for (final r in routes) r.toJson()],
  };

  /// Throws [FormatException] rather than accept a malformed value.
  factory TeamConfig.fromJson(Map<String, dynamic> j) {
    try {
      final r = j['r'] as List<dynamic>?;
      return TeamConfig(
        radio: r == null
            ? null
            : TeamRadioSettings(
                freq: r[0] as int,
                bandwidth: r[1] as int,
                spreadingFactor: r[2] as int,
                codingRate: r[3] as int,
                txPower: r[4] as int?,
              ),
        channels: [
          for (final c in j['c'] as List<dynamic>? ?? const [])
            _channel(c as List<dynamic>),
        ],
        waypoints: [
          for (final w in j['w'] as List<dynamic>? ?? const [])
            ?Waypoint.fromJson(w as Map<String, dynamic>),
        ],
        routes: [
          for (final p in j['p'] as List<dynamic>? ?? const [])
            ?WaypointRoute.fromJson(p as Map<String, dynamic>),
        ],
      );
    } on TypeError {
      throw const FormatException('This team file is damaged.');
    } on RangeError {
      throw const FormatException('This team file is damaged.');
    }
  }

  static TeamChannel _channel(List<dynamic> c) {
    final psk = base64Decode(c[1] as String);
    if (psk.length != 16) {
      throw const FormatException('This team file has a bad channel key.');
    }
    return TeamChannel(c[0] as String, psk);
  }
}

/// Which empty radio slot each new channel goes in. Channels the radio
/// already has (same key) are skipped, and slot 0, the public channel, is
/// never used. Channels that don't fit are left out.
Map<int, TeamChannel> planChannelSlots(
  List<Channel> existing,
  List<TeamChannel> incoming,
  int maxChannels,
) {
  final used = {
    for (final c in existing)
      if (c.name.isNotEmpty) c.index,
    0,
  };
  final keys = [
    for (final c in existing)
      if (c.name.isNotEmpty) c.psk,
  ];
  final plan = <int, TeamChannel>{};
  var slot = 1;
  for (final channel in incoming) {
    if (keys.any((k) => listEquals(k, channel.psk))) continue;
    while (used.contains(slot)) {
      slot++;
    }
    if (slot >= maxChannels) break;
    plan[slot] = channel;
    used.add(slot);
    keys.add(channel.psk);
  }
  return plan;
}

const _format = 'notoryx-team';
const _iterations = 310000;
const minTeamPassphrase = 12;

/// The shared text form of a [TeamConfig]: always encrypted, because it
/// holds channel keys and anyone who sees it could read those channels.
Future<String> sealTeamConfig(TeamConfig config, String passphrase) async {
  if (passphrase.length < minTeamPassphrase) {
    throw const FormatException('Use at least 12 characters.');
  }
  final salt = SecretKeyData.random(length: 16).bytes;
  final key = await _key(passphrase, salt);
  final box = await AesGcm.with256bits().encrypt(
    gzip.encode(utf8.encode(jsonEncode(config.toJson()))),
    secretKey: key,
    aad: utf8.encode(_format),
  );
  return '$_format:1:${base64Url.encode([...salt, ...box.nonce, ...box.mac.bytes, ...box.cipherText])}';
}

/// Opens [sealed]. Throws [FormatException] for anything not a team file
/// and [SecretBoxAuthenticationError] for a wrong passphrase or tampering.
Future<TeamConfig> openTeamConfig(String sealed, String passphrase) async {
  final text = sealed.trim();
  if (!text.startsWith('$_format:1:') || text.length > 1024 * 1024) {
    throw const FormatException('This is not a NOTORYX team file.');
  }
  final bytes = base64Url.decode(text.substring(_format.length + 3));
  if (bytes.length < 44) {
    throw const FormatException('This team file is damaged.');
  }
  final key = await _key(passphrase, bytes.sublist(0, 16));
  final plain = await AesGcm.with256bits().decrypt(
    SecretBox(
      bytes.sublist(44),
      nonce: bytes.sublist(16, 28),
      mac: Mac(bytes.sublist(28, 44)),
    ),
    secretKey: key,
    aad: utf8.encode(_format),
  );
  final decoded = jsonDecode(utf8.decode(gzip.decode(plain)));
  if (decoded is! Map<String, dynamic>) {
    throw const FormatException('This team file is damaged.');
  }
  return TeamConfig.fromJson(decoded);
}

Future<SecretKey> _key(String passphrase, List<int> salt) => Pbkdf2(
  macAlgorithm: Hmac.sha256(),
  iterations: _iterations,
  bits: 256,
).deriveKey(secretKey: SecretKey(utf8.encode(passphrase)), nonce: salt);
