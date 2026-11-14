# Two-radio check

For multiple radios at once. Needs **two radios connected to one phone**, plus a third node (another phone and radio) to talk to. Mark each row **Pass**, **Fail** (what happened) or **Not tried**.

| | |
|---|---|
| Build tag + APK SHA-256 | |
| Phone + OS | |
| Radio 1 (model, firmware) | |
| Radio 2 (model, firmware) | |
| Third node | |

| # | Check | Result | Notes |
|---|---|---|---|
| 1 | Add radio 2; both stay connected after 10 min | | |
| 2 | Message the third node from radio 1, then from radio 2: the third node sees two different senders | | |
| 3 | Third node DMs radio 2 while radio 1 is active: unread badge on radio 2, notification names radio 2 | | |
| 4 | Tap that notification: opens the chat on radio 2 | | |
| 5 | Queue a message on radio 1, switch to radio 2 before it sends: it still goes out from radio 1, never radio 2 | | |
| 6 | Change a setting with radio 2 active: only radio 2 changes (check radio 1's value) | | |
| 7 | Reboot radio 1: it reconnects by itself, radio 2 unaffected | | |
| 8 | Restart the app: both reconnect, a few seconds apart | | |
| 9 | Continue a chat on the other radio: the chat moves, history stays readable | | |
| 10 | One hour with both connected: phone battery use noted | | |

Decision: ready to recommend / not yet. Failures:
