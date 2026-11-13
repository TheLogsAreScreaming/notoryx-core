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

  group('notifications', () {
    test('name the radio only when there is more than one', () {
      final radios = RadioManager(MeshCoreConnector());
      expect(radios.primary.notificationTitle('Sam'), 'Sam');
      final second = radios.add();
      expect(second.notificationTitle('Sam'), 'Sam · #2');
      expect(radios.primary.notificationTitle('Sam'), 'Sam · #1');
    });

    test('use the saved name when not connected', () async {
      final prefs = PrefsManager.instance;
      await const SavedRadio(
        transport: SavedRadioTransport.tcp,
        address: '10.0.0.5:5000',
        name: 'Hill',
      ).save(prefs, slot: 'r2');
      final radios = RadioManager(MeshCoreConnector());
      final second = radios.add();
      expect(second.notificationTitle('#hiking'), '#hiking · Hill');
    });

    test('a notification from another radio switches to it once', () {
      final radios = RadioManager(MeshCoreConnector());
      final second = radios.add();
      expect(radios.radioIn('r2'), second);
      expect(radios.radioIn('r9'), isNull);
      radios.switchFor(second, 'message:r2/abcd', reply: 'on my way');
      expect(radios.active, second);
      expect(radios.takeHandOff(), (
        payload: 'message:r2/abcd',
        reply: 'on my way',
      ));
      expect(radios.takeHandOff(), isNull);
    });

    test('unread on the radio in use is not counted as background', () {
      final radios = RadioManager(MeshCoreConnector())..add();
      expect(radios.backgroundUnread, 0);
    });
  });

  group('remembered radios', () {
    test('added radios come back after a restart', () {
      final prefs = PrefsManager.instance;
      final radios = RadioManager(MeshCoreConnector(), prefs: prefs);
      radios.add();
      radios.add();
      expect(prefs.getStringList(RadioManager.slotsKey), ['r2', 'r3']);
      final again = RadioManager(MeshCoreConnector(), prefs: prefs);
      expect(again.radios.map((r) => r.slot), ['', 'r2', 'r3']);
      expect(again.active, again.primary);
    });

    test('removed radios are forgotten', () async {
      final prefs = PrefsManager.instance;
      final radios = RadioManager(MeshCoreConnector(), prefs: prefs);
      final second = radios.add();
      await radios.remove(second);
      expect(prefs.getStringList(RadioManager.slotsKey), isEmpty);
      expect(
        RadioManager(MeshCoreConnector(), prefs: prefs).hasMultiple,
        isFalse,
      );
    });

    test('bad or duplicate saved slots are ignored', () async {
      final prefs = PrefsManager.instance;
      await prefs.setStringList(RadioManager.slotsKey, [
        '',
        'r2',
        'r2',
        'x',
        'r3',
        'r4',
      ]);
      final radios = RadioManager(MeshCoreConnector(), prefs: prefs);
      expect(radios.radios.map((r) => r.slot), ['', 'r2', 'r3']);
    });

    test('numbers radios in order', () {
      final radios = RadioManager(MeshCoreConnector());
      final second = radios.add();
      expect(radios.numberOf(radios.primary), 1);
      expect(radios.numberOf(second), 2);
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
