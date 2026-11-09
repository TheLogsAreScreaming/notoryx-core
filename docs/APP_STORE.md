# App Store preparation

Status: **not submitted.** The app has never run on a real iPhone, and the `iOS TestFlight` workflow hasn't been run, because it needs an Apple Developer account. Everything below marked *draft* needs the owner's review.

## Owner's steps

1. Join the Apple Developer Program. Choose individual (your legal name shows as seller) or organization (needs a D-U-N-S number).
2. In App Store Connect, register the bundle ID `com.bastionmesh.bastion` and create the app.
3. Create an App Store Connect API key with the **Admin** role, needed for CI to create signing certificates. Download the `.p8` file; Apple only offers it once.
4. Add these GitHub repository secrets. Never put them in the repo or in chat.

| Secret | Value |
|---|---|
| `APPLE_TEAM_ID` | The 10-character team ID from your membership page |
| `ASC_KEY_ID` | The API key's ID |
| `ASC_ISSUER_ID` | The issuer ID on the API keys page |
| `ASC_KEY_P8` | The full text of the `.p8` file |

5. Run **Actions → iOS TestFlight** with a version. Expect the first run to need fixes.
6. Test on an iPhone through TestFlight, using the checks in *Before submitting*.
7. Add screenshots, the listing and the privacy and export answers, then submit.

**Version numbers.** Apple allows up to three numbers, so a tag like `10.0.0-rc.41` can't be used. Each new version must be higher than the last, so testing with `0.41.0` leaves `1.0.0` free for launch. CI sets the build number itself.

## Before submitting

- [ ] Bluetooth pairing, sending and receiving on an iPhone
- [ ] Messages keep arriving with the app in the background
- [ ] Notifications, including reply
- [ ] Face ID app lock, and encrypted history
- [ ] Camera QR scan, photo picker, location prompts
- [ ] VoiceOver on SOS, sending a message and connecting a radio
- [ ] Privacy policy available at a public URL
- [ ] Support URL decided. Keep it separate from Backcountry Signal
- [ ] Privacy manifest (`PrivacyInfo.xcprivacy`) checked; the app target has none of its own
- [ ] Screenshots for the required iPhone sizes, and iPad if iPad stays enabled

## Store listing (draft)

**Name:** NOTORYX Core

**Subtitle:** Off-grid MeshCore messaging

**Keywords:** meshcore,lora,mesh,off-grid,offline,radio,messaging,hiking,backcountry,repeater,no cell

**Promotional text:** Text friends over LoRa radios with no cell service or internet. Needs a MeshCore radio.

**Description:**

> NOTORYX Core is a messaging app for MeshCore LoRa radios. Connect a compatible radio by Bluetooth and exchange messages with people in radio range or across a mesh of repeaters, with no cell service, internet or account.
>
> A compatible MeshCore radio, sold separately, is required.
>
> - Direct messages and channels
> - Map of nodes, waypoints and routes, with offline maps
> - Delivery status and route details
> - Trip check-ins and field reports
> - Team setup shared by encrypted QR code or file
> - Optional app lock and encrypted history
> - No account, analytics, advertising or crash reporting
>
> IMPORTANT: NOTORYX Core does not contact emergency services. The SOS feature only sends a message to people you choose, over a radio network that may not deliver it. Don't rely on it as your only way to get help.

**Category:** Navigation or Utilities. **Price:** Free.

## Review notes (draft)

> This app controls a MeshCore LoRa radio over Bluetooth and needs one for its main functions. We have attached a video showing pairing, sending and receiving on real hardware. [Add the link before submitting.]
>
> No account or login is needed. Without a radio, you can browse the interface, map and settings.
>
> Background Bluetooth (`bluetooth-central`) keeps the link to the user's radio so messages arrive while the app is not on screen.
>
> The SOS feature sends a mesh message to contacts the user has chosen. It doesn't contact emergency services, and the app says so.

## App privacy answers (draft)

The privacy policy says the developers receive nothing unless a user sends it themselves, and the app has no analytics, advertising or crash reporting. The likely answer is **Data Not Collected**. Confirm it against Apple's definitions, considering these optional or third-party connections:

| Feature | Goes to |
|---|---|
| Map tiles | OpenStreetMap or the chosen tile source |
| GIF search | Giphy |
| Weather | Open-Meteo, and the National Weather Service for alerts |
| Translation model download | Hugging Face |
| MQTT and coverage upload | Servers the user configures, off by default |

Location only leaves the phone if the user shares it over the mesh or turns on coverage upload.

## Encryption and export (draft, needs checking)

The app uses standard encryption: AES for mesh messages, AES-GCM with PBKDF2 for backups and team files, and SQLCipher-style database encryption. App Store Connect will ask about this. `ITSAppUsesNonExemptEncryption` is deliberately **not** set, so the question stays open until it's answered properly.

This app does not appear to be exempt merely for using encryption. Check with Apple's export compliance guidance, and with someone qualified if unsure, whether a US filing or annual self-classification report is needed.

## Likely review issues

- **Hardware required:** a demo video and clear notes are essential.
- **SOS wording:** must not suggest it replaces emergency services.
- **User-generated content (Guideline 1.2):** chats may need a way to block and report. Sender blocking exists; there is no reporting, because the mesh has no operator. Explain this in the review notes if asked.
- **GIF search and link previews:** third-party content that can affect the age rating.
- **Downloaded translation models and bots:** should be fine as data, but may draw questions.
- **Fork notice:** the MIT licence notice for the original project must stay included.
