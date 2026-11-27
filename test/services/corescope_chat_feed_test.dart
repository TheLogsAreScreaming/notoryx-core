import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:meshcore_open/services/corescope.dart';
import 'package:meshcore_open/services/corescope_chat_feed.dart';
import 'package:meshcore_open/storage/prefs_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

Map<String, dynamic> packet(String hash, String hex, String seen) => {
  'hash': hash,
  'raw_hex': hex,
  'first_seen': seen,
  'payload_type': 5,
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('parseCoreScopeChannelPackets', () {
    test('keeps channel packets with raw bytes, oldest first', () {
      final list = parseCoreScopeChannelPackets({
        'packets': [
          packet('BB', '1502aabb', '2026-11-26T10:05:00Z'),
          packet('aa', '1501ff', '2026-11-26T10:00:00Z'),
          {...packet('cc', '1504', '2026-11-26T10:01:00Z'), 'payload_type': 4},
          packet('dd', 'zz', '2026-11-26T10:02:00Z'),
          packet('ee', '123', '2026-11-26T10:02:00Z'),
          {'hash': 'ff'},
          'junk',
        ],
      });
      expect(list.map((p) => p.hash), ['aa', 'bb']);
      expect(list.first.raw, Uint8List.fromList([0x15, 0x01, 0xFF]));
    });
  });

  test('region codes', () {
    expect(isValidCoreScopeRegion(''), isTrue);
    expect(isValidCoreScopeRegion('ORD'), isTrue);
    expect(isValidCoreScopeRegion('ord, MDW'), isTrue);
    expect(isValidCoreScopeRegion('O'), isFalse);
    expect(isValidCoreScopeRegion('ORD;DROP'), isFalse);
  });

  group('CoreScopeChatFeed', () {
    late List<http.Request> requests;
    late List<Map<String, dynamic>> pages;
    late List<Uint8List> got;
    late AnalyzerService analyzer;
    final now = DateTime.utc(2026, 11, 26, 12);

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      PrefsManager.reset();
      await PrefsManager.initialize();
      requests = [];
      pages = [];
      got = [];
      analyzer = AnalyzerService()..load();
    });

    CoreScopeChatFeed feed() => CoreScopeChatFeed(
      analyzer: analyzer,
      onPacket: got.add,
      clock: () => now,
      client: () => MockClient((req) async {
        requests.add(req);
        final body = pages.isEmpty ? {'packets': []} : pages.removeAt(0);
        return http.Response(jsonEncode(body), 200);
      }),
    );

    test('makes no requests while off', () async {
      final f = feed()..load();
      await f.pollNow();
      expect(requests, isEmpty);
      f.dispose();
    });

    test(
      'only reads: GET with a fixed set of query keys and no body',
      () async {
        final f = feed()..load();
        await f.setRegion('ord');
        await f.setEnabled(true);
        await pumpEventQueue();
        expect(requests, isNotEmpty);
        for (final r in requests) {
          expect(r.method, 'GET');
          expect(r.body, isEmpty);
          expect(r.url.path, '/api/packets');
          expect(r.url.queryParameters.keys.toSet(), {
            'type',
            'since',
            'order',
            'limit',
            'region',
          });
        }
        final q = requests.first.url.queryParameters;
        expect(q['type'], '5');
        expect(q['region'], 'ORD');
        expect(
          DateTime.parse(q['since']!),
          now.subtract(CoreScopeChatFeed.backfill),
        );
        f.dispose();
      },
    );

    test('hands on each packet once and moves the window forward', () async {
      pages.add({
        'packets': [
          packet('aa', '1501', '2026-11-26T11:00:00Z'),
          packet('bb', '1502', '2026-11-26T11:30:00Z'),
        ],
      });
      final f = feed()..load();
      await f.setEnabled(true);
      await pumpEventQueue();
      expect(got, hasLength(2));

      pages.add({
        'packets': [
          packet('bb', '1502', '2026-11-26T11:30:00Z'),
          packet('cc', '1503', '2026-11-26T11:40:00Z'),
        ],
      });
      await f.pollNow();
      expect(got.map((r) => r.last), [1, 2, 3]);
      expect(
        DateTime.parse(requests.last.url.queryParameters['since']!),
        DateTime.utc(2026, 11, 26, 11, 30),
      );
      f.dispose();
    });

    test('stops in the background and after switching off', () async {
      final f = feed()..load();
      f.foreground = false;
      await f.setEnabled(true);
      await pumpEventQueue();
      expect(requests, isEmpty);
      f.foreground = true;
      await pumpEventQueue();
      expect(requests, hasLength(1));
      await f.setEnabled(false);
      await f.pollNow();
      expect(requests, hasLength(1));
      f.dispose();
    });

    test('marks the feed offline when the server fails', () async {
      final f = CoreScopeChatFeed(
        analyzer: analyzer,
        onPacket: got.add,
        clock: () => now,
        client: () => MockClient((_) async => http.Response('', 502)),
      )..load();
      await f.setEnabled(true);
      await pumpEventQueue();
      expect(f.lastFailed, isTrue);
      expect(got, isEmpty);
      f.dispose();
    });
  });
}
