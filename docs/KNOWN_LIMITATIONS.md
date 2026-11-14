# Known limitations

What NOTORYX Core can't do, or hasn't been shown to do yet. Read this before relying on it in the field. Report anything missing here at [notoryx-core-releases issues](https://github.com/TheLogsAreScreaming/notoryx-core-releases/issues/new/choose).

## Testing

- **Real hardware coverage is thin.** Releases are checked by automated tests (unit, widget and a mesh simulator) and a successful CI build of the exact commit. They have not been run across a wide range of phones, Android versions, radios and firmware. Each release's notes say what was and wasn't tried on hardware.
- **Multiple radios at once** is built and merged but hasn't been through a two-radio field test.
- **Background behaviour** (locked screen, battery optimisation, the OS stopping the app) varies by phone maker and hasn't been measured on many models.

## Messaging and delivery

- **Delivery is never guaranteed.** No app can deliver over the mesh when there's no radio path. The radio taking a message, a repeater being overheard and a delivery receipt from the recipient's radio are different things, and none of them means the message was read.
- A queued message whose send was interrupted goes back to the message box with a note that it **may already have gone out**. Check before sending it again.
- Channels shared by name or with a guessable key aren't private.

## Maps and location

- **Offline maps must be downloaded before you go.** The trip check counts only whole map tiles, but it checks map data, not radio coverage.
- Distances and directions are straight lines from your radio. A radio route is how messages travel, not a path on the ground.
- Coverage records come from what this phone heard. They aren't a complete coverage map.

## Safety features

- **SOS and check-ins reach other people on the mesh only.** They do not contact emergency services and depend on someone with a compatible app being in range.
- Moderation lists (Sentinel) need internet to update and can't ban a radio from the mesh.

## Platforms

- **Android:** full app and Lite. Lite leaves out on-device translation, picture messages, the camera QR scanner and phone GPS.
- **macOS:** universal build, not notarized by Apple (see the README for how to open it).
- **iOS, Windows, Linux and web** compile in CI but aren't released.

## Firmware

- Optional features are turned on only when the radio has shown it supports them (Diagnostics → Radio features shows why). Custom-firmware commands are sent only after the radio answers a probe.
- Firmware updates over LoRa, dual radio profiles and mailboxes are **not** supported.

## Accessibility

- Screens have labels and a map-as-a-list view, but a full walkthrough with TalkBack or VoiceOver on a real phone hasn't been done yet.
