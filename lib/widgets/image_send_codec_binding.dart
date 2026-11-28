import 'dart:typed_data';

/// Minimal, dependency-free abstraction over the neural image codec used by
/// [ImageSendPreviewSheet].
///
/// The real implementation lives in `lib/services/image_codec_service.dart`
/// (`ImageCodecService implements ImageSendCodec`) and
/// `lib/services/image_chunk_transport.dart`. This file deliberately does NOT
/// import them, so the preview sheet can be built, analyzed and previewed on
/// its own and so the service depends on the UI contract rather than the other
/// way round.
///
// Packet-count and airtime maths deliberately live in
// `lib/utils/lora_airtime.dart`, not here.

/// Hard minimum resolution for the codec. Images are centre-cropped to this
/// square before encoding; the decoder collapses below it.
const int kImageCodecSquareSize = 512;

/// Availability of the image codec, as far as the UI is concerned.
enum ImageCodecAvailability {
  /// The feature is switched off in app settings.
  disabled,

  /// The codec model is being fetched; the feature is temporarily unusable.
  downloading,

  /// The codec is usable right now.
  ready,

  /// The codec cannot run on this device/platform at all.
  unavailable,
}

/// Rate points the wire format can express.
///
/// The shipping build encodes at [standard] (`ft32`) only — see
/// [kImageSendRatePoint]. The enum keeps more than one value because the rate
/// point is written into the chunk-0 metadata byte by
/// `image_chunk_transport.dart`, so the ordinals are part of the wire format and
/// must stay stable even for rate points the UI never offers. Removing [high]
/// would renumber nothing today but would make a future rate point silently
/// reuse ordinal 1 and be decoded as ft16 by older builds.
enum ImageCodecRatePoint {
  /// `ft32` — the only rate point this build sends. Measured 110-209 B
  /// (mean 156 B) over 26 images, i.e. 1-2 data chunks plus parity.
  standard,

  /// `ft16` — larger, higher fidelity. **Not offered in the UI**: the model
  /// registry ships ft32 weights only. Retained so the ordinal stays reserved
  /// and so bitstreams produced elsewhere can still be identified on the wire.
  high,
}

/// The single rate point the compose UI encodes at.
///
/// The quality selector was removed once ft32 became the only shipping model;
/// every send goes out at this rate. Named rather than inlined so a future
/// second rate point has one place to come back to.
const ImageCodecRatePoint kImageSendRatePoint = ImageCodecRatePoint.standard;

/// Measured payload statistics for a rate point, in bytes.
///
/// These are real measurements over 26 images of rANS bitstreams produced by
/// the codec at 512x512, not estimates. They let the sheet show a plausible
/// range instantly, before an encode has finished.
class ImageCodecRateStats {
  final int meanBytes;
  final int minBytes;
  final int maxBytes;

  const ImageCodecRateStats({
    required this.meanBytes,
    required this.minBytes,
    required this.maxBytes,
  });

  static const ImageCodecRateStats standard = ImageCodecRateStats(
    meanBytes: 156,
    minBytes: 110,
    maxBytes: 209,
  );

  /// Retained for [ImageCodecRatePoint.high], which the UI no longer offers.
  static const ImageCodecRateStats high = ImageCodecRateStats(
    meanBytes: 288,
    minBytes: 176,
    maxBytes: 409,
  );

  static ImageCodecRateStats forRate(ImageCodecRatePoint rate) {
    switch (rate) {
      case ImageCodecRatePoint.standard:
        return standard;
      case ImageCodecRatePoint.high:
        return high;
    }
  }
}

/// Small zoom/shift tweaks behind "Try another version": (zoom, dx, dy).
/// The decoder is generative, so a near-identical input can reconstruct with
/// different invented detail; re-encoding a slightly moved frame gives the
/// sender other outcomes to choose from. Version 1 (index 0) is the whole
/// photo, byte-identical to a plain encode, so the wire format is unchanged.
/// Adapted from meshcore-open (MIT).
const List<(double, double, double)> kImageSendRerollTweaks = [
  (1.0, 0.0, 0.0),
  (1.02, 0.005, 0.0),
  (1.02, -0.005, 0.005),
  (1.04, 0.0, -0.005),
  (1.03, 0.01, 0.01),
  (1.03, -0.01, -0.01),
];

