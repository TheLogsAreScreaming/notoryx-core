// SOS behaviour over its full hour: repeats, the send cap, losing the radio
// part way through, acknowledgement and stopping. Time is moved forward with
// fake_async and a matching clock, so nothing here waits in real time.
import 'dart:async';
import 'dart:typed_data';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meshcore_open/connector/meshcore_connector.dart';
import 'package:meshcore_open/connector/meshcore_protocol.dart';
import 'package:meshcore_open/models/channel.dart';
import 'package:meshcore_open/models/contact.dart';
import 'package:meshcore_open/models/field_ops.dart';
import 'package:meshcore_open/models/message.dart';
import 'package:meshcore_open/services/field_ops_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Radio extends MeshCoreConnector {
  bool connected = true;

  /// When set, direct sends throw, as a radio that drops the frame would.
  bool failDirect = false;
  final stream = StreamController<Message>.broadcast();
  final sent = <Message>[];
  final channelSends = <String>[];

  Contact _contact(int fill, String name) => Contact(
    publicKey: Uint8List.fromList(List.filled(32, fill)),
    name: name,
    type: advTypeChat,
    pathLength: -1,
    path: Uint8List(0),
    lastSeen: DateTime(2026),
  );
  late final person = _contact(7, 'Trail partner');
  late final stranger = _contact(8, 'Someone else');
  final team = Channel(
    index: 2,
    name: '#search-team',
    psk: Uint8List.fromList(List.filled(16, 9)),
  );

  /// SOS texts sent, direct and channel together.
  int get sosSends =>
      sent.where((m) => isSosText(m.text)).length +
      channelSends.where((t) => t.contains(sosTag)).length;

  @override
  bool get isConnected => connected;
  @override
  bool get isLoadingContacts => false;
  @override
  List<Contact> get contacts => [person, stranger];
  @override
  List<Channel> get channels => [team];
  @override
  Stream<Message> get receivedDirectMessages => stream.stream;
  @override
  List<Message> getMessages(Contact c) => sent;
  @override
  Future<void> sendMessage(
    Contact contact,
    String text, {
    String? originalText,
    String? translatedLanguageCode,
    String? translationModelId,
  }) async {
    if (failDirect) throw StateError('radio busy');
    sent.add(
      Message(
        senderKey: contact.publicKey,
        text: text,
        timestamp: DateTime(2026),
        isOutgoing: true,
        status: MessageStatus.pending,
      ),
    );
  }

  @override
  Future<void> sendChannelMessage(
    Channel channel,
    String text, {
    String? originalText,
    String? translatedLanguageCode,
    String? translationModelId,
    bool sign = false,
  }) async {
    channelSends.add('${channel.name}: $text');
  }

  void reply(Contact from, String text) => stream.add(
    Message(
      senderKey: from.publicKey,
      text: text,
      timestamp: DateTime(2026),
      isOutgoing: false,
    ),
  );
}

/// Runs [body] with a loaded service whose clock follows fake time.
void _withSos(
  void Function(FakeAsync time, _Radio radio, FieldOpsService ops) body, {
  bool withChannel = true,
}) {
  fakeAsync((time) {
    SharedPreferences.setMockInitialValues({});
    final start = DateTime.utc(2026, 11, 14, 12);
    final radio = _Radio();
    final ops = FieldOpsService(radio, clock: () => start.add(time.elapsed));
    unawaited(ops.load());
    time.flushMicrotasks();
    unawaited(
      ops.configureTrip(
        TripPlan(
          members: [radio.person.publicKeyHex],
          sosChannel: withChannel ? 2 : -1,
        ),
      ),
    );
    time.flushMicrotasks();
    body(time, radio, ops);
    ops.dispose();
    unawaited(radio.stream.close());
    radio.dispose();
    time.flushMicrotasks();
  });
}

