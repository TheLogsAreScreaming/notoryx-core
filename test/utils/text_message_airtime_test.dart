import 'package:flutter_test/flutter_test.dart';
import 'package:meshcore_open/utils/lora_airtime.dart';

void main() {
  test('returns null until the radio settings are known', () {
    expect(estimateTextMessageAirtime(textBytes: 10), isNull);
    expect(
      estimateTextMessageAirtime(
        textBytes: 10,
        spreadingFactor: 10,
        bandwidthHz: 250000,
      ),
      isNull,
    );
  });

  test('accepts firmware 1..4 and 5..8 coding rates alike', () {
    final a = estimateTextMessageAirtime(
      textBytes: 40,
      spreadingFactor: 10,
      bandwidthHz: 250000,
      codingRate: 1,
    );
    final b = estimateTextMessageAirtime(
      textBytes: 40,
      spreadingFactor: 10,
      bandwidthHz: 250000,
      codingRate: 5,
    );
    expect(a, isNotNull);
    expect(a, b);
  });

  test('includes the message overhead and grows with length', () {
    final empty = estimateTextMessageAirtime(
      textBytes: 0,
      spreadingFactor: 10,
      bandwidthHz: 250000,
      codingRate: 5,
    )!;
    final direct = loraTimeOnAir(
      payloadBytes: kTextMessageOverheadBytes,
      spreadingFactor: 10,
      bandwidthHz: 250000,
      codingRate: 5,
    );
    expect(empty, direct);
    final long = estimateTextMessageAirtime(
      textBytes: 120,
      spreadingFactor: 10,
      bandwidthHz: 250000,
      codingRate: 5,
    )!;
    expect(long > empty, isTrue);
  });

  test('rejects impossible settings instead of asserting', () {
    expect(
      estimateTextMessageAirtime(
        textBytes: 10,
        spreadingFactor: 13,
        bandwidthHz: 250000,
        codingRate: 5,
      ),
      isNull,
    );
  });
}
