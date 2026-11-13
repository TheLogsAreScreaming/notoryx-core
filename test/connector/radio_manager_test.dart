import 'package:flutter_test/flutter_test.dart';
import 'package:meshcore_open/connector/meshcore_connector.dart';
import 'package:meshcore_open/connector/radio_manager.dart';
import 'package:meshcore_open/models/saved_radio.dart';
import 'package:meshcore_open/storage/prefs_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    PrefsManager.reset();
    await PrefsManager.initialize();
  });
  tearDown(PrefsManager.reset);

  group('RadioManager', () {
    test('starts with the first radio active', () {
      final first = MeshCoreConnector();
      final radios = RadioManager(first);
      expect(radios.radios, [first]);
      expect(radios.active, first);
      expect(radios.primary, first);
      expect(radios.hasMultiple, isFalse);
      expect(radios.canAdd, isTrue);
    });

    test('adds radios in free slots up to the limit', () {
      final radios = RadioManager(MeshCoreConnector());
      final second = radios.add();
      final third = radios.add();
      expect([second.slot, third.slot], ['r2', 'r3']);
      expect(radios.hasMultiple, isTrue);
      expect(radios.canAdd, isFalse);
      expect(radios.add, throwsStateError);
      expect(radios.active, radios.primary);
    });

    test('switches the active radio and notifies', () {
      final radios = RadioManager(MeshCoreConnector());
      final second = radios.add();
      var notified = 0;
      radios.addListener(() => notified++);
      radios.setActive(second);
      expect(radios.active, second);
      radios.setActive(second);
      radios.setActive(MeshCoreConnector(slot: 'r9'));
      expect(radios.active, second);
      expect(notified, 1);
    });

    test('removing the active radio falls back to the first', () async {
      final radios = RadioManager(MeshCoreConnector());
      final second = radios.add();
      radios.setActive(second);
      await radios.remove(second);
      expect(radios.radios, [radios.primary]);
      expect(radios.active, radios.primary);
    });

    test('removing another radio keeps the active one', () async {
      final radios = RadioManager(MeshCoreConnector());
      final second = radios.add();
      final third = radios.add();
      radios.setActive(third);
      await radios.remove(second);
      expect(radios.active, third);
      expect(radios.add().slot, 'r2');
    });

    test('the first radio cannot be removed', () async {
      final radios = RadioManager(MeshCoreConnector());
      await radios.remove(radios.primary);
      expect(radios.radios.length, 1);
    });
  });

  group('saved radio slots', () {
    const base = SavedRadio(
      transport: SavedRadioTransport.bluetooth,
      address: 'AA:BB',
      name: 'Base',
    );
    const handheld = SavedRadio(
      transport: SavedRadioTransport.tcp,
      address: '10.0.0.5:5000',
      name: 'Hill',
    );

    test('the first slot uses the keys earlier builds wrote', () async {
      final prefs = PrefsManager.instance;
      await base.save(prefs);
      expect(prefs.getString(SavedRadio.addressKey), 'AA:BB');
      expect(SavedRadio.load(prefs), base);
    });

    test('each slot keeps its own radio', () async {
      final prefs = PrefsManager.instance;
      await base.save(prefs);
      await handheld.save(prefs, slot: 'r2');
      expect(SavedRadio.load(prefs), base);
      expect(SavedRadio.load(prefs, slot: 'r2'), handheld);
      await SavedRadio.clear(prefs, slot: 'r2');
      expect(SavedRadio.load(prefs, slot: 'r2'), isNull);
      expect(SavedRadio.load(prefs), base);
    });

    test('a connector reads its own slot', () async {
      final prefs = PrefsManager.instance;
      await base.save(prefs);
      await handheld.save(prefs, slot: 'r2');
      expect(MeshCoreConnector().savedRadio, base);
      expect(MeshCoreConnector(slot: 'r2').savedRadio, handheld);
      expect(MeshCoreConnector(slot: 'r3').savedRadio, isNull);
    });
  });
}
