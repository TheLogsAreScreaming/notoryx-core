# Release hardware check: 10.1.0-rc.2 (partial, one phone + one radio)

## The build

| | |
|---|---|
| Tag | v10.1.0-rc.2 |
| APK SHA-256 | `8d61ec7a90cb714d710ab594c70e3e442636c11494c15fdd50165103a390b596` |
| `RELEASE-MANIFEST.json` attached? | yes |
| Date | 2026-11-14 |
| Tester | Claude over adb, owner present |

## Equipment

| | Phone + OS version | Radio model | Companion firmware |
|---|---|---|---|
| A | Samsung Galaxy A15 5G (SM-S156V), Android 16 | Seeed T1000-E | MeshCore v1.18.0 (protocol v14), Bluetooth companion |
| B | none | none | none |

## Checks

| # | Check | Phone A | Phone B | Notes |
|---|---|---|---|---|
| 1 | Connect over Bluetooth, contacts and channels load | Pass | Not tried | Reconnected by itself after install; 500 nodes, 37 channels, channel history shown. |
| 2 | Connect over USB | Not tried | Not tried | This T1000-E runs the Bluetooth companion build; its USB port doesn't speak the companion protocol. |
| 3 | Connect over Wi-Fi / TCP | Not tried | Not tried | T1000-E has no Wi-Fi. |
| 4 | DM A→B receipt, B→A | Not tried | Not tried | No second phone/radio. |
| 5 | Channel message both ways | Pass (A→mesh) | Not tried | "test 1, please ignore" on #testing: shown Signed ✓✓, heard back via 2 repeaters. B→A not tried (no second phone/radio). |
| 6 | B off, send from A | Not tried | Not tried | No second phone/radio. |
| 7 | Queue while disconnected, sends once | Can't be done as written | | When the link drops, Core closes the chat and locks the Chats tab until reconnected, so nothing can be queued offline. Radio powered off 11:36:37; Core reconnected **by itself** 11:37:12 after power-on (no tap). |
| 8 | Pull power during queued send | Not tried | | Timing can't be lined up remotely. |
| 9 | Reboot radio while connected: reconnects | **Pass** | | Settings → Reboot Device. Link dropped 11:25:55 (GATT status 8), reconnected 11:25:56. |
| 10 | Force-close and reopen: history and queue intact | Pass (history) | | `am force-stop`, relaunch: reconnected, all channel history present. Queue not exercised. |
| 11 | Screen locked: a DM still notifies | Partial | | Home + lock for 2 min: link stayed up, 18 frames received. No DM sent (no B). **Leaving the app with Back disconnects the radio** (see Known failures). |
| 12 | SOS from lock screen; check-in reminder | Not tried | | Not triggered on purpose. |
| 13 | Backup, uninstall, reinstall, restore | Not tried | | Would wipe the owner's data; owner's call. |
| 14 | Install over previous release: history kept | **Pass** | | rc.2 installed over 10.0.0-rc.47 (build 100) with `adb install -r`; channels, history, radio pairing kept. |
| 15 | Offline map in airplane mode; whole-tile count | Not tried | | Airplane mode is a phone setting; owner's call. |
| 16 | Diagnostics → Radio features matches the radio | **Pass** | | Live stats, text CLI, channel data, signed posts, raw packets: Supported (protocol v14). Flood corridor: Not supported (stock firmware). Correct. |

## Screen reader (Map as a list, issue #7)

- Map → ⋮ → Map as a list opens a list of 404 nodes, nearest first, each with distance, compass direction, last heard and route state.
- With TalkBack on, the accessibility tree has: "Back" button, the title, the intro text, "Nodes (404)", and each row as **one button** whose label is the name plus "0.2 km south-east • heard 4d ago • No route yet".
- Not checked: spoken output by ear, headings, scrolling with TalkBack gestures, opening a row with double-tap (the TalkBack tutorial kept taking focus).

## Result

- Supported combinations (only those that passed): Galaxy A15 / Android 16 + T1000-E MeshCore v1.18.0 over Bluetooth, for checks 1, 5 (one way), 9, 14, 16, and reconnect after radio power loss.
- Known failures:
  - **Back button drops the radio link.** Leaving Core with Back destroys the activity; the Bluetooth plugin's `onDetachedFromEngine` calls `disconnectAllDevices`, and the background service doesn't reconnect. Until reopened, no messages or alerts arrive. (Home keeps the link.)
  - **Home screen / Diagnostics health show no signal data** ("Noise: No data", RSSI "—") while Live radio stats shows noise −115 dBm, RSSI −24, SNR 13.5 from the same radio.
  - **Home → Sensors: "Your radio didn't answer"** for the T1000-E (has temperature/light sensors). Not yet investigated.
  - **Duplicated hint on Home while offline:** "Connect your radio first. Connect your radio first." under the Check in / SOS buttons.
  - **"heard Just now"** capitalised mid-sentence in Map as a list.
- Decision: not ready (one phone, one radio only; Back-button disconnect).
