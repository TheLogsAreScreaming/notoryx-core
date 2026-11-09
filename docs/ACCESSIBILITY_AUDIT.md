# NOTORYX Core accessibility audit

**Status: first pass, code review only.** Audited at commit `eea4dcae` (`dev`, 9 November 2026), after 10.0.0-rc.39. The tables below are that first scan; **Fixes since the first scan** lists what has changed.

**No screen reader, switch control or large-text walk-through has been done yet.** This page reports what the code shows. It doesn't claim the app is accessible, and it isn't a conformance statement.

Other NOTORYX apps can reuse this method: run the scanner, review its list by hand, then do the device checks.

## Method

| Layer | How | Done? |
|---|---|---|
| 1. Pattern scan | `python3 tool/a11y_scan.py` from the repository root | Yes |
| 2. Automated tests | Flutter accessibility guideline checks in widget tests | Partly: 5 test files |
| 3. Review of scan results | Reading each flagged place in context | Yes, once |
| 4. Screen reader | TalkBack on Android, VoiceOver on iOS and macOS | **Not yet** |
| 5. Large text and display | Largest system text, bold text, reduce motion, each theme | **Not yet** |
| 6. People who use these tools | Feedback from disabled users | **Not yet** |

The scanner matches text patterns, so a flagged line is a place to look, not a confirmed bug, and an unflagged line isn't proof of correct behaviour.

## Results from the scan

| Check | Found | To review |
|---|---|---|
| Icon buttons without a tooltip | 147 | 0 |
| Floating buttons without a tooltip | 5 | 1 |
| Tap areas (`GestureDetector`) with no nearby label | 31 | 22 |
| `InkWell` with no nearby label or text | 44 | 6 |
| Images with no label | 7 | 6 |

| Pattern | Count | Why it matters |
|---|---|---|
| Text scaling clamped or disabled | 0 | Good: nothing blocks system text size |
| Reduce-motion checks | 6 files | Motion is respected in shared components; coverage not verified |
| Bold-text checks | 0 | Whether bold text works hasn't been checked |
| `TextOverflow.ellipsis` | 104 in 46 files | Can cut text off at large sizes |
| `FittedBox` | 6 in 6 files | Can shrink text instead of wrapping it |
| Live regions | 3 | Few status changes are announced automatically |
| `Text` not translated | 115 in 27 files | Mostly Bot settings, Automation and Team setup; English only |

## Known problems

1. **Add-contact button has no label.** `lib/screens/contacts_screen.dart:516` is a floating button with only an icon, so a screen reader can't name it. The rc.38 note that every icon button has a label was true of `IconButton` but missed this one.
2. **Map screens are the likely weak spot.** 8 of the 22 flagged tap areas are on the map, line-of-sight and path-trace screens, which are visual by nature and need a non-visual alternative.
3. **Received images and picked GIFs have no description.** Most of the 6 flagged images are user content, with nothing yet to describe them.
4. **Message-list tap areas need checking.** Flagged lines in the direct and channel chat screens need review with a screen reader.
5. **Long text may be cut off** at the largest text sizes, as the ellipsis count suggests.
6. **Few live announcements.** New messages, SOS status and connection changes should be checked for whether they're announced.

## Fixes since the first scan

Each flagged place was read in context.

**Labelled:** the add-contact button; the repeater CLI send button; the jump-to-latest button; map markers for nodes, clusters and shared markers; line-of-sight obstructions and endpoints; path-trace hops; wardrive pings; received and preview pictures. The decorative mesh icon in QR codes is now hidden from screen readers.

**Left as they are, pending the device walk-through:** the remaining flagged tap areas wrap visible text, or sit under a tooltip or labelled parent. Those should already be readable, but only testing with a screen reader can confirm it.

**Still open:** received pictures are labelled only as a picture, because nothing describes their contents, and map screens still need a non-visual way to explore.

## What's in place

- All 147 `IconButton`s have a tooltip, which screen readers use as the label.
- Nothing clamps system text size.
- Status icons pair colour with an icon or word in the delivery and mesh health views.
- The shared themes have automated contrast tests.

## Not measured

- Contrast on every screen. Only what the theme tests cover has been checked.
- Touch target size across the app.
- Reading and focus order.
- Keyboard use on desktop.
- Whether the new screens work with a screen reader: lock-screen SOS, reports, automation and team setup.

## Next steps

1. Do the device walk-through with TalkBack and VoiceOver, starting with SOS, sending a message and connecting a radio.
2. Update this page with the results, and name the device and OS versions used.
