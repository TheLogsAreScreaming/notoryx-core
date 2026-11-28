import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../connector/meshcore_connector.dart';
import '../connector/meshcore_protocol.dart';
import '../models/contact.dart';
import '../storage/prefs_manager.dart';

/// One map point for a TAK app.
@immutable
class TakPoint {
  final String uid;
  final String callsign;
  final String type;
  final double lat;
  final double lon;
  final String remarks;

  const TakPoint({
    required this.uid,
    required this.callsign,
    required this.type,
    required this.lat,
    required this.lon,
    required this.remarks,
  });
}

/// Sends the positions of MeshCore nodes this radio knows to a TAK app
/// (ATAK, iTAK, WinTAK) as Cursor-on-Target events over UDP, so they show
/// on its map. One way: nothing comes back from TAK.
///
/// Off until the person turns it on. Defaults to ATAK on the same phone
/// (127.0.0.1:4242, its local UDP input).
class TakFeedService extends ChangeNotifier {
  TakFeedService({
    required MeshCoreConnector Function() connector,
    Future<void> Function(String host, int port, List<List<int>> datagrams)?
    send,
    DateTime Function()? clock,
  }) : _connector = connector,
       _send = send ?? _udpSend,
       _clock = clock ?? DateTime.now;

  static const enabledKey = 'tak_feed_enabled';
  static const hostKey = 'tak_feed_host';
  static const portKey = 'tak_feed_port';
  static const defaultHost = '127.0.0.1';
  static const defaultPort = 4242;

  /// How often the points are sent, and how long TAK keeps one after.
  static const interval = Duration(seconds: 30);
  static const stale = Duration(minutes: 3);

  /// Nodes not heard for longer than this are left off the map.
  static const maxAge = Duration(hours: 24);

  final MeshCoreConnector Function() _connector;
  final Future<void> Function(String, int, List<List<int>>) _send;
  final DateTime Function() _clock;

  Timer? _timer;
  bool _enabled = false;
  String _host = defaultHost;
  int _port = defaultPort;
  int _lastSentCount = 0;
  DateTime? _lastSentAt;
  String? _lastError;

  bool get enabled => _enabled;
  String get host => _host;
  int get port => _port;
  int get lastSentCount => _lastSentCount;
  DateTime? get lastSentAt => _lastSentAt;
  String? get lastError => _lastError;

  /// Web builds can't send UDP.
  static bool get supported => !kIsWeb;

  void load() {
    final prefs = PrefsManager.instance;
    _host = prefs.getString(hostKey) ?? defaultHost;
    _port = prefs.getInt(portKey) ?? defaultPort;
    _enabled = supported && (prefs.getBool(enabledKey) ?? false);
    _schedule();
    notifyListeners();
  }

  Future<void> setEnabled(bool value) async {
    _enabled = supported && value;
    await PrefsManager.instance.setBool(enabledKey, _enabled);
    _schedule();
    notifyListeners();
    if (_enabled) await sendNow();
  }

  /// Sets where points go. Returns false (and changes nothing) for an empty
  /// host or a port outside 1-65535.
  Future<bool> setTarget(String host, int port) async {
    final h = host.trim();
    if (h.isEmpty || port < 1 || port > 65535) return false;
    _host = h;
    _port = port;
    await PrefsManager.instance.setString(hostKey, h);
    await PrefsManager.instance.setInt(portKey, port);
    notifyListeners();
    return true;
  }

  void _schedule() {
    _timer?.cancel();
    _timer = _enabled
        ? Timer.periodic(interval, (_) => unawaited(sendNow()))
        : null;
  }

  /// The points to send now: this radio and every node with a position
  /// heard in the last [maxAge].
  List<TakPoint> currentPoints() {
    final c = _connector();
    final now = _clock();
    final points = <TakPoint>[];
    final selfLat = c.selfLatitude;
    final selfLon = c.selfLongitude;
    final selfKey = c.selfPublicKeyHex;
    if (selfLat != null &&
        selfLon != null &&
        (selfLat != 0 || selfLon != 0) &&
        selfKey.isNotEmpty) {
      points.add(
        TakPoint(
          uid: uidFor(selfKey),
          callsign: c.selfName ?? 'My radio',
          type: 'a-f-G-U-C',
          lat: selfLat,
          lon: selfLon,
          remarks: 'MeshCore: this radio',
        ),
      );
    }
    for (final contact in c.allContactsUnfiltered) {
      if (!contact.hasLocation) continue;
      if (now.difference(contact.lastSeen) > maxAge) continue;
      points.add(pointFor(contact, now));
    }
    return points;
  }

  static String uidFor(String publicKeyHex) =>
      'MESHCORE-${publicKeyHex.substring(0, publicKeyHex.length.clamp(0, 16)).toUpperCase()}';

  static TakPoint pointFor(Contact contact, DateTime now) {
    final (type, kind) = switch (contact.type) {
      advTypeRepeater => ('a-f-G-I-U-T', 'repeater'),
      advTypeRoom => ('a-f-G-I-B', 'room server'),
      advTypeSensor => ('a-f-G-E-S', 'sensor'),
      _ => ('a-f-G-U-C', 'companion'),
    };
    final minutes = now.difference(contact.lastSeen).inMinutes;
    final heard = minutes < 1
        ? 'heard just now'
        : minutes < 120
        ? 'heard $minutes min ago'
        : 'heard ${minutes ~/ 60} h ago';
    return TakPoint(
      uid: uidFor(contact.publicKeyHex),
      callsign: contact.name.isEmpty
          ? contact.publicKeyHex.substring(0, 8)
          : contact.name,
      type: type,
      lat: contact.latitude!,
      lon: contact.longitude!,
      remarks: 'MeshCore $kind, $heard',
    );
  }

  /// One Cursor-on-Target event for [p].
  static String cotXml(
    TakPoint p,
    DateTime now, {
    Duration staleAfter = stale,
  }) {
    String t(DateTime d) => d.toUtc().toIso8601String();
    return '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
        '<event version="2.0" uid="${_esc(p.uid)}" type="${_esc(p.type)}" '
        'how="m-g" time="${t(now)}" start="${t(now)}" '
        'stale="${t(now.add(staleAfter))}">'
        '<point lat="${p.lat.toStringAsFixed(6)}" '
        'lon="${p.lon.toStringAsFixed(6)}" '
        'hae="9999999.0" ce="9999999.0" le="9999999.0"/>'
        '<detail><contact callsign="${_esc(p.callsign)}"/>'
        '<remarks>${_esc(p.remarks)}</remarks></detail></event>';
  }

  static String _esc(String s) => s
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&apos;');

  /// Sends the current points once.
  Future<void> sendNow() async {
    if (!_enabled) return;
    final now = _clock();
    final points = currentPoints();
    try {
      await _send(_host, _port, [
        for (final p in points) utf8.encode(cotXml(p, now)),
      ]);
      _lastSentCount = points.length;
      _lastSentAt = now;
      _lastError = null;
    } catch (e) {
      _lastError = '$e';
    }
    notifyListeners();
  }

  static Future<void> _udpSend(
    String host,
    int port,
    List<List<int>> datagrams,
  ) async {
    if (datagrams.isEmpty) return;
    final addresses = await InternetAddress.lookup(host);
    if (addresses.isEmpty) throw StateError('No address for $host');
    final target = addresses.first;
    final socket = await RawDatagramSocket.bind(
      target.type == InternetAddressType.IPv6
          ? InternetAddress.anyIPv6
          : InternetAddress.anyIPv4,
      0,
    );
    try {
      for (final d in datagrams) {
        socket.send(d, target, port);
      }
    } finally {
      socket.close();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
