# Release provenance

Every file published to [notoryx-core-releases](https://github.com/TheLogsAreScreaming/notoryx-core-releases/releases) should be traceable to one commit, a passing test run of that same commit, and the release signing certificate.

## What each workflow proves

| Workflow | What it does | What it proves |
|---|---|---|
| **Flutter and Dart** | `flutter analyze` and `flutter test` | The commit's tests pass. Runs on pull requests and on pushes to `main` and `dev`, so the merged commit releases are built from is tested itself. |
| **Build NOTORYX Core APK** | Builds the APK and writes `BUILD-INFO.json` | The APK came from that commit. It is **build-only**: it does not run tests and is never counted as a test pass. |
| **Build NOTORYX Core Lite APK** | Builds the Lite APK | Same as above, for Lite. |

`BUILD-INFO.json` records the commit, the build run, the Flutter version, the hash of the resolved `pubspec.lock`, the APK's SHA-256 before signing, and a link to the checks for that commit.

## Before publishing an Android release

The APK is re-signed on the maintainer's Mac with the release key, because the signing key never goes to CI. Re-signing changes the file, so its hash changes. To keep the chain intact:

1. Download the CI artifact (it includes `BUILD-INFO.json`) and re-sign the APK as usual.
2. Run:

   ```bash
   python3 tools/release/release_manifest.py --ci-artifact <artifact dir> --signed <signed apk> --tag <tag>
   ```

   It writes `RELEASE-MANIFEST.json` and **refuses** if:
   - the "Flutter and Dart" run for that exact commit didn't pass, or never ran
   - the signed APK differs from the CI build in anything but the signature
   - the signing certificate isn't the release certificate
3. Upload `RELEASE-MANIFEST.json` with the APK and `SHA256SUMS-Android.txt`.

The manifest lists the commit, the build run, the test run(s), the hash before and after re-signing, and the certificate's SHA-256. Anyone can check the published APK's hash and certificate against it.
