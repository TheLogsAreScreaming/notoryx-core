import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

import '../models/contact.dart';
import '../models/radio_rx_packet.dart';
import '../models/traffic_route.dart';
import '../services/rx_log_service.dart';

/// Turns packets the radio hears into routes for the live traffic map.
/// Lives only while the map's Traffic mode is on; nothing is stored.
class TrafficController extends ChangeNotifier {
  TrafficController({
    required Stream<RadioRxPacket> packets,
    required this.contacts,
    required this.selfPosition,
    required this.selfLabel,
    this.channelSender,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now {
    _subscription = packets.listen(add);
  }

  final List<Contact> Function() contacts;
  final LatLng? Function() selfPosition;
  final String Function() selfLabel;

  /// Where a channel message with this packet hash started, when the app
  /// can tell from the decoded message's sender.
  final TrafficHop? Function(String packetHash)? channelSender;
  final DateTime Function() _clock;
  late final StreamSubscription<RadioRxPacket> _subscription;

  final TrafficQueue queue = TrafficQueue();
  Set<TrafficKind> _shown = TrafficKind.values.toSet();
  TrafficRoute? _latest;
  RxLogEntry? _latestEntry;

  /// With reduce motion on, routes are drawn at once and fade.
  bool reduceMotion = false;

  /// The newest packet shown, for the route card.
  TrafficRoute? get latest => _latest;

  /// The raw packet behind [latest], for the packet details sheet.
  RxLogEntry? get latestEntry => _latestEntry;

  /// Packet types drawn on the map.
  Set<TrafficKind> get shown => Set.unmodifiable(_shown);

  set shown(Set<TrafficKind> kinds) {
    if (setEquals(kinds, _shown)) return;
    _shown = kinds.toSet();
    if (_latest != null && !_shown.contains(_latest!.kind)) {
      _latest = null;
      _latestEntry = null;
    }
    notifyListeners();
  }

  DateTime now() => _clock();

  /// Adds one heard packet.
  @visibleForTesting
  void add(RadioRxPacket packet) {
    final entry = RxLogEntry.from(packet);
    if (entry == null) return;
    if (!_shown.contains(trafficKindFor(entry.kind))) return;
    // A flood is heard once per repeater in range. Later copies can add a
    // branch to the map, but the card keeps the first one.
    final repeat = entry.info.hash == _latest?.packetHash;
    final route = buildTrafficRoute(
      entry,
      contacts: contacts(),
      selfPosition: selfPosition(),
      selfLabel: selfLabel(),
      sender: entry.kind == RxKind.channel
          ? channelSender?.call(entry.info.hash)
          : null,
    );
    if (!repeat) {
      _latest = route;
      _latestEntry = entry;
    }
    final taken = queue.add(route, _clock(), reduceMotion: reduceMotion);
    if (taken || !repeat) notifyListeners();
  }

  @override
  void dispose() {
    unawaited(_subscription.cancel());
    super.dispose();
  }
}
