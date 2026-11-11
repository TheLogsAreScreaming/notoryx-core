# Multiple radios at once: design

Status: **proposal only. No code yet.** Not to be merged or built until the single-radio build, including the connector split (#260), has passed real-radio testing.

## Goal

Stay connected to two or more MeshCore radios at the same time: for example a handheld by Bluetooth and a base station over the network. You can read and send through any of them, and nothing is missed on the one not on screen.

## How the app works today

- `main.dart` creates **one** `MeshCoreConnector` and gives it to the whole app as a provider.
- 17 services are built around that one connector, including bots, automation, Field Ops, the outbox, track logging, wardrive, the SOS relay and coverage.
- 74 screen and widget files read it from the provider, and 31 service files use it.
- Most stored data is already **scoped per radio** by its public key: message history, contacts, channels, drafts and the outbox. That is the main thing in our favour.

## Approach

Keep `MeshCoreConnector` as one radio's connection, and add a `RadioManager` above it:

1. **`RadioManager`** holds a list of connectors, each with its own transport (Bluetooth, USB or network). It decides which one is *active*, the one the screens show and send through.
2. **The provider keeps serving "the active connector"**, so the 74 screens mostly work unchanged. When the active radio changes, the provider swaps it and screens rebuild.
3. **Background radios keep receiving.** Notifications, unread counts and the outbox listen to every connector, not just the active one, and each notification names its radio.
4. **Services split into two kinds:**
   - *Per radio*, one copy each: outbox, track log, SOS relay, direct repeaters, battery history.
   - *App-wide*, following the active radio: bots, automation, regional presets, coverage. Bots and automation must never answer twice, once per radio.
5. **UI:** a radio switcher in the top bar, the transport and status for each radio, and "send from" in chats when more than one radio can reach a contact.

## Phases (one PR each)

1. Add `RadioManager` with one radio. No change in behaviour, so the refactor can be tested on its own.
2. Allow a second connection and the switcher. Background radios connect but only the active one is used.
3. Notifications, unread counts and the outbox listen to every radio.
4. Split services into per-radio and app-wide, with a guard against double bot or automation replies.
5. "Send from" in chats, and per-radio status in the connection screen.

Each phase needs a real-radio test before the next. Realistically this is several weeks of work and testing, not one session.

## Risks

- **Bluetooth limits:** phones can hold several Bluetooth connections, but background behaviour on iOS and Android may drop the inactive one. This must be checked on real phones.
- **Double actions:** a contact heard by both radios could trigger two bot replies, two notifications or two SOS relays. These need de-duplication by message, not by radio.
- **Battery:** two live connections cost more power.
- **Scope bugs:** anything still stored without a radio scope would mix data between radios.

## Licence

NOTORYX PRO already supports several radios, but PRO is **GPL-3.0** and Core is **MIT**, so no code can be copied from PRO into Core. This must be an independent implementation.

## Testing

- Unit tests with two simulated connectors: switching, background receive, no double replies.
- Real test: two radios on one phone, then a phone with one radio plus a Mac with another. Check messages arrive on both, notifications name the right radio, and nothing sends twice.
