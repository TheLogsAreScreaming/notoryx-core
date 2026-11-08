# NOTORYX Core privacy policy (release review draft)

**Last reviewed:** November 8, 2026  
**Status:** Draft for code and distribution review before public release.

## About NOTORYX Core

NOTORYX Core is an independent MeshCore companion app. It communicates with compatible mesh radios and provides messaging, maps, route intelligence, diagnostics and coverage capture. No NOTORYX Core account is required for the current companion workflows.

## What the mesh can see

- **Direct messages** are encrypted between the two radios. Repeaters forward them but can't read them. Short sender and recipient IDs and the route travel in the clear.
- **Channel messages** are encrypted with the channel's key; anyone with the key can read them. Public and hashtag channel keys are known to everyone, so treat those channels as public.
- **Adverts** carry the radio's name, public key and, if you share it, its position, unencrypted, to everyone in range.

The app shows the same summary under **More → Privacy**.

## Information stored on the device

Depending on the features you use, NOTORYX Core can store messages, contact identifiers, channel settings, routing/path history, coverage sessions and observations, mesh node positions, track logs, waypoints and routes, repeater battery history, network change history, app preferences, cached map tiles and optional diagnostic logs. Coverage observations can contain the connected radio's GPS coordinates and nearby signal measurements. A radio's GPS position is not necessarily the phone's position.

The app uses device storage and operating-system protections; do not assume that all stored messages, logs or exports have additional app-level encryption. Anyone with access to an exported file may be able to read its contents.

You can turn on **App lock** and **Encrypt message history** under Tools → Security. Encryption covers the message database only (contacts, routes, waypoints and settings are not encrypted), and its key stays in the phone's secure storage. If that key is lost, the history can't be recovered.

## Radio communication and sharing

Messages and other information sent over a MeshCore network are transmitted to compatible radio devices. Their reach and visibility depend on the protocol, radio configuration, recipients and network participants. NOTORYX Core can let you export coverage data or diagnostics; sharing those files with other people or services is your choice.

## Device permissions

- **Bluetooth:** discover and communicate with supported MeshCore radios.
- **Location:** support platform-specific BLE discovery requirements and location-related features where enabled. Coverage capture currently records the connected radio's reported GPS location when available.
- **Internet:** retrieve online maps, optional downloads, elevation data and other internet-dependent features.
- **Notifications:** display incoming-message notifications when permitted.
- **Foreground service / wake lock:** maintain a connected-device session in the background where Android permits it.
- **Camera:** scan QR codes when that feature is used.

Permissions can be managed through Android settings, although denying a permission may disable the associated feature.

## Third-party network services

Depending on the features and settings used, the app may request map tiles from OpenStreetMap or Stadia Maps, terrain elevation from Open-Meteo, optional models from Hugging Face, GIF results from Giphy, images linked from pyx.li in messages, regional presets and the channel directory from this app's GitHub releases repository (raw.githubusercontent.com), and CoreScope analyzer lookups.

**MQTT** connects only to brokers you add. If you turn uploading on, packets your radio hears are published to them. Broker passwords are kept in the phone's secure storage (Keychain on Apple platforms, the Android Keystore on Android). Those requests can reveal your IP address and relevant request data (for example, map tile coordinates, selected path coordinates or a GIF search query) to the provider. Review each provider's privacy policy before using the feature.

## What NOTORYX Core doesn't do

No account, no analytics, no advertising and no crash reporting. The developers receive nothing unless you send it yourself, for example by attaching an exported log to an issue.

## Diagnostics and data removal

Debug logs and exported diagnostics can include device, network and radio metadata. Inspect files before sharing them. Deleting app data or uninstalling the app removes data stored solely within its private app storage; separately exported files, backups, remote services and data already transmitted over the mesh are not removed by uninstalling.

## Children and policy updates

NOTORYX Core is not designed to collect information from children. This policy will be updated if data handling or integrations change.


## Contact

For questions, bug reports or privacy concerns, open an issue in this app's GitHub repository. Confirm a permanent support address and public policy URL before publishing a store listing.
