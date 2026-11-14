import 'package:flutter_test/flutter_test.dart';
import 'package:meshcore_open/services/background_service.dart';

class _Counting extends BackgroundService {
  int starts = 0;
  int stops = 0;

  @override
  Future<void> start() async => starts++;

  @override
  Future<void> stop() async => stops++;
}

void main() {
  test('the service stops only when the last radio lets go', () async {
    final shared = _Counting();
    final first = shared.forRadio('');
    final second = shared.forRadio('r2');
    await first.start();
    await second.start();
    expect(shared.starts, 2);
    expect(shared.holders, {'', 'r2'});
    await second.stop();
    expect(shared.stops, 0);
    expect(shared.holders, {''});
    await first.stop();
    expect(shared.stops, 1);
    expect(shared.holders, isEmpty);
  });

  test('one radio behaves as before', () async {
    final shared = _Counting();
    final only = shared.forRadio('');
    await only.start();
    await only.stop();
    await only.stop();
    expect(shared.starts, 1);
    expect(shared.stops, 2);
  });
}
