import 'package:flutter_test/flutter_test.dart';
import 'package:meshcore_open/services/notification_deduper.dart';

void main() {
  final sent = DateTime.utc(2026, 11, 14, 12, 0, 0);
  var now = sent;
  NotificationDeduper deduper({int capacity = 512}) =>
      NotificationDeduper(capacity: capacity, clock: () => now);

  String dm({String radio = '', DateTime? at, String text = 'hello'}) =>
      NotificationDeduper.directKey(
        radio: radio,
        senderKeyHex: 'abcd',
        sentAt: at ?? sent,
        text: text,
      );

  setUp(() => now = sent);

  test('a message read again after a reconnect alerts once', () {
    final d = deduper();
    final queue = [dm(text: 'one'), dm(text: 'two'), dm(text: 'three')];

    final firstSync = queue.where(d.firstSighting).length;
    final secondSync = queue.where(d.firstSighting).length;

    expect(firstSync, 3);
    expect(secondSync, 0);
  });

  test('a sender retry with the same timestamp does not alert again', () {
    final d = deduper();
    expect(d.firstSighting(dm()), isTrue);
    now = now.add(const Duration(seconds: 20));
    expect(d.firstSighting(dm()), isFalse);
  });

  test('the same words sent again later still alert', () {
    final d = deduper();
    expect(d.firstSighting(dm(text: 'ok')), isTrue);
    final later = sent.add(const Duration(minutes: 2));
    expect(d.firstSighting(dm(text: 'ok', at: later)), isTrue);
  });

  test('a channel post heard through two repeaters alerts once', () {
    final d = deduper();
    String post() => NotificationDeduper.channelKey(
      radio: '',
      channelIndex: 0,
      senderName: 'Ridge',
      sentAt: sent,
      text: 'net check-in',
    );
    expect(d.firstSighting(post()), isTrue);
    expect(d.firstSighting(post()), isFalse);
  });

  test('each radio, channel and sender is kept apart', () {
    final d = deduper();
    expect(d.firstSighting(dm()), isTrue);
    expect(d.firstSighting(dm(radio: 'r2')), isTrue);
    expect(
      d.firstSighting(
        NotificationDeduper.channelKey(
          radio: '',
          channelIndex: 1,
          senderName: 'abcd',
          sentAt: sent,
          text: 'hello',
        ),
      ),
      isTrue,
    );
  });

  test('a message is forgotten after the window', () {
    final d = deduper();
    expect(d.firstSighting(dm()), isTrue);
    now = now.add(const Duration(hours: 1, minutes: 1));
    expect(d.firstSighting(dm()), isTrue);
  });

  test('the oldest message is dropped when full', () {
    final d = deduper(capacity: 2);
    expect(d.firstSighting(dm(text: 'a')), isTrue);
    expect(d.firstSighting(dm(text: 'b')), isTrue);
    expect(d.firstSighting(dm(text: 'c')), isTrue);
    expect(d.firstSighting(dm(text: 'a')), isTrue);
    expect(d.firstSighting(dm(text: 'c')), isFalse);
  });

  test('clear forgets everything', () {
    final d = deduper();
    expect(d.firstSighting(dm()), isTrue);
    d.clear();
    expect(d.firstSighting(dm()), isTrue);
  });
}
