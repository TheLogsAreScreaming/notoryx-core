// Which route an ACK credits. Delivery times teach the timeout model, and
// path results rank routes, so both must use the route of the attempt the ACK
// belongs to, and neither may guess when the ACK can't be tied to one route.
import 'dart:async';
import 'dart:typed_data';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meshcore_open/models/contact.dart';
import 'package:meshcore_open/models/message.dart';
import 'package:meshcore_open/models/path_selection.dart';
import 'package:meshcore_open/services/message_retry_service.dart';

Contact _contact({int pathLength = -1, List<int> path = const []}) => Contact(
  publicKey: Uint8List.fromList(List<int>.generate(32, (i) => 0xAA + i)),
  name: 'Test',
  type: 1,
  pathLength: pathLength,
  path: Uint8List.fromList(path),
  lastSeen: DateTime(2026),
);

void main() {
  final selfKey = Uint8List(32);

  /// Runs [body] with a retry service whose sends, deliveries and route
  /// credits are recorded.
  void withService(
    void Function(
      FakeAsync time,
      MessageRetryService service,
      List<({int attempt, int timestamp})> sends,
      Map<String, Message> latest,
      List<int> observedHops,
      List<PathSelection> credited,
    )
    body,
  ) {
    fakeAsync((time) {
      final service = MessageRetryService();
      final sends = <({int attempt, int timestamp})>[];
      final latest = <String, Message>{};
      final observedHops = <int>[];
      final credited = <PathSelection>[];
      service.initialize(
        RetryServiceConfig(
          sendMessage: (_, _, attempt, timestamp) async {
            sends.add((attempt: attempt, timestamp: timestamp));
            return true;
          },
          addMessage: (_, m) => latest[m.messageId] = m,
          updateMessage: (m) => latest[m.messageId] = m,
          getSelfPublicKey: () => selfKey,
          calculateTimeout:
              (_, _, {String? contactKey, int? deviceTimeoutMs}) => 20,
          onDeliveryObserved: (_, hops, _, _) => observedHops.add(hops),
          recordPathResult: (_, selection, success, _) {
            if (success) credited.add(selection);
          },
        ),
      );
      body(time, service, sends, latest, observedHops, credited);
      service.dispose();
    });
  }

  int ackHash(List<({int attempt, int timestamp})> sends, int attempt) =>
      MessageRetryService.computeExpectedAckHash(
        sends.first.timestamp,
        attempt,
        'hello',
        selfKey,
      );

  /// Confirms attempt [attempt] was sent, then lets it time out.
  void sentThenTimeOut(
    FakeAsync time,
    MessageRetryService service,
    List<({int attempt, int timestamp})> sends,
    int attempt,
  ) {
    expect(sends.map((s) => s.attempt).last, attempt);
    service.updateMessageFromSent(ackHash(sends, attempt), 20);
    // Timeout, then the backoff before the next attempt.
    time.elapse(Duration(milliseconds: 25 + 1000 * (1 << (attempt + 1))));
  }

  test('a late ACK teaches the route of the attempt it acks', () {
    withService((time, service, sends, latest, observedHops, credited) {
      unawaited(
        service.sendMessageWithRetry(
          contact: _contact(pathLength: 2, path: [0x11, 0x22]),
          text: 'hello',
        ),
      );
      time.flushMicrotasks();

      // The direct route stops being known, so the retry floods.
      service.updatePendingContact(_contact());
      sentThenTimeOut(time, service, sends, 0);
      expect(sends.map((s) => s.attempt), [0, 1]);
      expect(latest.values.single.pathLength, -1);

      // The ACK for the first, direct attempt arrives late.
      service.handleAckReceived(ackHash(sends, 0), 700);

      expect(latest.values.single.status, MessageStatus.delivered);
      expect(observedHops, [2], reason: 'learned as two hops, not flood');
      expect(credited.single.useFlood, false);
      expect(credited.single.pathBytes, [0x11, 0x22]);
    });
  });

  test('an ACK two routes could have earned credits neither', () {
    withService((time, service, sends, latest, observedHops, credited) {
      unawaited(
        service.sendMessageWithRetry(
          contact: _contact(pathLength: 2, path: [0x11, 0x22]),
          text: 'hello',
        ),
      );
      time.flushMicrotasks();
      service.updatePendingContact(_contact());

      // Attempts 0 (direct) and 4 (flood) share an ACK hash.
      for (var attempt = 0; attempt < 4; attempt++) {
        sentThenTimeOut(time, service, sends, attempt);
      }
      expect(sends.map((s) => s.attempt).last, 4);
      service.updateMessageFromSent(ackHash(sends, 4), 20);
      expect(ackHash(sends, 4), ackHash(sends, 0));

      service.handleAckReceived(ackHash(sends, 4), 900);

      expect(latest.values.single.status, MessageStatus.delivered);
      expect(observedHops, isEmpty);
      expect(credited, isEmpty);
    });
  });
}
