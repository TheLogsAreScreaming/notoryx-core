# NOTORYX Core 10.0.0 (1.0): release status

Prepared 2026-11-13 from `dev` at `4fdb1e86` (10.0.0-rc.46), updated 2026-11-14 after multiple radios merged, and 2026-11-15 after 10.0.0 was published. This page records where each gate in [BASTION_ANDROID_1_0_RELEASE_GATES.md](BASTION_ANDROID_1_0_RELEASE_GATES.md) stands.

**Owner decision, 2026-11-13:** the maintainer lifted the hold on 10.0.0 and on multiple radios. **10.0.0 was published on 2026-11-14 as the latest stable release, without recorded Gate B results**; its release notes say it hasn't been tested on radios. These gates apply again to the next stable release (10.1.0). Record device results below as they come in.

## Summary

| Gate | Status |
|---|---|
| A. Automated checks | **Met** for 10.0.0; release commit and checksums recorded below |
| B. Physical-device tests | **Waived by the owner for 10.0.0.** Partial results since, for 10.1.0-rc.2 (one phone, one radio) |
| C. Privacy, licensing, distribution | **Met**, except store-listing contact details and the two-device test |

## Gate A: automated checks

- **Analyzer and full test suite:** passed on the 10.0.0 PR (#302), with all eight checks green: analyze, android, android-apk, ios, linux, lite-apk, macos and web.
- **Release commit:** `95298756` (merge of #302, 2026-11-14).
- **Version code:** 10.0.0 uses **101**. rc.47 used 100 and the multiple-radios test build (rc.46.radios1) used 99, so 101 installs over all test builds.
- **Signing:** releases are signed on the maintainer's Mac with the permanent Bastion key, using `sign-android.sh`. Certificate SHA-256: `01834f7d91916da8d22c6a5e3a2073c8d1689135e0ee351e20512708ac946787`. The release script refuses any other certificate.
- **CI signed workflow:** the key owner added the four `BASTION_*` secrets on 2026-11-14. *Bastion Signed Android Release* now builds the full APK, the Play bundle and the Lite APK signed with the certificate above (artifacts only; it never publishes).
- **10.0.0 SHA-256** (from the release's SHA256SUMS files):
  - `NOTORYX-Core-10.0.0-arm64-v8a.apk`: `8e31f35bd441eb2ac33799cf60982adb615abee96b0b23879f6b85d62647faf6`
  - `NOTORYX-Core-Lite-10.0.0-arm64-v8a.apk`: `e85771cbabb0442048c72a604733213af8fafd0786839cef9a03e5db1d4f649b`
  - `NOTORYX-Core-10.0.0-macOS-universal.zip`: `38c3a71e3a80a93662c429f9d7b57e49a5b62cd6443f46891e5e7530a9e0ab66`

## Gate B: physical-device tests

Nothing was recorded for 10.0.0 itself. Since then, one partial session has been recorded: [RELEASE_HARDWARE_CHECK_10.1.0-rc.2.md](test-sessions/RELEASE_HARDWARE_CHECK_10.1.0-rc.2.md). Use the sheets in [test-sessions/](test-sessions/) for new results, including [TWO_RADIO_CHECK.md](test-sessions/TWO_RADIO_CHECK.md) for multiple radios. For each case, note the Android version, phone, radio model, firmware, transport and pass or fail.

**From the rc.2 session:** Bluetooth connect, a channel message out (heard via 2 repeaters), reconnect after a radio reboot, history after force-close, upgrade keeping data, and the radio-features check all passed. Two failures were found and fixed in code in rc.3, but **neither fix has been re-checked on hardware**:
- Pressing Back on Home dropped the radio link (fixed in #338).
- Home and Diagnostics showed no noise, RSSI or SNR until Live radio stats was opened (fixed in #341).

Still untested on hardware: anything needing a second phone or radio (direct messages both ways, receipts, SOS and check-ins), USB and TCP, offline maps, backup and restore, and multiple radios.

Suggested order, so one session covers the most:

1. Fresh install, then upgrade from the previous release keeping data.
2. Bluetooth connect, disconnect and reconnect, plus a direct message and a channel message both ways, with notifications.
3. Background and locked screen for 30 minutes, then check messages still arrived.
4. SOS hold and repeat, trip check-in and overdue alert (needs two radios).
5. Map and offline map pack with no internet.
6. Encrypted backup with message history, then restore.

| Date | Phone / Android | Radio / firmware | Transport | Cases | Result |
|---|---|---|---|---|---|
| 2026-11-14 | Galaxy A15 5G / Android 16 | Seeed T1000-E / MeshCore v1.18.0 | Bluetooth | 1, 5 (one way), 9, 10, 14, 16 | Pass; Back and signal-data failures, both fixed in rc.3 but not re-checked |
| | | | | | |

## Gate C: privacy, licensing and distribution

- [x] **Privacy policy matches the code.** It covers on-device storage, encryption, MQTT opt-ins and community moderation (the Sentinel relay at `sentinel-relay.meshmayhem.org`).
- [x] **Permissions reviewed:** location, Bluetooth (scan, connect, advertise), camera (QR codes), notifications, foreground service for connected devices, wake lock and internet. Each matches a feature. `BLUETOOTH_ADVERTISE` is worth a second look.
- [x] **Third-party licences:** the in-app licence page is in About, and the Open-Meteo notice is registered at startup.
- [x] **Install and update instructions** are on the releases page, including Obtainium and the old-key note for builds before rc.10.
- [x] **Support channel fixed in #302.** The privacy policy told people to open issues in `notoryx-core`, where issues are switched off. It now points to `notoryx-core-releases/issues`, which accepts them.
- [x] **"Report a problem" link** is on the releases page README, pointing to its issues.
- [ ] **Test the exact signed APK on two Android devices** when available (Gate B).
- [ ] **Store listings only:** confirm a permanent support email and public privacy policy URL.

## In 10.0.0 without a device test

- **Multiple radios** (#291–#298, merged as #298). Needs a two-radio check.

## Not in 10.0.0

- **iPhone / TestFlight** waits for the Apple Developer account and its GitHub secrets (see APP_STORE.md).
- **Firmware update from the phone** is on hold.
