import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:meshcore_open/connector/meshcore_connector.dart';
import 'package:meshcore_open/connector/meshcore_protocol.dart';
import 'package:meshcore_open/models/channel.dart';
import 'package:meshcore_open/models/contact.dart';
import 'package:meshcore_open/services/offline_outbox.dart';
import 'package:meshcore_open/storage/draft_store.dart';
import 'package:meshcore_open/storage/prefs_manager.dart';
import 'package:meshcore_open/storage/secure_prefs.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _sam = Contact(
  publicKey: Uint8List.fromList(List.generate(32, (i) => i + 1)),
  name: 'Sam',
  type: advTypeChat,
  path: Uint8List(0),
  pathLength: 0,
  lastSeen: DateTime(2026, 10, 30),
);
final _hiking = Channel(
  index: 2,
  name: '#hiking',
  psk: Uint8List.fromList(List.filled(16, 2)),
);

class _Radio extends MeshCoreConnector {
  _Radio({super.slot});

  bool connected = false;
  bool loaded = true;
  String self = 'aabbccddeeff';
  final sent = <String>[];

  /// Thrown by the next send, after nothing was recorded as sent.
  Object? failNext;

  /// When set, sends wait on it, like a radio that never answers.
  Completer<void>? hang;

  Future<void> _out(String line) async {
    final error = failNext;
    if (error != null) {
      failNext = null;
      throw error;
    }
    if (hang != null) await hang!.future;
    sent.add(line);
  }

  @override
  bool get isConnected => connected;
  @override
  bool get hasLoadedChannels => loaded;
  @override
  bool get isLoadingContacts => false;
  @override
  bool get isSyncingChannels => false;
  @override
  String get selfPublicKeyHex => self;
  @override
  Contact? getContactByPubKeyHex(String hex) =>
      hex == _sam.publicKeyHex ? _sam : null;
  @override
  List<Channel> get channels => [_hiking];
  @override
  Future<void> sendMessage(
    Contact contact,
    String text, {
    String? originalText,
    String? translatedLanguageCode,
    String? translationModelId,
  }) => _out('${contact.name}:$text');
  @override
  Future<void> sendChannelMessage(
    Channel channel,
    String text, {
    String? originalText,
    String? translatedLanguageCode,
    String? translationModelId,
    bool sign = false,
  }) => _out('${channel.name}:$text');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _Radio radio;
  late DateTime now;
  final samTarget = 'message:${_sam.publicKeyHex}';
  final draft = DraftStore.contactKey('aabbccddeeff', _sam.publicKeyHex);

  OfflineOutbox make() =>
      OfflineOutbox(radio, clock: () => now, spacing: Duration.zero);

  setUp(() async {
    PrefsManager.reset();
    SharedPreferences.setMockInitialValues({});
    await PrefsManager.initialize();
    radio = _Radio();
    now = DateTime(2026, 11, 8, 12);
  });

  test('sends oldest first once the radio is back', () async {
    final outbox = make();
    await outbox.add(samTarget, 'one');
    await outbox.add('channel:2', 'two');
    radio.connected = true;
    await outbox.flush();
    expect(radio.sent, ['Sam:one', '#hiking:two']);
    expect(outbox.entriesFor(samTarget), isEmpty);
  });

  test('each radio keeps its own outbox, encrypted like the first', () async {
    await make().add(samTarget, 'from one');
    final other = _Radio(slot: 'r2')..self = '112233445566';
    OfflineOutbox second() =>
        OfflineOutbox(other, clock: () => now, spacing: Duration.zero);
    await second().add(samTarget, 'from two');
    expect(make().entriesFor(samTarget).single.text, 'from one');
    expect(second().entriesFor(samTarget).single.text, 'from two');
    expect(SecurePrefs.isSensitive('offline_outbox_v1_r2'), isTrue);
    expect(SecurePrefs.isSensitive('offline_outbox_v1_x'), isFalse);
  });

  test('survives an app restart', () async {
    await make().add(samTarget, 'kept');
    radio.self = '';
    final reopened = make();
    expect(reopened.entriesFor(samTarget).single.text, 'kept');
  });

  test('waits until channels and contacts are loaded', () async {
    final outbox = make();
    await outbox.add(samTarget, 'wait');
    radio
      ..connected = true
      ..loaded = false;
    await outbox.flush();
    expect(radio.sent, isEmpty);
    expect(outbox.entriesFor(samTarget), hasLength(1));
  });

  test('another radio does not send it', () async {
    final outbox = make();
    await outbox.add(samTarget, 'mine');
    radio
      ..connected = true
      ..self = '112233445566';
    await outbox.flush();
    expect(radio.sent, isEmpty);
    expect(outbox.entriesFor(samTarget), hasLength(1));
  });

  test('over a day old goes back to the draft', () async {
    final outbox = make();
    await outbox.add(samTarget, 'stale');
    now = now.add(const Duration(hours: 25));
    radio.connected = true;
    await outbox.flush();
    expect(radio.sent, isEmpty);
    expect(DraftStore.load(draft), 'stale');
    expect(outbox.entriesFor(samTarget), isEmpty);
  });

