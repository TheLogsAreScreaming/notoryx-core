import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/radio_rx_packet.dart';

/// Accumulates RSSI and SNR statistics from every [RadioRxPacket] received
/// since the app started. Stats reset only on a cold restart.
class RxSignalStatsService extends ChangeNotifier {
  RxSignalStatsService(Stream<RadioRxPacket> packets) {
    _sub = packets.listen(_onPacket);
  }

  late final StreamSubscription<RadioRxPacket> _sub;

  int _count = 0;
  int _rssiMin = 0;
  int _rssiMax = 0;
  double _rssiSum = 0;
  double _snrMin = 0;
  double _snrMax = 0;
  double _snrSum = 0;
  Timer? _notifyTimer;

  int get count => _count;

  int? get rssiMin => _count == 0 ? null : _rssiMin;
  int? get rssiMax => _count == 0 ? null : _rssiMax;
  double? get rssiAvg => _count == 0 ? null : _rssiSum / _count;

  double? get snrMin => _count == 0 ? null : _snrMin;
  double? get snrMax => _count == 0 ? null : _snrMax;
  double? get snrAvg => _count == 0 ? null : _snrSum / _count;

  void _onPacket(RadioRxPacket p) {
    if (_count == 0) {
      _rssiMin = p.rssi;
      _rssiMax = p.rssi;
      _rssiSum = p.rssi.toDouble();
      _snrMin = p.snr;
      _snrMax = p.snr;
      _snrSum = p.snr;
    } else {
      if (p.rssi < _rssiMin) _rssiMin = p.rssi;
      if (p.rssi > _rssiMax) _rssiMax = p.rssi;
      _rssiSum += p.rssi;
      if (p.snr < _snrMin) _snrMin = p.snr;
      if (p.snr > _snrMax) _snrMax = p.snr;
      _snrSum += p.snr;
    }
    _count++;
    _notifyTimer ??= Timer(const Duration(milliseconds: 500), () {
      _notifyTimer = null;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _sub.cancel();
    _notifyTimer?.cancel();
    super.dispose();
  }
}
