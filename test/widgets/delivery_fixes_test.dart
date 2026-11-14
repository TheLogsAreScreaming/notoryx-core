// Which fixes are offered for each way a message can fail.
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:meshcore_open/connector/meshcore_protocol.dart';
import 'package:meshcore_open/models/contact.dart';
import 'package:meshcore_open/models/delivery_diagnosis.dart';
import 'package:meshcore_open/models/message.dart';
import 'package:meshcore_open/widgets/delivery_fix.dart';
import 'package:meshcore_open/widgets/delivery_sheet.dart';

Contact _contact({
  int pathLength = 2,
  DateTime? lastSeen,
  int? pathOverride,
  List<int> path = const [0xA1, 0x3F],
}) => Contact(
  publicKey: Uint8List.fromList(List.filled(32, 7)),
  name: 'Sam',
  type: advTypeChat,
  pathLength: pathLength,
  path: Uint8List.fromList(path),
  lastSeen: lastSeen ?? DateTime(2026, 11, 14, 9),
  pathOverride: pathOverride,
);

List<DeliveryFix> _fixes({
  MessageStatus status = MessageStatus.failed,
  int retries = 6,
  int path = 2,
  int flood = 2,
  DateTime? lastSeen,
}) => deliveryFixesFor(
  diagnoseDelivery(
    Message(
      senderKey: Uint8List(32),
      text: 'At camp',
      timestamp: DateTime(2026, 11, 14, 9),
      isOutgoing: true,
      status: status,
      retryCount: retries,
      sentAt: retries < 0 ? null : DateTime(2026, 11, 14, 9, 0, 2),
      pathLength: path,
      pathBytes: path < 0 ? Uint8List(0) : Uint8List.fromList([0xA1, 0x3F]),
    ),
    maxRetries: 5,
    floodAttempts: flood,
    contact: _contact(lastSeen: lastSeen),
    now: DateTime(2026, 11, 14, 9, 5),
  ),
);

void main() {
  test('nothing to fix while it is going or got through', () {
    expect(_fixes(status: MessageStatus.delivered), isEmpty);
    expect(_fixes(status: MessageStatus.pending, retries: 1), isEmpty);
  });

  test('never taken by the radio: only send again', () {
    final fixes = deliveryFixesFor(
      diagnoseDelivery(
        Message(
          senderKey: Uint8List(32),
          text: 'At camp',
          timestamp: DateTime(2026, 11, 14, 9),
          isOutgoing: true,
          status: MessageStatus.failed,
        ),
        maxRetries: 5,
        floodAttempts: 2,
      ),
    );
    expect(fixes, [DeliveryFix.retry]);
  });

  test('flood off: flood first, then retry or pick a route', () {
    expect(_fixes(flood: 0), [
      DeliveryFix.retryByFlood,
      DeliveryFix.retry,
      DeliveryFix.pickRoute,
    ]);
  });

  test('contact quiet: flood reaches furthest', () {
    expect(_fixes(lastSeen: DateTime(2026, 11, 13)), [
      DeliveryFix.retryByFlood,
      DeliveryFix.retry,
    ]);
  });

  test('already flooded: no flood offer again', () {
    expect(_fixes(path: -1), [DeliveryFix.retry, DeliveryFix.pickRoute]);
    expect(_fixes(path: -1, lastSeen: DateTime(2026, 11, 13)), [
      DeliveryFix.retry,
    ]);
  });

  test('a route counts as changed only when it would send differently', () {
    final a = _contact();
    expect(sameRoute(a, _contact()), isTrue);
    expect(sameRoute(a, _contact(pathOverride: -1)), isFalse);
    expect(sameRoute(a, _contact(path: const [0xA1])), isFalse);
    expect(sameRoute(a, _contact(pathLength: -1)), isFalse);
  });
}