  test('a contact that is gone goes back to the draft', () async {
    final outbox = make();
    final target = 'message:ffff';
    await outbox.add(target, 'nobody');
    radio.connected = true;
    await outbox.flush();
    expect(radio.sent, isEmpty);
    expect(
      DraftStore.load(DraftStore.contactKey('aabbccddeeff', 'ffff')),
      'nobody',
    );
  });

  test('removed messages never send', () async {
    final outbox = make();
    await outbox.add(samTarget, 'cancel me');
    await outbox.remove(outbox.entriesFor(samTarget).single.id);
    radio.connected = true;
    await outbox.flush();
    expect(radio.sent, isEmpty);
  });

  test('with no radio ever seen it refuses', () async {
    radio.self = '';
    expect(await make().add(samTarget, 'x'), isFalse);
  });

  test('a scheduled message waits for its time, even when connected', () async {
    final outbox = make();
    radio.connected = true;
    // Connected, so check() would otherwise send it straight away.
    await outbox.add(
      samTarget,
      'later',
      sendAt: now.add(const Duration(hours: 2)),
    );
    await outbox.flush();
    expect(radio.sent, isEmpty);
    now = now.add(const Duration(hours: 3));
    await outbox.flush();
    expect(radio.sent, ['Sam:later']);
    outbox.dispose();
  });

  test('its 24-hour limit counts from the scheduled time', () async {
    final outbox = make();
    await outbox.add(
      samTarget,
      'next week',
      sendAt: now.add(const Duration(days: 7)),
    );
    now = now.add(const Duration(days: 7, hours: 1));
    radio.connected = true;
    await outbox.flush();
    expect(radio.sent, ['Sam:next week']);
  });

  test('missed by over a day it goes back to the draft', () async {
    final outbox = make();
    await outbox.add(
      samTarget,
      'missed',
      sendAt: now.add(const Duration(hours: 1)),
    );
    now = now.add(const Duration(days: 2));
    radio.connected = true;
    await outbox.flush();
    expect(radio.sent, isEmpty);
    expect(DraftStore.load(draft), 'missed');
  });

  group('send handoff', () {
    test(
      'a send that throws goes back to the draft, flagged, not resent',
      () async {
        final outbox = make();
        await outbox.add(samTarget, 'maybe');
        radio
          ..connected = true
          ..failNext = TimeoutException('no ack');
        await outbox.flush();
        expect(radio.sent, isEmpty);
        expect(outbox.entriesFor(samTarget), isEmpty);
        expect(DraftStore.load(draft), 'maybe');
        expect(outbox.uncertainFor(samTarget).single.entry.text, 'maybe');
        await outbox.flush();
        expect(radio.sent, isEmpty, reason: 'never retried by itself');
      },
    );

    test('one failure does not stop the rest of the queue', () async {
      final outbox = make();
      await outbox.add(samTarget, 'first');
      await outbox.add('channel:2', 'second');
      radio
        ..connected = true
        ..failNext = StateError('Connect your radio first.');
      await outbox.flush();
      expect(radio.sent, ['#hiking:second']);
      expect(DraftStore.load(draft), 'first');
    });

    test('an app stop mid-send returns it to the draft on restart', () async {
      final outbox = make();
      await outbox.add(samTarget, 'in the air');
      radio
        ..connected = true
        ..hang = Completer<void>();
      unawaited(outbox.flush());
      await pumpEventQueue();
      // The app is killed here: the radio never answered.
      radio
        ..hang = null
        ..connected = false;
      final restarted = make();
      await pumpEventQueue();
      expect(restarted.entriesFor(samTarget), isEmpty);
      expect(DraftStore.load(draft), 'in the air');
      expect(restarted.uncertainFor(samTarget), hasLength(1));
      radio.connected = true;
      await restarted.flush();
      expect(radio.sent, isEmpty, reason: 'may already be out');
    });

    test('too long for the radio goes back to the draft unsent', () async {
      final outbox = make();
      final long = 'x' * 200;
      await outbox.add(samTarget, long);
      await outbox.add('channel:2', long);
      radio.connected = true;
      await outbox.flush();
      expect(radio.sent, isEmpty);
      expect(DraftStore.load(draft), long);
      expect(
        outbox.returned.map((r) => r.reason),
        everyElement(OutboxReturnReason.tooLong),
      );
      expect(outbox.uncertainFor(samTarget), isEmpty);
    });

    test('a channel that is gone goes back to the draft', () async {
      final outbox = make();
      await outbox.add('channel:7', 'where');
      radio.connected = true;
      await outbox.flush();
      expect(radio.sent, isEmpty);
      expect(
        DraftStore.load(DraftStore.channelKey('aabbccddeeff', 7)),
        'where',
      );
    });

    test('a finished send is not left half-done after a restart', () async {
      final outbox = make();
      await outbox.add(samTarget, 'done');
      radio.connected = true;
      await outbox.flush();
      final restarted = make();
      await pumpEventQueue();
      expect(restarted.entriesFor(samTarget), isEmpty);
      expect(DraftStore.load(draft), isNull);
      expect(radio.sent, ['Sam:done']);
    });

    test('dismissing clears the note', () async {
      final outbox = make();
      await outbox.add(samTarget, 'x');
      radio
        ..connected = true
        ..failNext = StateError('drop');
      await outbox.flush();
      outbox.dismissReturned(samTarget);
      expect(outbox.uncertainFor(samTarget), isEmpty);
    });
  });
}
