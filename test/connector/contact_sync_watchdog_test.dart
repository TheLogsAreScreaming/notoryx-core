import 'dart:convert';
import 'dart:typed_data';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meshcore_open/connector/meshcore_connector.dart';
import 'package:meshcore_open/connector/meshcore_protocol.dart';
import 'package:meshcore_open/models/contact.dart';
import 'package:meshcore_open/storage/prefs_manager.dart';

Uint8List _key(int seed) => Uint8List.fromList(
  List.generate(32, (i) => (seed * 31 + i * 7) & 0xFF | 1),
);

Contact _contact(int seed, String name) => Contact(
  publicKey: _key(seed),
  name: name,
  type: advTypeChat,
  pathLength: -1,
  path: Uint8List(0),
  lastSeen: DateTime.now(),
);

/// A RESP_CODE_CONTACT frame as the radio sends it.
List<int> _contactFrame(int seed, String name) {
  final nameBytes = utf8.encode(name);
  return [
    respCodeContact,
    ..._key(seed),
    advTypeChat,
    0, // flags
    0xFF, // path unknown
    ...List.filled(64, 0),
    ...nameBytes,
    ...List.filled(32 - nameBytes.length, 0),
    ...List.filled(16, 0), // last advert, lat, lon, lastmod
  ];
}

class _Radio extends MeshCoreConnector {
  final sent = <Uint8List>[];
  @override
  bool get isConnected => true;
  @override
  Future<void> sendFrame(
    Uint8List frame, {
    String? channelSendQueueId,
    bool expectsGenericAck = false,
    bool waitForGenericAck = false,
  }) async => sent.add(frame);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _Radio radio;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    PrefsManager.reset();
    await PrefsManager.initialize();
    MeshCoreConnector.contactSyncSilence = const Duration(milliseconds: 60);
    radio = _Radio()
      ..debugSetContacts([_contact(1, 'Sam'), _contact(2, 'Alex')]);
  });
  tearDown(() => radio.dispose());

  // The watchdog runs on timers, so these tests use a fake clock. Real
  // delays raced the 60 ms silence window when the machine was busy.
  void sync(FakeAsync async, {bool preserveExisting = false}) {
    radio.getContacts(preserveExisting: preserveExisting);
    async.flushMicrotasks();
  }

  void wait(FakeAsync async, int ms) =>
      async.elapse(Duration(milliseconds: ms));

  int requests() => radio.sent.where((f) => f[0] == cmdGetContacts).length;

  test('saved contacts stay visible while the radio sends its list', () {
    fakeAsync((async) {
      sync(async);
      expect(radio.isLoadingContacts, isTrue);
      expect(radio.contacts.map((c) => c.name), ['Sam', 'Alex']);
    });
  });

  test('a silent radio is asked once more, then the sync gives up', () {
    fakeAsync((async) {
      sync(async);
      expect(requests(), 1);
      wait(async, 90);
      expect(requests(), 2);
      expect(radio.isLoadingContacts, isTrue);
      wait(async, 90);
      expect(radio.isLoadingContacts, isFalse);
      expect(radio.contactSyncStalled, isTrue);
      expect(radio.hasLoadedContacts, isTrue);
      expect(radio.contacts, hasLength(2), reason: 'nothing is dropped');

      radio.retryContactSync();
      async.flushMicrotasks();
      expect(radio.contactSyncStalled, isFalse);
      expect(radio.isLoadingContacts, isTrue);
    });
  });

  test('contacts arriving keep the sync alive', () {
    fakeAsync((async) {
      sync(async);
      for (var i = 0; i < 4; i++) {
        wait(async, 40);
        radio.handleFrameForTest(_contactFrame(1, 'Sam'));
      }
      expect(radio.isLoadingContacts, isTrue);
      expect(requests(), 1);
    });
  });

  test('a complete sync drops contacts the radio no longer has', () {
    fakeAsync((async) {
      sync(async);
      radio.handleFrameForTest([respCodeContactsStart, 1, 0, 0, 0]);
      radio.handleFrameForTest(_contactFrame(1, 'Sam'));
      radio.handleFrameForTest([respCodeEndOfContacts]);
      expect(radio.isLoadingContacts, isFalse);
      expect(radio.contactSyncStalled, isFalse);
      expect(radio.contacts.map((c) => c.name), ['Sam']);
      wait(async, 90);
      expect(
        requests(),
        1,
        reason: 'the watchdog stops after the sync completes',
      );
    });
  });

  test('a partial (refresh) sync keeps contacts it did not mention', () {
    fakeAsync((async) {
      sync(async, preserveExisting: true);
      radio.handleFrameForTest(_contactFrame(1, 'Sam'));
      radio.handleFrameForTest([respCodeEndOfContacts]);
      expect(radio.contacts, hasLength(2));
    });
  });
}
