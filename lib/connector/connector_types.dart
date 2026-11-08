import 'package:flutter/foundation.dart';

class DirectRepeater {
  static const int maxAgeMinutes = 30; // Max age for direct repeater info
  List<int> pubkeyPrefix;
  int pathHashWidth;
  String? contactKeyHex;
  double snr;
  DateTime lastUpdated;

  DirectRepeater({
    required List<int> pubkeyPrefix,
    required this.pathHashWidth,
    this.contactKeyHex,
    required this.snr,
    DateTime? lastUpdated,
  }) : pubkeyPrefix = List.unmodifiable(pubkeyPrefix),
       lastUpdated = lastUpdated ?? DateTime.now();

  String get pubkeyPrefixHex => pubkeyPrefix
      .map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase())
      .join();

  bool matchesPrefix(List<int> prefix) {
    return pubkeyPrefix.length == prefix.length &&
        listEquals(pubkeyPrefix, prefix);
  }

  bool matchesPathStart(List<int> pathBytes, int pathHashByteWidth) {
    final width = pathHashByteWidth.clamp(1, 4).toInt();
    if (pathBytes.length < width || pubkeyPrefix.length != width) {
      return false;
    }
    return listEquals(pubkeyPrefix, pathBytes.sublist(0, width));
  }

  void update(
    double newSNR, {
    List<int>? pubkeyPrefix,
    int? pathHashWidth,
    String? contactKeyHex,
  }) {
    snr = newSNR;
    if (pubkeyPrefix != null &&
        pubkeyPrefix.length >= this.pubkeyPrefix.length) {
      this.pubkeyPrefix = List.unmodifiable(pubkeyPrefix);
    }
    if (pathHashWidth != null && pathHashWidth >= this.pathHashWidth) {
      this.pathHashWidth = pathHashWidth;
    }
    this.contactKeyHex ??= contactKeyHex;
    lastUpdated = DateTime.now();
  }

  int get ranking {
    if (isStale()) {
      return -1; // Stale repeaters get lowest rank
    }
    // Higher SNR gets higher rank and recency within maxAgeMinutes breaks ties.
    final ageMs =
        DateTime.now().millisecondsSinceEpoch -
        lastUpdated.millisecondsSinceEpoch;
    final maxAgeMs = maxAgeMinutes * 60 * 1000;
    final recencyScore = (maxAgeMs - ageMs).clamp(0, maxAgeMs);
    return ((snr - 31.75) * 1000).round() + recencyScore;
  }

  bool isStale() {
    return DateTime.now().difference(lastUpdated) >
        const Duration(minutes: maxAgeMinutes);
  }
}

enum MeshCoreConnectionState {
  disconnected,
  scanning,
  connecting,
  connected,
  disconnecting,
}

enum MeshCoreTransportType { bluetooth, usb, tcp }

/// A wired or network link to reconnect to after it drops: the TCP endpoint
/// or USB port of the last connect that succeeded. Bluetooth reconnects use
/// the remembered device instead.
@immutable
sealed class LinkTarget {
  const LinkTarget();
  MeshCoreTransportType get transport;
}

final class TcpLinkTarget extends LinkTarget {
  const TcpLinkTarget(this.host, this.port);
  final String host;
  final int port;
  @override
  MeshCoreTransportType get transport => MeshCoreTransportType.tcp;
  @override
  bool operator ==(Object other) =>
      other is TcpLinkTarget && other.host == host && other.port == port;
  @override
  int get hashCode => Object.hash(host, port);
}

final class UsbLinkTarget extends LinkTarget {
  const UsbLinkTarget(this.portName, this.baudRate);
  final String portName;
  final int baudRate;
  @override
  MeshCoreTransportType get transport => MeshCoreTransportType.usb;
  @override
  bool operator ==(Object other) =>
      other is UsbLinkTarget &&
      other.portName == portName &&
      other.baudRate == baudRate;
  @override
  int get hashCode => Object.hash(portName, baudRate);
}

class RepeaterBatterySnapshot {
  final int millivolts;
  final DateTime updatedAt;
  final String source;

  const RepeaterBatterySnapshot({
    required this.millivolts,
    required this.updatedAt,
    required this.source,
  });
}

class MeshCoreRadioStateSnapshot {
  final int freqHz;
  final int bwHz;
  final int sf;
  final int cr;
  final int txPowerDbm;

  const MeshCoreRadioStateSnapshot({
    required this.freqHz,
    required this.bwHz,
    required this.sf,
    required this.cr,
    required this.txPowerDbm,
  });
}

class BlockedRemoteCommand {
  final String? contactKey;
  final String name;
  final String command;
  final DateTime at;
  const BlockedRemoteCommand({
    required this.contactKey,
    required this.name,
    required this.command,
    required this.at,
  });
}
