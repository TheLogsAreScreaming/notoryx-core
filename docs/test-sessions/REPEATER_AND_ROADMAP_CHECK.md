# Repeater and roadmap check (10.1.0-rc.22 and later)

Covers the features shipped since rc.21 that have only been tested in code: repeater tools, Fleet, the gap finder, SARNEG on a second radio and the ping note. About an hour.

**You need:** this phone with Core, **one repeater you own** (its admin password), and a **second MeshCore radio** (another phone or a companion radio) to send to. Mark each row **Pass**, **Fail** (what happened) or **Not tried**. Use test words and the #testing channel only; never put real node names in the notes you share.

| | |
|---|---|
| Build tag + APK SHA-256 | |
| Phone + OS | |
| Your radio (model, firmware) | |
| Repeater (model, firmware) | |
| Second radio | |

## A. Repeater login doctor (#422)

| # | Check | Result | Notes |
|---|---|---|---|
| A1 | Log in with the right password: login succeeds | | |
| A2 | Log in with a wrong password: message says "no answer" and mentions a wrong password (repeaters stay silent), not a generic failure | | |
| A3 | Turn Bluetooth off on the phone, try to log in: "Your radio isn't connected" | | |
| A4 | Set a saved direct path that's wrong (Routing), log in: message names the hop count and suggests Force Flood | | |
| A5 | After login, change **flood.max** and Save: "Settings saved and confirmed by the repeater" | | |
| A6 | Change **advert.interval** and the **name** together, Save: confirmed; the values on the repeater match (Refresh) | | |

## B. Repeater report card (#423)

| # | Check | Result | Notes |
|---|---|---|---|
| B1 | Run Status on the repeater 3 times a few minutes apart: Report card shows 3 checks, longest uptime, battery | | |
| B2 | Reboot the repeater, run Status again: Restarts seen goes up by 1 | | |
| B3 | Neighbours (run the neighbour list once): Report card shows neighbours heard | | |
| B4 | Export CSV: file opens in a spreadsheet, one row per check, times in UTC | | |

## C. Fleet (#420, #428)

| # | Check | Result | Notes |
|---|---|---|---|
| C1 | Tools → Routing → Fleet → add your repeater: listed once (no duplicate), search finds it | | |
| C2 | Poll it: full health card (battery, uptime, noise), not "No answer" | | |
| C3 | "Last heard" matches when the repeater was really heard, not its own clock | | |
| C4 | Bulk settings: change one allowed setting; the diff shows old → new; confirm; the repeater has the new value | | |

## D. Ping and signal labels (#418)

| # | Check | Result | Notes |
|---|---|---|---|
| D1 | Repeater ping, 10 probes, repeater in range: round trip and SNR both ways shown | | |
| D2 | Ping a repeater that's off or out of range: the "No reply isn't proof the repeater is down" note appears | | |
| D3 | Map → Traffic: a relayed packet says "Last hop <repeater>"; a packet straight from its sender says "Heard from" | | |

## E. Gap finder (#426)

| # | Check | Result | Notes |
|---|---|---|---|
| E1 | With the phone's location on, DM the second radio 3 times (delivered): Coverage → Gap finder shows a green hexagon | | |
| E2 | Turn the second radio off, DM it twice (fails): the same hexagon turns amber or red, the list shows the failures | | |
| E3 | Clear history: the map empties | | |

## F. SARNEG with a second radio (#425)

| # | Check | Result | Notes |
|---|---|---|---|
| F1 | Send a grid reference with the zone in clear to the second radio on #testing: it decodes there with the same word | | |
| F2 | Send without the marker; on the receiving side, Decode unmarked messages offers to decode it | | |
| F3 | Number and letter of the day match on both radios | | |
| F4 | Forget the test word on both radios afterwards | | |

## G. Connection timeline and support file (#421, #429)

| # | Check | Result | Notes |
|---|---|---|---|
| G1 | Close and reopen the app with auto-connect on: Diagnostics timeline says "connected automatically" | | |
| G2 | Walk out of range until the link drops: timeline says "link dropped", then "automatic retry" | | |
| G3 | Export: open the file, no node names, keys or coordinates appear | | |

Decision: ready for 10.1.0 / not yet. Failures:
