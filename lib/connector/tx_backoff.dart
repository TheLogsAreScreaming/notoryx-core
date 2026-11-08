import 'dart:math' as math;

/// How long to hold a send after inbound traffic, from [minMs] on a quiet
/// channel to [maxMs] on a noisy one. Scales with the worse of noise floor
/// and last SNR, plus a smaller share for recent airtime ([airBusy], 0–1).
int txBackoffTargetMs({
  required double noiseFloorDbm,
  required double lastSnrDb,
  required double airBusy,
  required int minMs,
  required int maxMs,
}) {
  // Quieter (more negative) → lower score; noisier → higher.
  const noiseQuietDbm = -118.0;
  const noiseNoisyDbm = -88.0;
  final noiseT =
      ((noiseFloorDbm - noiseQuietDbm) / (noiseNoisyDbm - noiseQuietDbm)).clamp(
        0.0,
        1.0,
      );
  const snrGood = 12.0;
  const snrBad = -2.0;
  final snrT = (1.0 - ((lastSnrDb - snrBad) / (snrGood - snrBad))).clamp(
    0.0,
    1.0,
  );
  final severity = (math.max(noiseT, snrT) * 0.82 + airBusy * 0.18).clamp(
    0.0,
    1.0,
  );
  return (minMs + severity * (maxMs - minMs)).round();
}
