import 'package:flutter_test/flutter_test.dart';
import 'package:meshcore_open/connector/reconnect_policy.dart';
import 'package:meshcore_open/connector/tx_backoff.dart';

void main() {
  test('reconnect delays double, capped at 30 s', () {
    expect(
      [for (var i = 0; i < 9; i++) reconnectDelayMs(i)],
      [1000, 2000, 4000, 8000, 16000, 30000, 30000, 30000, 30000],
    );
  });

  int run(double nf, double snr, double busy) => txBackoffTargetMs(
    noiseFloorDbm: nf,
    lastSnrDb: snr,
    airBusy: busy,
    minMs: 500,
    maxMs: 15000,
  );

  test('a quiet, clear channel waits the minimum', () {
    expect(run(-120, 15, 0), 500);
  });
  test('a noisy channel, or a weak signal, waits longer', () {
    expect(run(-88, 15, 0), 500 + (0.82 * 14500).round());
    expect(run(-120, -2, 0), 500 + (0.82 * 14500).round());
  });
  test('worst case waits the maximum', () {
    expect(run(-80, -10, 1), 15000);
  });
  test('recent airtime adds a smaller share', () {
    expect(run(-120, 15, 1), 500 + (0.18 * 14500).round());
  });
}