void _start(FakeAsync time, FieldOpsService ops) {
  unawaited(ops.startSos());
  time.flushMicrotasks();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('repeats every five minutes, not sooner', () {
    _withSos((time, radio, ops) {
      _start(time, ops);
      expect(ops.sos.sends, 1);
      expect(radio.sent, hasLength(1));
      expect(radio.channelSends, hasLength(1));

      time.elapse(const Duration(minutes: 4, seconds: 50));
      expect(ops.sos.sends, 1, reason: 'no repeat before five minutes');

      time.elapse(const Duration(seconds: 20));
      expect(ops.sos.sends, 2);
      expect(radio.sent, hasLength(2));
      expect(radio.channelSends, hasLength(2));
    });
  });

  test('stops sending after twelve, but stays shown', () {
    _withSos((time, radio, ops) {
      _start(time, ops);
      time.elapse(const Duration(hours: 2));
      expect(ops.sos.sends, sosMaxSends);
      expect(radio.sent, hasLength(sosMaxSends));
      expect(radio.channelSends, hasLength(sosMaxSends));
      expect(ops.sos.active, true);
      expect(ops.sos.nextSendAt, isNull);
      expect(
        ops.entries.where((e) => e.text.contains('repeats finished')),
        hasLength(1),
      );
    });
  });

  test('losing the radio holds the repeat without using one up', () {
    _withSos((time, radio, ops) {
      _start(time, ops);
      radio.connected = false;
      time.elapse(const Duration(minutes: 20));
      expect(ops.sos.sends, 1, reason: 'nothing can be sent while down');
      expect(ops.sos.active, true);

      radio.connected = true;
      // The overdue repeat goes out on the next 15-second check, not after
      // another full five minutes.
      time.elapse(const Duration(seconds: 15));
      expect(ops.sos.sends, 2);
      expect(radio.sent.last.text, startsWith(sosTag));
    });
  });

  test('a reply from a trip contact stops the repeats', () {
    _withSos((time, radio, ops) {
      _start(time, ops);
      radio.reply(radio.person, 'Coming');
      time.flushMicrotasks();
      expect(ops.sos.acknowledgedBy, 'Trail partner');

      time.elapse(const Duration(hours: 1));
      expect(ops.sos.sends, 1);
      expect(radio.sosSends, 2, reason: 'the first direct and channel send');
      expect(ops.sos.active, true, reason: 'only the sender ends an SOS');
    });
  });

  test('a reply from someone outside the trip does not stop it', () {
    _withSos((time, radio, ops) {
      _start(time, ops);
      radio.reply(radio.stranger, 'ok');
      time.flushMicrotasks();
      expect(ops.sos.acknowledgedBy, isNull);

      time.elapse(const Duration(minutes: 5));
      expect(ops.sos.sends, 2);
    });
  });

  test('stopping ends the repeats; all clear goes out once', () {
    _withSos((time, radio, ops) {
      _start(time, ops);
      unawaited(ops.stopSos(allClear: true));
      time.flushMicrotasks();
      expect(ops.sos.active, false);
      expect(radio.sent.last.text, startsWith('$sosTag All clear'));
      expect(radio.channelSends.last, contains('All clear'));
      final after = radio.sent.length + radio.channelSends.length;

      time.elapse(const Duration(hours: 1));
      expect(radio.sent.length + radio.channelSends.length, after);
    });
  });

  test('stopping without all clear sends nothing more', () {
    _withSos((time, radio, ops) {
      _start(time, ops);
      unawaited(ops.stopSos());
      time.flushMicrotasks();
      time.elapse(const Duration(hours: 1));
      expect(radio.sent, hasLength(1));
      expect(radio.channelSends, hasLength(1));
    });
  });

  test('pressing SOS again while it runs does not send twice', () {
    _withSos((time, radio, ops) {
      _start(time, ops);
      _start(time, ops);
      expect(ops.sos.sends, 1);
      expect(radio.sent, hasLength(1));
    });
  });

  test('two checks at once send one SOS', () {
    _withSos((time, radio, ops) {
      _start(time, ops);
      // Hold the timer's own repeat back so the overdue one is left for us.
      radio.connected = false;
      time.elapse(const Duration(minutes: 6));
      radio.connected = true;
      // Due now. Two checks racing must not both send.
      unawaited(ops.sosTick());
      unawaited(ops.sosTick());
      time.flushMicrotasks();
      expect(ops.sos.sends, 2);
      expect(radio.sent, hasLength(2));
    });
  });

  test('a contact the radio cannot reach still leaves the channel SOS', () {
    _withSos((time, radio, ops) {
      radio.failDirect = true;
      _start(time, ops);
      expect(radio.channelSends.single, contains(sosTag));
      expect(
        ops.entries.where((e) => e.kind == 'sos' && e.status == 'failed'),
        hasLength(1),
      );

      // The failure doesn't end the SOS: the next repeat tries again.
      radio.failDirect = false;
      time.elapse(const Duration(minutes: 5));
      expect(ops.sos.sends, 2);
      expect(radio.sent.single.text, startsWith(sosTag));
    });
  });

  test('works with only an SOS channel, no trip contacts', () {
    _withSos((time, radio, ops) {
      unawaited(ops.configureTrip(const TripPlan(sosChannel: 2)));
      time.flushMicrotasks();
      expect(ops.sosUnavailable, isNull);
      _start(time, ops);
      time.elapse(const Duration(minutes: 5));
      expect(radio.sent, isEmpty);
      expect(radio.channelSends, hasLength(2));
    });
  });

  test('closing the app stops the timer', () {
    fakeAsync((time) {
      SharedPreferences.setMockInitialValues({});
      final start = DateTime.utc(2026, 11, 14, 12);
      final radio = _Radio();
      final ops = FieldOpsService(radio, clock: () => start.add(time.elapsed));
      unawaited(ops.load());
      time.flushMicrotasks();
      unawaited(
        ops.configureTrip(TripPlan(members: [radio.person.publicKeyHex])),
      );
      time.flushMicrotasks();
      _start(time, ops);
      ops.dispose();
      time.elapse(const Duration(hours: 1));
      expect(radio.sent, hasLength(1));
      unawaited(radio.stream.close());
      radio.dispose();
      time.flushMicrotasks();
    });
  });

  test('the SOS this app sends is one the relay recognises', () {
    final at = DateTime.utc(2026, 11, 14, 12);
    for (final text in [
      sosText(at),
      sosText(at, latitude: 35.2, longitude: -80.8, battery: 5),
      sosAllClearText(at),
    ]) {
      expect(isSosText(text), true, reason: text);
    }
  });
}
