import 'dart:async';

import 'package:bonsoir/bonsoir.dart';
import 'package:flutter/foundation.dart';

/// A MeshCore Wi-Fi companion found on the local network.
@immutable
class FoundCompanion {
  /// The node name the radio advertises, or its mDNS name.
  final String name;

  /// An IP address to connect to.
  final String host;
  final int port;

  /// Firmware version from the advert, when given.
  final String? firmwareVersion;

  const FoundCompanion({
    required this.name,
    required this.host,
    required this.port,
    this.firmwareVersion,
  });

  String get endpoint => host.contains(':') ? '[$host]:$port' : '$host:$port';

  @override
  bool operator ==(Object other) =>
      other is FoundCompanion &&
      other.name == name &&
      other.host == host &&
      other.port == port;

  @override
  int get hashCode => Object.hash(name, host, port);
}

/// Finds MeshCore companions advertising themselves over mDNS
/// (`_meshcore._tcp`, with `node-name` and `firmware-version` TXT entries).
abstract class CompanionFinder {
  /// The mDNS service type companion firmware advertises.
  static const serviceType = '_meshcore._tcp';

  /// Whether this platform can look at all (not on the web).
  bool get supported;

  /// Companions found so far; a new list each time one appears or goes.
  /// Searching starts on listen and stops when the last listener cancels.
  Stream<List<FoundCompanion>> watch();

  /// The platform finder.
  factory CompanionFinder() = _BonsoirCompanionFinder;

  /// What a resolved advert says, or null when it has no usable address.
  static FoundCompanion? fromAdvert({
    required String serviceName,
    required List<String> addresses,
    required int port,
    required Map<String, String> attributes,
  }) {
    if (port <= 0 || port > 65535) return null;
    // Prefer IPv4: it's what people expect to see, and link-local IPv6
    // needs a zone id many sockets won't take.
    final v4 = addresses.where((a) => !a.contains(':'));
    final host = v4.isNotEmpty
        ? v4.first
        : addresses
              .where((a) => !a.toLowerCase().startsWith('fe80'))
              .firstOrNull;
    if (host == null || host.isEmpty) return null;
    final nodeName = attributes['node-name']?.trim();
    final firmware = attributes['firmware-version']?.trim();
    return FoundCompanion(
      name: nodeName != null && nodeName.isNotEmpty ? nodeName : serviceName,
      host: host,
      port: port,
      firmwareVersion: firmware != null && firmware.isNotEmpty
          ? firmware
          : null,
    );
  }
}

class _BonsoirCompanionFinder implements CompanionFinder {
  @override
  bool get supported => !kIsWeb;

  @override
  Stream<List<FoundCompanion>> watch() {
    late final StreamController<List<FoundCompanion>> out;
    BonsoirDiscovery? discovery;
    StreamSubscription<BonsoirDiscoveryEvent>? events;
    final found = <String, FoundCompanion>{};

    void emit() {
      if (!out.isClosed) out.add(found.values.toList(growable: false));
    }

    Future<void> start() async {
      try {
        final d = BonsoirDiscovery(type: CompanionFinder.serviceType);
        discovery = d;
        await d.initialize();
        events = d.eventStream?.listen((event) {
          switch (event) {
            case BonsoirDiscoveryServiceFoundEvent():
              d.serviceResolver.resolveService(event.service);
            case BonsoirDiscoveryServiceResolvedEvent():
            case BonsoirDiscoveryServiceUpdatedEvent():
              final s = event.service!;
              final companion = CompanionFinder.fromAdvert(
                serviceName: s.name,
                addresses: s.hostAddresses,
                port: s.port,
                attributes: s.attributes,
              );
              if (companion != null) {
                found[s.name] = companion;
                emit();
              }
            case BonsoirDiscoveryServiceLostEvent():
              if (found.remove(event.service.name) != null) emit();
            default:
              break;
          }
        });
        await d.start();
        emit();
      } catch (e) {
        if (!out.isClosed) out.addError(e);
      }
    }

    out = StreamController<List<FoundCompanion>>(
      onListen: () => unawaited(start()),
      onCancel: () async {
        await events?.cancel();
        try {
          await discovery?.stop();
        } catch (_) {}
      },
    );
    return out.stream;
  }
}
