# NOTORYX Core lite build

A smaller Android build with no closed-source libraries, for IzzyOnDroid and
anyone who wants a light APK. It is the same app with three features left out:

| Left out | Package | Why |
|---|---|---|
| On-device message translation | `llamadart` (llama.cpp + LiteRT) | ~50 MB of native libraries |
| Picture messages | `flutter_onnxruntime` | ~80 MB of native libraries |
| Camera QR scanner | `mobile_scanner` (Google ML Kit) | ML Kit is closed source |

In the lite build, translation settings are hidden, picture messages say they
aren't in this build, and the QR scanner becomes a box to paste the code's text,
checked the same way.

## How it works

`tool/lite/apply.sh` rewrites a checkout in place:

1. Copies each `tool/lite/overrides/<path>.dart.lite` over `<path>.dart`.
   The full files and their lite copies have the same public API.
   `lib/build_flavor.dart` sets `kLiteBuild`.
2. Deletes `lib/services/image_codec_session_io.dart`.
3. Removes the three packages from `pubspec.yaml` (`strip_pubspec.py`).
4. Fails if anything in `lib` still imports them.
5. Deletes `test/`, which tests the full build.

The `.dart.lite` extension keeps the overrides out of the normal analyzer.

**Run it only on a throwaway checkout.** CI does this in
`.github/workflows/build-lite-apk.yml`, which also fails if a left-out
library is still in the APK.

## Changing a seam file

If you change the public API of one of these, change its lite copy too:

- `lib/build_flavor.dart`
- `lib/services/translation_llm.dart`
- `lib/services/image_codec_backend.dart` (lite only needs `kImageCodecBitstreamPathAvailable`)
- `lib/services/image_codec_session.dart`
- `lib/widgets/qr_scanner_widget.dart`

The lite workflow runs on PRs that touch them.

## Still closed source

`geolocator` uses Google Play Services location on Android, and some plugins
pull in other Google libraries. The workflow lists any `com.google.android.gms`,
`mlkit` or `firebase` classes it finds in the APK.
