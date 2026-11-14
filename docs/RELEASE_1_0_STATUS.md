# NOTORYX Core 10.0.0 (1.0): release status

Prepared 2026-11-13 from `dev` at `4fdb1e86` (10.0.0-rc.46), updated 2026-11-14 after multiple radios merged. This page records where each gate in [BASTION_ANDROID_1_0_RELEASE_GATES.md](BASTION_ANDROID_1_0_RELEASE_GATES.md) stands.

**Owner decision, 2026-11-13:** the maintainer lifted the hold on 10.0.0 and on multiple radios. 10.0.0 ships without recorded Gate B results; the release notes say it hasn't been tested on radios yet. Record device results below as they come in.

## Summary

| Gate | Status |
|---|---|
| A. Automated checks | Met, apart from the release-commit run below |
| B. Physical-device tests | **Waived by the owner for 10.0.0.** No results recorded yet |
| C. Privacy, licensing, distribution | Mostly met; two items left for the user |

## Gate A: automated checks

- **Analyzer and full test suite:** run by CI on the 10.0.0 version-bump PR. Confirm both pass on that PR before merging.
- **Builds on `4fdb1e86`:** Android APK, Lite APK and macOS all built successfully.
- **Version code:** 10.0.0 uses **101**. rc.47 used 100 and the multiple-radios test build (rc.46.radios1) used 99, so 101 installs over all test builds.
- **Signing:** releases are signed on the maintainer's Mac with the permanent Bastion key, using `sign-android.sh`. Certificate SHA-256: `01834f7d91916da8d22c6a5e3a2073c8d1689135e0ee351e20512708ac946787`. The release script refuses any other certificate.
- **CI signed workflow:** *Bastion Signed Android Release* stops at "Check signing configuration" because the four `BASTION_*` secrets aren't set. This doesn't block 1.0, since local signing uses the same key. Adding the secrets is optional and only the key owner should do it.
- **Record at release time:** the release commit, the APK SHA-256 values and the certificate above.

## Gate B: physical-device tests

Nothing is recorded yet. Use the checklist in the gates document, and for each case note the Android version, phone, radio model, firmware, transport and pass or fail.

Suggested order, so one session covers the most:

1. Fresh install, then upgrade from rc.45/rc.46 keeping data.
2. Bluetooth connect, disconnect and reconnect, plus a direct message and a channel message both ways, with notifications.
3. Background and locked screen for 30 minutes, then check messages still arrived.
4. SOS hold and repeat, trip check-in and overdue alert (needs two radios).
5. Map and offline map pack with no internet.
6. Encrypted backup with message history, then restore.

| Date | Phone / Android | Radio / firmware | Transport | Cases | Result |
|---|---|---|---|---|---|
| | | | | | |

## Gate C: privacy, licensing and distribution

- [x] **Privacy policy matches the code.** It covers on-device storage, encryption, MQTT opt-ins and community moderation (the Sentinel relay at `sentinel-relay.meshmayhem.org`).
- [x] **Permissions reviewed:** location, Bluetooth (scan, connect, advertise), camera (QR codes), notifications, foreground service for connected devices, wake lock and internet. Each matches a feature. `BLUETOOTH_ADVERTISE` is worth a second look.
- [x] **Third-party licences:** the in-app licence page is in About, and the Open-Meteo notice is registered at startup.
- [x] **Install and update instructions** are on the releases page, including Obtainium and the old-key note for builds before rc.10.
- [x] **Support channel fixed in this PR.** The privacy policy told people to open issues in `notoryx-core`, where issues are switched off. It now points to `notoryx-core-releases/issues`, which accepts them.
- [ ] **Add a "Report a problem" link** to the releases page README when 10.0.0 is published.
- [ ] **Test the exact signed APK on two Android devices** when available (Gate B).
- [ ] **Store listings only:** confirm a permanent support email and public privacy policy URL.

## In 10.0.0 without a device test

- **Multiple radios** (#291–#298, merged as #298). Needs a two-radio check.

## Not in 10.0.0

- **iPhone / TestFlight** waits for the Apple Developer account and its GitHub secrets (see APP_STORE.md).
- **Firmware update from the phone** is on hold.
