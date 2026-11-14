# Release hardware check

Fill this in for **one exact build** before calling it ready. Copy the file per release (for example `RELEASE_HARDWARE_CHECK_10.1.0-rc.2.md`). Write what actually happened. A row that wasn't tried stays **Not tried**, never Pass.

## The build

| | |
|---|---|
| Tag | |
| APK SHA-256 (from `SHA256SUMS-Android.txt`) | |
| `RELEASE-MANIFEST.json` attached? | yes / no |
| Date | |
| Tester | |

## Equipment (at least two phones and two radios)

| | Phone + OS version | Radio model | Companion firmware |
|---|---|---|---|
| A | | | |
| B | | | |

## Checks

Result: **Pass**, **Fail** (say what happened) or **Not tried**.

| # | Check | Phone A | Phone B | Notes |
|---|---|---|---|---|
| 1 | Connect over Bluetooth, contacts and channels load | | | |
| 2 | Connect over USB (Android OTG / Mac) | | | |
| 3 | Connect over Wi-Fi / TCP (if the radio supports it) | | | |
| 4 | DM A→B shows a delivery receipt; B→A the same | | | |
| 5 | Channel message both ways | | | |
| 6 | Turn B's radio off, send from A: shows not delivered, no app freeze | | | |
| 7 | Queue a message with A disconnected, reconnect: sends once only | | | |
| 8 | Pull A's radio power just as it reconnects with a queued message: text comes back with "may already have gone out" | | | |
| 9 | Reboot radio A while connected: app reconnects by itself | | | |
| 10 | Force-close and reopen the app: history and queue intact | | | |
| 11 | Screen locked 15 min: a DM still notifies | | | |
| 12 | Screen locked: start SOS from the notification / lock screen if offered; check-in reminder fires | | | |
| 13 | Encrypted backup, uninstall, reinstall, restore: settings and history back | | | |
| 14 | Install this build over the previous release: history kept | | | |
| 15 | Offline map: airplane mode, the trip area draws; trip check shows whole-tile count | | | |
| 16 | Diagnostics → Radio features matches what the radio can do | | | |

## Result

- Supported combinations (only those that passed):
- Known failures:
- Decision: ready / not ready
