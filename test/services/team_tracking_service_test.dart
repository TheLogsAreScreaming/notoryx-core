import 'package:fake_async/fake_async.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meshcore_open/connector/meshcore_connector.dart';
import 'package:meshcore_open/models/channel.dart';
import 'package:meshcore_open/screens/map_screen.dart' show parseMarkerText;
import 'package:meshcore_open/services/team_tracking_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

final t0 = DateTime(2026, 11, 8, 9);

class _Radio extends MeshCoreConnector {
  final posts = <String>[];
  double? lat = 49.3, lon = -123.1;
  @override
  bool get isConnected => true;
  @override
  double? get selfLatitude => lat;
  @override
  double? get selfLongitude => lon;
  @override
  String? get selfName => 'Sam';
  @override
  Future<void> sendChannelMessage(
    Channel channel,
    String text, {
    String? originalText,
    String? translatedLanguageCode,
    String? translationModelId,
    bool sign = false,
  }) async => posts.add(text);
}

void main() {
  group('policy', () {
    const p = TeamTrackingPolicy();
    const here = (lat: 49.3, lon: -123.1);
    const near = (lat: 49.3001, lon: -123.1); // ~11 m
    const far = (lat: 49.301, lon: -123.1); // ~111 m
    bool post(Duration since, ({double lat, double lon}) at) => p.shouldPost(
      now: t0.add(since),
      lastPostAt: t0,
      lastPosition: here,
      position: at,
      interval: const Duration(minutes: 15),
    );

    test('first post goes at once', () {
      expect(
        p.shouldPost(
          now: t0,
          lastPostAt: null,
          lastPosition: null,
          position: here,
          interval: const Duration(minutes: 15),
        ),
        isTrue,
      );
    });
    test('not before the interval', () {
      expect(post(const Duration(minutes: 14), far), isFalse);
    });
    test('after the interval only if moved 25 m', () {
      expect(post(const Duration(minutes: 16), near), isFalse);
      expect(post(const Duration(minutes: 16), far), isTrue);
    });
    test('a heartbeat after 3 intervals even standing still', () {
      expect(post(const Duration(minutes: 45), here), isTrue);
    });
    test('the floor is 10 minutes', () {
      expect(TeamTrackingPolicy.intervals.first, 10);
    });
  });

  test('the post is a marker the map reads, flagged as tracking', () {
    final m = parseMarkerText(trackingMarkerText('Sam|A', 49.3, -123.1))!;
    expect(m.label, 'Sam/A');
    expect(m.flags, 't');
    expect(m.position.latitude, closeTo(49.3, 1e-6));
  });

  group('service', () {
    late _Radio radio;
    late ValueNotifier<bool> trip;
    late SharedPreferences prefs;
    final private = Channel(
      index: 1,
      name: 'Team',
      psk: Uint8List.fromList(List.filled(16, 7)),
    );
    final public = Channel(
      index: 0,
      name: 'Public',
      psk: Uint8List.fromList([
        for (var i = 0; i < 32; i += 2)
          int.parse(Channel.publicChannelPsk.substring(i, i + 2), radix: 16),
      ]),
    );

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    void run(
      void Function(
        FakeAsync async,
        TeamTrackingService t,
        DateTime Function() now,
        void Function(Duration) advance,
      )
      body,
    ) {
      fakeAsync((async) {
        var now = t0;
        radio = _Radio()..debugSetChannels([public, private]);
        trip = ValueNotifier(true);
        final t = TeamTrackingService(
          connector: radio,
          trip: trip,
          tripActive: () => trip.value,
          prefs: prefs,
          clock: () => now,
        );
        void advance(Duration d) {
          now = now.add(d);
          async.elapse(d);
        }

        body(async, t, () => now, advance);
        t.dispose();
        radio.dispose();
        async.flushTimers();
      });
    }

    test('only private channels are offered', () {
      run((async, t, now, advance) {
        expect(t.eligibleChannels.map((c) => c.name), ['Team']);
        t.start(0);
        async.flushMicrotasks();
        expect(t.enabled, isFalse);
      });
    });

    test('posts at start, then on the interval when moving', () {
      run((async, t, now, advance) {
        t.start(1);
        advance(const Duration(seconds: 10));
        expect(radio.posts, hasLength(1));
        expect(radio.posts.single, contains('|Sam|t'));
        advance(const Duration(minutes: 16));
        expect(radio.posts, hasLength(1), reason: 'not moved');
        radio.lat = 49.31;
        advance(const Duration(minutes: 1));
        expect(radio.posts, hasLength(2));
      });
    });

    test('turns off when the trip ends', () {
      run((async, t, now, advance) {
        t.start(1);
        advance(const Duration(seconds: 10));
        trip.value = false;
        expect(t.enabled, isFalse);
      });
    });

    test('turns off after 12 hours', () {
      run((async, t, now, advance) {
        t.start(1);
        advance(const Duration(hours: 12, minutes: 1));
        expect(t.enabled, isFalse);
      });
    });

    test('no trip, no tracking', () {
      run((async, t, now, advance) {
        trip.value = false;
        t.start(1);
        async.flushMicrotasks();
        expect(t.enabled, isFalse);
      });
    });

    test('picking a channel does not start it', () {
      run((async, t, now, advance) {
        t.selectChannel(1);
        expect(t.enabled, isFalse);
        expect(t.channelIndex, 1);
      });
    });
  });
}
