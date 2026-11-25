import 'package:flutter_test/flutter_test.dart';
import 'package:meshcore_open/l10n/app_localizations.dart';
import 'package:meshcore_open/models/app_settings.dart';
import 'package:meshcore_open/services/channel_digest.dart';
import 'package:flutter/widgets.dart';

void main() {
  final t0 = DateTime(2026, 11, 25, 12);
  DateTime at(int minutes) => t0.add(Duration(minutes: minutes));

  test('a quiet channel always alerts', () {
    final d = ChannelDigest();
    for (var i = 0; i < 4; i++) {
      expect(d.offer('#hike', at(i * 3)), isTrue);
    }
    expect(d.nextDue, isNull);
  });

  test('a busy channel is held and summarised once', () {
    final d = ChannelDigest();
    for (var i = 0; i < 5; i++) {
      expect(d.offer('#busy', at(0)), isTrue);
    }
    expect(d.offer('#busy', at(1)), isFalse);
    expect(d.offer('#busy', at(2)), isFalse);
    expect(
      d.offer('#quiet', at(2)),
      isTrue,
      reason: 'other channels unaffected',
    );
    expect(d.nextDue, at(16));
    expect(d.takeDue(at(10)), isEmpty);
    expect(d.takeDue(at(16)), {'#busy': 2});
    expect(d.takeDue(at(17)), isEmpty, reason: 'reported once');
    // Quiet again: alerts straight away.
    expect(d.offer('#busy', at(40)), isTrue);
  });

  test('urgent messages always alert and never count towards busy', () {
    final d = ChannelDigest();
    for (var i = 0; i < 10; i++) {
      expect(d.offer('#ops', at(0), urgent: true), isTrue);
    }
    expect(d.offer('#ops', at(0)), isTrue);
    for (var i = 0; i < 4; i++) {
      d.offer('#ops', at(1));
    }
    expect(d.offer('#ops', at(1)), isFalse);
    expect(d.offer('#ops', at(1), urgent: true), isTrue, reason: 'mention/SOS');
  });

  test('the setting is on by default and survives a save', () {
    expect(AppSettings().channelDigest, isTrue);
    final off = AppSettings().copyWith(channelDigest: false);
    expect(AppSettings.fromJson(off.toJson()).channelDigest, isFalse);
  });

  test('summary text reads naturally', () {
    final en = lookupAppLocalizations(const Locale('en'));
    expect(en.digest_body(1), '1 more message on this busy channel');
    expect(en.digest_body(12), '12 more messages on this busy channel');
  });
}
