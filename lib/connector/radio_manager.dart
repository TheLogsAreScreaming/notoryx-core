import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'meshcore_connector.dart';

/// Builds a connection for [slot]; swapped out in tests.
typedef ConnectorFactory = MeshCoreConnector Function(String slot);

/// Holds every radio connection and says which one is active: the one the
/// screens show and send through.
///
/// The app's services follow the active radio. Other radios stay connected
/// in the background (docs/MULTI_RADIO_DESIGN.md, phase 2). Added radios are
/// remembered in [prefs], and come back unconnected after a restart.
class RadioManager extends ChangeNotifier {
  RadioManager(
    MeshCoreConnector primary, {
    ConnectorFactory? create,
    this.prefs,
  }) : assert(primary.slot.isEmpty, 'the first radio uses slot ""'),
       _radios = [primary],
       _create = create ?? ((slot) => MeshCoreConnector(slot: slot)) {
    _nameNotifications(primary);
    for (final slot in prefs?.getStringList(slotsKey) ?? const <String>[]) {
      if (!_validSlot(slot) || !canAdd) continue;
      if (_radios.any((r) => r.slot == slot)) continue;
      _radios.add(_nameNotifications(_create(slot)));
    }
  }

  /// With more than one radio, notifications name the radio they came in
  /// on: its own name, else its saved name, else "#2" and so on.
  MeshCoreConnector _nameNotifications(MeshCoreConnector radio) {
    radio.notificationRadioName = () {
      if (!hasMultiple) return null;
      final own = radio.selfName?.trim();
      if (own != null && own.isNotEmpty) return own;
      final saved = radio.savedRadio?.name.trim();
      if (saved != null && saved.isNotEmpty) return saved;
      return '#${numberOf(radio)}';
    };
    return radio;
  }

  /// Where the added radios' slots are remembered.
  static const slotsKey = 'radio_slots';

  /// Remembers added radios; null in tests that don't need it.
  final SharedPreferences? prefs;

  static bool _validSlot(String slot) => RegExp(r'^r[2-9]$').hasMatch(slot);

  /// The most radios at once. Each live connection costs battery and, on
  /// Bluetooth, one of the phone's limited connection slots.
  static const maxRadios = 3;

  final List<MeshCoreConnector> _radios;
  final ConnectorFactory _create;
  int _active = 0;

  /// Every connection, the first radio first.
  List<MeshCoreConnector> get radios => List.unmodifiable(_radios);

  /// The first radio. Services that aren't radio-aware yet stay on this one.
  MeshCoreConnector get primary => _radios.first;

  /// The radio the screens show and send through.
  MeshCoreConnector get active => _radios[_active];

  /// Whether more than one radio has been added.
  bool get hasMultiple => _radios.length > 1;

  /// Whether another radio can be added.
  bool get canAdd => _radios.length < maxRadios;

  /// Adds a new, unconnected radio in the first free slot and returns it.
  /// Throws a [StateError] when [maxRadios] are already added.
  MeshCoreConnector add() {
    if (!canAdd) throw StateError('At most $maxRadios radios.');
    final used = {for (final r in _radios) r.slot};
    var n = 2;
    while (used.contains('r$n')) {
      n++;
    }
    final radio = _nameNotifications(_create('r$n'));
    _radios.add(radio);
    _saveSlots();
    notifyListeners();
    return radio;
  }

  void _saveSlots() => unawaited(
    prefs?.setStringList(slotsKey, [for (final r in _radios.skip(1)) r.slot]),
  );

  ({String payload, String? reply})? _handOff;

  /// Switches to [radio] and leaves a notification tap ([reply] null) or a
  /// quick reply for the app to finish once it's rebuilt for that radio.
  void switchFor(MeshCoreConnector radio, String payload, {String? reply}) {
    _handOff = (payload: payload, reply: reply);
    setActive(radio);
  }

  /// The notification action left by [switchFor], once.
  ({String payload, String? reply})? takeHandOff() {
    final handOff = _handOff;
    _handOff = null;
    return handOff;
  }

  /// Unread messages on the radios not in use.
  int get backgroundUnread => _radios
      .where((r) => r != active)
      .fold(0, (sum, r) => sum + r.getTotalUnreadCount());

  /// Other connected radios that know the contact with [publicKeyHex],
  /// each with its route length to them: 0 direct, more for hops, -1 when
  /// it has no route and would flood.
  List<({MeshCoreConnector radio, int hops})> otherRadiosForContact(
    String publicKeyHex,
  ) => [
    for (final radio in _radios)
      if (radio != active && radio.isConnected)
        if (radio.getContactByPubKeyHex(publicKeyHex) case final contact?)
          (radio: radio, hops: contact.pathLength),
  ];

  /// Other connected radios with a channel using the same key as [psk],
  /// with that channel's slot on each radio.
  List<({MeshCoreConnector radio, int index})> otherRadiosForChannel(
    Uint8List psk,
  ) => [
    for (final radio in _radios)
      if (radio != active && radio.isConnected)
        for (final channel in radio.channels)
          if (listEquals(channel.psk, psk))
            (radio: radio, index: channel.index),
  ];

  /// The radio in [slot], or null.
  MeshCoreConnector? radioIn(String slot) {
    for (final radio in _radios) {
      if (radio.slot == slot) return radio;
    }
    return null;
  }

  /// The position of [radio] in [radios], from 1: "Radio 2" and so on.
  int numberOf(MeshCoreConnector radio) => _radios.indexOf(radio) + 1;

  /// Makes [radio] the active one. Does nothing if it isn't one of ours.
  void setActive(MeshCoreConnector radio) {
    final index = _radios.indexOf(radio);
    if (index < 0 || index == _active) return;
    // Bluetooth scanning is shared by the whole phone, so only the active
    // radio may scan.
    unawaited(active.stopScan());
    _active = index;
    notifyListeners();
  }

  /// Disconnects and forgets [radio]. The first radio can't be removed. If
  /// [radio] was active, the first radio becomes active.
  Future<void> remove(MeshCoreConnector radio) async {
    final index = _radios.indexOf(radio);
    if (index <= 0) return;
    final wasActive = index == _active;
    final active = this.active;
    _radios.removeAt(index);
    _active = wasActive ? 0 : _radios.indexOf(active);
    _saveSlots();
    notifyListeners();
    try {
      await radio.disconnect(manual: true);
      await radio.forgetSavedRadio();
    } finally {
      radio.dispose();
    }
  }
}
