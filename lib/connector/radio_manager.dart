import 'package:flutter/foundation.dart';

import 'meshcore_connector.dart';

/// Builds a connection for [slot]; swapped out in tests.
typedef ConnectorFactory = MeshCoreConnector Function(String slot);

/// Holds every radio connection and says which one is active: the one the
/// screens show and send through.
///
/// Phase 1 of docs/MULTI_RADIO_DESIGN.md: the app still uses only the first
/// radio, so nothing changes for users yet. Later phases add a switcher and
/// let background radios keep receiving.
class RadioManager extends ChangeNotifier {
  RadioManager(MeshCoreConnector primary, {ConnectorFactory? create})
    : assert(primary.slot.isEmpty, 'the first radio uses slot ""'),
      _radios = [primary],
      _create = create ?? ((slot) => MeshCoreConnector(slot: slot));

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
    final radio = _create('r$n');
    _radios.add(radio);
    notifyListeners();
    return radio;
  }

  /// Makes [radio] the active one. Does nothing if it isn't one of ours.
  void setActive(MeshCoreConnector radio) {
    final index = _radios.indexOf(radio);
    if (index < 0 || index == _active) return;
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
    notifyListeners();
    try {
      await radio.disconnect(manual: true);
      await radio.forgetSavedRadio();
    } finally {
      radio.dispose();
    }
  }
}
