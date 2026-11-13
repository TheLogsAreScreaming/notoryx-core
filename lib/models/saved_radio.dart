import 'package:shared_preferences/shared_preferences.dart';

/// Transport used to reach a saved radio. Mirrors the connector's transports
/// without importing it, so the model stays free of BLE/USB dependencies.
enum SavedRadioTransport { bluetooth, usb, tcp }

/// The last radio the app connected to, remembered so the dashboard can offer
/// "Reconnect to `name`". Holds only a transport address (BLE remote id, USB
/// port name or TCP host:port) and a display name; never keys or secrets.
class SavedRadio {
  const SavedRadio({
    required this.transport,
    required this.address,
    required this.name,
  });

  static const String transportKey = 'last_radio_transport';
  static const String addressKey = 'last_radio_address';
  static const String nameKey = 'last_radio_name';

  /// The preference key for [base] in [slot]: the plain key for the first
  /// radio (slot ''), so earlier builds' saved radio still loads.
  static String keyFor(String base, String slot) =>
      slot.isEmpty ? base : '${base}_$slot';

  final SavedRadioTransport transport;
  final String address;
  final String name;

  /// Reads the saved radio, or null when nothing (or something unreadable) is
  /// stored.
  static SavedRadio? load(SharedPreferences prefs, {String slot = ''}) {
    final transportName = prefs.getString(keyFor(transportKey, slot));
    final address = prefs.getString(keyFor(addressKey, slot))?.trim();
    if (transportName == null || address == null || address.isEmpty) {
      return null;
    }
    final transport = SavedRadioTransport.values
        .where((t) => t.name == transportName)
        .firstOrNull;
    if (transport == null) return null;
    if (transport == SavedRadioTransport.tcp && parseTcp(address) == null) {
      return null;
    }
    final name = prefs.getString(keyFor(nameKey, slot))?.trim();
    return SavedRadio(
      transport: transport,
      address: address,
      name: name == null || name.isEmpty ? address : name,
    );
  }

  Future<void> save(SharedPreferences prefs, {String slot = ''}) async {
    await prefs.setString(keyFor(transportKey, slot), transport.name);
    await prefs.setString(keyFor(addressKey, slot), address);
    await prefs.setString(keyFor(nameKey, slot), name);
  }

  static Future<void> clear(SharedPreferences prefs, {String slot = ''}) async {
    await prefs.remove(keyFor(transportKey, slot));
    await prefs.remove(keyFor(addressKey, slot));
    await prefs.remove(keyFor(nameKey, slot));
  }

  /// Splits a saved "host:port" TCP address. The last colon separates the
  /// port so bracket-less IPv6 hosts still parse.
  static ({String host, int port})? parseTcp(String address) {
    final split = address.lastIndexOf(':');
    if (split <= 0 || split == address.length - 1) return null;
    final host = address.substring(0, split).trim();
    final port = int.tryParse(address.substring(split + 1));
    if (host.isEmpty || port == null || port < 1 || port > 65535) return null;
    return (host: host, port: port);
  }

  @override
  bool operator ==(Object other) =>
      other is SavedRadio &&
      other.transport == transport &&
      other.address == address &&
      other.name == name;

  @override
  int get hashCode => Object.hash(transport, address, name);
}
