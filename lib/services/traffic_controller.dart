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
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now {
    _subscription = packets.listen(add);
  }

  final List<Contact> Function() contacts;
  final LatLng? Function() selfPosition;
  final String Function() selfLabel;
  final DateTime Function() _clock;
  late final StreamSubscription<RadioRxPacket> _subscription;

  final TrafficQueue queue = TrafficQueue();
  Set<TrafficKind> _shown = TrafficKind.values.toSet();
  TrafficRoute? _latest;

  /// With reduce motion on, routes are drawn at once and fade.
  bool reduceMotion = false;

  /// The newest packet shown, for the route card.
  TrafficRoute? get latest => _latest;

  /// Packet types drawn on the map.
  Set<TrafficKind> get shown => Set.unmodifiable(_shown);

  set shown(Set<TrafficKind> kinds) {
    if (setEquals(kinds, _shown)) return;
    _shown = kinds.toSet();
    if (_latest != null && !_shown.contains(_latest!.kind)) _latest = null;
    notifyListeners();
  }

  DateTime now() => _clock();

  /// Adds one heard packet.
  @visibleForTesting
  void add(RadioRxPacket packet) {
    final entry = RxLogEntry.from(packet);
    if (entry == null) return;
    if (!_shown.contains(trafficKindFor(entry.kind))) return;
    // A flood is heard once per repeater in range; keep the first copy.
    if (entry.info.hash == _latest?.packetHash) return;
    final route = buildTrafficRoute(
      entry,
      contacts: contacts(),
      selfPosition: selfPosition(),
      selfLabel: selfLabel(),
    );
    _latest = route;
    queue.add(route, _clock(), reduceMotion: reduceMotion);
    notifyListeners();
  }

  @override
  void dispose() {
    unawaited(_subscription.cancel());
    super.dispose();
  }
}