/// How many versions the sheet offers.
final int kImageSendMaxVersions = kImageSendRerollTweaks.length;

/// The part of a [width] x [height] photo that [variant] encodes: at most
/// about 2% trimmed at an edge, so the shape (and its aspect code) is kept.
({double left, double top, double width, double height}) rerollSourceRect(
  int width,
  int height,
  int variant,
) {
  if (variant < 0 || variant >= kImageSendRerollTweaks.length) {
    throw RangeError.range(
      variant,
      0,
      kImageSendRerollTweaks.length - 1,
      'variant',
    );
  }
  final (zoom, dx, dy) = kImageSendRerollTweaks[variant];
  final w = width / zoom;
  final h = height / zoom;
  final left = ((width - w) / 2 + dx * width).clamp(0.0, width - w);
  final top = ((height - h) / 2 + dy * height).clamp(0.0, height - h);
  return (left: left, top: top, width: w, height: h);
}

/// The encode interface the preview sheet consumes.
abstract class ImageSendCodec {
  /// Current availability. The sheet renders a non-interactive explanation for
  /// anything other than [ImageCodecAvailability.ready].
  ImageCodecAvailability get availability;

  /// Why [availability] is [ImageCodecAvailability.unavailable], as one
  /// user-facing sentence, or null when the codec is not permanently
  /// unavailable.
  ///
  /// This is the sentence the compose sheet shows in place of its generic
  /// "not available on this device" string: `unavailable` is a permanent
  /// property of the build (no native runtime, no entropy path, backend failed
  /// to load) and the only useful thing the UI can do is say WHICH one it hit.
  /// Implementations must not return an empty string; return null instead.
  String? get unavailableReason;

  /// Encode [imageBytes] (any common still format) at [rate], returning the
  /// compressed bitstream that will be chunked onto the air.
  ///
  /// Implementations are expected to centre-crop to
  /// [kImageCodecSquareSize] square first. [variant] picks the frame tweak
  /// (see [rerollSourceRect]); 0 is the whole photo.
  Future<Uint8List> encode(
    Uint8List imageBytes,
    ImageCodecRatePoint rate, {
    int variant = 0,
  });

  /// Decodes [payload] on this device into the picture recipients will
  /// reconstruct (PNG), or null when this device can't decode.
  Future<Uint8List?> decodePreview(Uint8List payload);
}

/// A deterministic stand-in used for widget previews and tests.
///
/// It produces a buffer of the measured mean size for the requested rate point
/// so the sheet can be exercised end-to-end without the real codec.
class FakeImageSendCodec implements ImageSendCodec {
  @override
  final ImageCodecAvailability availability;

  /// Mirrors `ImageCodecService.unavailableReason`; null unless a test wants to
  /// exercise the "why can't I send?" path.
  @override
  final String? unavailableReason;

  final Duration latency;

  /// What [decodePreview] returns; null mimics a device that can't decode.
  final Uint8List? previewPng;

  const FakeImageSendCodec({
    this.availability = ImageCodecAvailability.ready,
    this.unavailableReason,
    this.latency = const Duration(milliseconds: 250),
    this.previewPng,
  });

  /// The fake's payload size for [variant]: each version a little larger, so
  /// tests can tell them apart.
  static int payloadBytesFor(ImageCodecRatePoint rate, int variant) =>
      ImageCodecRateStats.forRate(rate).meanBytes + variant * 3;

  @override
  Future<Uint8List> encode(
    Uint8List imageBytes,
    ImageCodecRatePoint rate, {
    int variant = 0,
  }) async {
    if (latency > Duration.zero) {
      await Future<void>.delayed(latency);
    }
    final size = payloadBytesFor(rate, variant);
    return Uint8List.fromList(
      List<int>.generate(
        size,
        (i) => (i * 31 + rate.index + variant * 7) & 0xFF,
      ),
    );
  }

  @override
  Future<Uint8List?> decodePreview(Uint8List payload) async {
    if (latency > Duration.zero) {
      await Future<void>.delayed(latency);
    }
    return previewPng;
  }
}
