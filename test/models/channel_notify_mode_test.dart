import 'package:flutter_test/flutter_test.dart';
import 'package:meshcore_open/models/app_settings.dart';
import 'package:meshcore_open/models/channel_notify_mode.dart';

void main() {
  group('mentionsName', () {
    test('matches the @[name] form, ignoring case and spaces', () {
      expect(mentionsName('@[Base Camp] are you there?', 'base camp'), isTrue);
      expect(mentionsName('hi @[ Base Camp ]', 'Base Camp'), isTrue);
    });

    test('does not match another name or a bare word', () {
      expect(mentionsName('@[Base] hello', 'Base Camp'), isFalse);
      expect(mentionsName('base camp is fine', 'Base Camp'), isFalse);
    });

    test('an unknown own name never matches', () {
      expect(mentionsName('@[Base Camp] hi', null), isFalse);
      expect(mentionsName('@[Base Camp] hi', '  '), isFalse);
    });
  });

  group('shouldNotifyForChannelMode', () {
    test('all notifies, muted never does', () {
      expect(
        shouldNotifyForChannelMode(
          ChannelNotifyMode.all,
          text: 'x',
          selfName: 'A',
        ),
        isTrue,
      );
      expect(
        shouldNotifyForChannelMode(
          ChannelNotifyMode.muted,
          text: '@[A] x',
          selfName: 'A',
        ),
        isFalse,
      );
    });

    test('mentions only notifies just for mentions', () {
      expect(
        shouldNotifyForChannelMode(
          ChannelNotifyMode.mentionsOnly,
          text: '@[A] x',
          selfName: 'A',
        ),
        isTrue,
      );
      expect(
        shouldNotifyForChannelMode(
          ChannelNotifyMode.mentionsOnly,
          text: 'x',
          selfName: 'A',
        ),
        isFalse,
      );
    });
  });

  test('mentions-only channels survive a JSON round trip', () {
    final settings = AppSettings(mentionsOnlyChannels: {'Public'});
    final restored = AppSettings.fromJson(settings.toJson());
    expect(restored.mentionsOnlyChannels, {'Public'});
    expect(AppSettings.fromJson({}).mentionsOnlyChannels, isEmpty);
  });
}
