import 'package:flutter_test/flutter_test.dart';
import 'package:meshcore_open/services/notification_service.dart';

void main() {
  test('the first radio keeps its payloads unchanged', () {
    expect(NotificationService.tagged('', 'abcd'), 'abcd');
    expect(NotificationService.untag('message:abcd'), (
      radio: '',
      payload: 'message:abcd',
    ));
    expect(NotificationService.untag('channel:3'), (
      radio: '',
      payload: 'channel:3',
    ));
  });

  test('other radios tag the id and untag back', () {
    final payload = 'message:${NotificationService.tagged('r2', 'abcd')}';
    expect(payload, 'message:r2/abcd');
    expect(NotificationService.untag(payload), (
      radio: 'r2',
      payload: 'message:abcd',
    ));
    expect(NotificationService.untag('channel:r3/0'), (
      radio: 'r3',
      payload: 'channel:0',
    ));
  });

  test('a payload about no radio has no radio', () {
    expect(NotificationService.untag('batch'), (radio: null, payload: 'batch'));
  });

  test('only real radio slots count as tags', () {
    expect(NotificationService.untag('message:x/abcd'), (
      radio: '',
      payload: 'message:x/abcd',
    ));
    expect(NotificationService.untag('message:/abcd'), (
      radio: '',
      payload: 'message:/abcd',
    ));
  });
}
