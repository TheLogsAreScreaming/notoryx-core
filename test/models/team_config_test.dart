import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meshcore_open/models/channel.dart';
import 'package:meshcore_open/models/team_config.dart';

Uint8List _key(int b) => Uint8List.fromList(List.filled(16, b));
const _pass = 'correct horse battery';

void main() {
  final config = TeamConfig(
    radio: const TeamRadioSettings(
      freq: 910525,
      bandwidth: 62500,
      spreadingFactor: 7,
      codingRate: 5,
      txPower: 22,
    ),
    channels: [TeamChannel('#team', _key(7))],
  );

  test('round trip keeps radio settings and channel keys', () async {
    final back = await openTeamConfig(
      await sealTeamConfig(config, _pass),
      _pass,
    );
    expect(back.radio!.freq, 910525);
    expect(back.radio!.txPower, 22);
    expect(back.channels.single.name, '#team');
    expect(back.channels.single.psk, _key(7));
  });

  test('the sealed text does not reveal the contents', () async {
    expect(await sealTeamConfig(config, _pass), isNot(contains('#team')));
  });

  test('a wrong passphrase fails', () async {
    final sealed = await sealTeamConfig(config, _pass);
    await expectLater(
      openTeamConfig(sealed, 'wrong passphrase!'),
      throwsA(isA<SecretBoxAuthenticationError>()),
    );
  });

  test('a short passphrase is refused', () {
    expect(sealTeamConfig(config, 'short'), throwsFormatException);
  });

  test('other text is refused', () {
    expect(openTeamConfig('hello', _pass), throwsFormatException);
  });

  test('a bad channel key is refused', () {
    expect(
      () => TeamConfig.fromJson({
        'c': [
          ['#x', 'AAAA'],
        ],
      }),
      throwsFormatException,
    );
  });

  group('channel slots', () {
    final public = Channel(index: 0, name: 'Public', psk: _key(1));
    final taken = Channel(index: 1, name: '#a', psk: _key(2));

    test('uses empty slots and never slot 0', () {
      final plan = planChannelSlots(
        [public, taken],
        [TeamChannel('#b', _key(3))],
        8,
      );
      expect(plan.keys, [2]);
    });

    test('skips a channel the radio already has', () {
      expect(
        planChannelSlots(
          [public, taken],
          [TeamChannel('#renamed', _key(2))],
          8,
        ),
        isEmpty,
      );
    });

    test('leaves out what does not fit', () {
      final plan = planChannelSlots(
        [public, taken],
        [TeamChannel('#b', _key(3)), TeamChannel('#c', _key(4))],
        3,
      );
      expect(plan.keys, [2]);
    });
  });
}
