import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:meshcore_open/models/channel_message.dart';
import 'package:meshcore_open/services/sentinel_service.dart';
import 'package:meshcore_open/storage/prefs_manager.dart';
import 'package:meshcore_open/widgets/sentinel_report_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _key = 'ab12cd34ef56ab12cd34ef56ab12cd34ef56ab12cd34ef56ab12cd34ef56ab12';

http.Response _json(int status, Object body) =>
    http.Response(jsonEncode(body), status);

Map<String, Object?> _decisions(List<Object?> bans) => {
  'network': 'meshcore',
  'generatedAt': '2026-11-13T00:00:00Z',
  'advisory': true,
  'bans': bans,
};

void main() {
  late List<http.Request> requests;
  late http.Response Function(http.Request) respond;
  late DateTime now;
  var refs = 0;

  SentinelService make() => SentinelService(
    httpClient: MockClient((req) async {
      requests.add(req);
      return respond(req);
    }),
    baseUrl: 'https://relay.test',
    now: () => now,
    newRef: () => 'ref-${++refs}',
  );

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    PrefsManager.reset();
    await PrefsManager.initialize();
    requests = [];
    refs = 0;
    now = DateTime.utc(2026, 11, 13, 12);
    respond = (_) => _json(200, _decisions(const []));
  });

  test('off by default and makes no requests', () async {
    final s = make();
    await s.start();
    await s.refresh(force: true);
    expect(s.enabled, isFalse);
    expect(requests, isEmpty);
    expect(s.banForKey(_key), isNull);
    final r = await s.report(nodeId: _key, reason: SentinelReason.spam);
    expect(r, isA<SentinelReportRejected>());
    expect(requests, isEmpty);
    s.dispose();
  });

  test(
    'turning on downloads the ban list and labels key and name bans',
    () async {
      respond = (_) => _json(
        200,
        _decisions([
          {
            'nodeId': _key.toUpperCase(),
            'caseRef': 'SNT-1',
            'bannedAt': '2026-11-12T00:00:00Z',
            'appealPending': false,
          },
          {'nodeId': 'name:Spammy', 'caseRef': 'SNT-2', 'appealPending': true},
          {'nodeId': '', 'caseRef': 'SNT-3'},
          'garbage',
        ]),
      );
      final s = make();
      await s.start();
      await s.setEnabled(true);
      await s.syncDecisions(force: true);
      expect(
        requests.first.url.toString(),
        'https://relay.test/v1/meshcore/decisions',
      );
      expect(s.flaggedCount, 2);
      expect(s.banForKey(_key)?.caseRef, 'SNT-1');
      expect(s.banForName(' Spammy ')?.appealPending, isTrue);
      expect(s.banForName('Someone else'), isNull);
      s.dispose();

      // Survives a restart without a network.
      respond = (_) => throw const SocketLikeError();
      final again = make();
      await again.start();
      expect(again.banForKey(_key)?.caseRef, 'SNT-1');
      again.dispose();
    },
  );

  test('does not re-download within five minutes unless forced', () async {
    final s = make();
    await s.start();
    await s.setEnabled(true);
    await s.syncDecisions(force: true);
    final before = requests.length;
    now = now.add(const Duration(minutes: 2));
    await s.syncDecisions();
    expect(requests.length, before);
    now = now.add(const Duration(minutes: 4));
    await s.syncDecisions();
    expect(requests.length, before + 1);
    s.dispose();
  });

  test('a report sends only what the user chose, trimmed', () async {
    respond = (req) => req.url.path.endsWith('/reports')
        ? _json(201, {
            'caseRef': 'SNT-77',
            'status': 'received',
            'duplicate': false,
          })
        : _json(200, _decisions(const []));
    final s = make();
    await s.start();
    await s.setEnabled(true);
    final r = await s.report(
      nodeId: _key,
      nodeName: 'Bob',
      reason: SentinelReason.flooding,
      note: '  every 10 seconds  ',
      messageExcerpt: 'x' * 400,
    );
    expect(
      r,
      isA<SentinelReportSent>().having((r) => r.caseRef, 'caseRef', 'SNT-77'),
    );
    final sent = requests.lastWhere((q) => q.url.path.endsWith('/reports'));
    expect(sent.url.toString(), 'https://relay.test/v1/meshcore/reports');
    final body = jsonDecode(sent.body) as Map<String, dynamic>;
    expect(body.keys.toSet(), {
      'nodeId',
      'nodeName',
      'reason',
      'messageExcerpt',
      'externalRef',
    });
    expect(body['reason'], 'Flooding the mesh: every 10 seconds');
    expect((body['messageExcerpt'] as String).length, 280);
    expect(s.sentReports.single.caseRef, 'SNT-77');
    s.dispose();
  });

  test(
    'offline reports queue, survive restart and send in order with the same ref',
    () async {
      var online = false;
      respond = (req) {
        if (!online) throw const SocketLikeError();
        if (req.url.path.endsWith('/reports')) {
          final ref = (jsonDecode(req.body) as Map)['externalRef'];
          return _json(201, {
            'caseRef': 'SNT-$ref',
            'status': 'received',
            'duplicate': false,
          });
        }
        return _json(200, _decisions(const []));
      };
      final s = make();
      await s.start();
      await s.setEnabled(true);
      expect(
        await s.report(nodeId: _key, reason: SentinelReason.spam),
        isA<SentinelReportQueued>(),
      );
      expect(
        await s.report(nodeId: 'name:X', reason: SentinelReason.other),
        isA<SentinelReportQueued>(),
      );
      expect(s.queuedCount, 2);
      s.dispose();

      online = true;
      requests.clear();
      final again = make();
      await again.start();
      expect(again.queuedCount, 2);
      expect(await again.flushQueue(), 2);
      final refs = [
        for (final q in requests.where((q) => q.url.path.endsWith('/reports')))
          (jsonDecode(q.body) as Map)['externalRef'],
      ];
      expect(refs, ['ref-1', 'ref-2']);
      expect(again.queuedCount, 0);
      again.dispose();
    },
  );

  test('rejected reports are not queued; 429 and 5xx are', () async {
    var status = 400;
    respond = (req) => req.url.path.endsWith('/reports')
        ? _json(status, {'error': 'Invalid report'})
        : _json(200, _decisions(const []));
    final s = make();
    await s.start();
    await s.setEnabled(true);
    final bad = await s.report(nodeId: _key, reason: SentinelReason.spam);
    expect(
      bad,
      isA<SentinelReportRejected>().having(
        (r) => r.message,
        'message',
        'Invalid report',
      ),
    );
    expect(s.queuedCount, 0);
    status = 429;
    expect(
      await s.report(nodeId: _key, reason: SentinelReason.spam),
      isA<SentinelReportQueued>(),
    );
    status = 503;
    expect(
      await s.report(nodeId: _key, reason: SentinelReason.spam),
      isA<SentinelReportQueued>(),
    );
    expect(s.queuedCount, 2);
    s.dispose();
  });

  test('turning off forgets the list and unsent reports', () async {
    respond = (req) => req.url.path.endsWith('/reports')
        ? _json(503, {'error': 'down'})
        : _json(
            200,
            _decisions([
              {'nodeId': _key, 'caseRef': 'SNT-1'},
            ]),
          );
    final s = make();
    await s.start();
    await s.setEnabled(true);
    await s.syncDecisions(force: true);
    await s.report(nodeId: _key, reason: SentinelReason.spam);
    expect(s.flaggedCount, 1);
    expect(s.queuedCount, 1);
    await s.setEnabled(false);
    expect(s.flaggedCount, 0);
    expect(s.queuedCount, 0);
    expect(s.banForKey(_key), isNull);
    s.dispose();
  });

  test('appeal outcomes map from relay status codes', () async {
    var status = 201;
    respond = (req) => req.url.path.endsWith('/appeals')
        ? _json(status, {'caseRef': 'SNT-5'})
        : _json(200, _decisions(const []));
    final s = make();
    await s.start();
    await s.setEnabled(true);
    Future<SentinelAppealOutcome> go() => s.appeal(
      caseRef: ' snt-5 ',
      statement: 'My weather beacon',
      contact: '',
    );
    expect(await go(), SentinelAppealOutcome.received);
    final body =
        jsonDecode(
              requests.lastWhere((q) => q.url.path.endsWith('/appeals')).body,
            )
            as Map<String, dynamic>;
    expect(body, {'caseRef': 'SNT-5', 'statement': 'My weather beacon'});
    status = 404;
    expect(await go(), SentinelAppealOutcome.unknownCase);
    status = 409;
    expect(await go(), SentinelAppealOutcome.notAppealable);
    status = 429;
    expect(await go(), SentinelAppealOutcome.tooMany);
    status = 500;
    expect(await go(), SentinelAppealOutcome.failed);
    s.dispose();
  });

  test('channel senders get a stable name id and hiding is opt-in', () async {
    expect(sentinelNameId('  Bob '), 'name:Bob');
    expect(sentinelNameId('x' * 100).length, 64);
    respond = (_) => _json(
      200,
      _decisions([
        {'nodeId': 'name:Bob', 'caseRef': 'SNT-9'},
      ]),
    );
    final s = make();
    await s.start();
    await s.setEnabled(true);
    await s.syncDecisions(force: true);
    final msg = ChannelMessage(
      senderKey: null,
      senderName: 'Bob',
      text: 'buy now',
      timestamp: now,
      isOutgoing: false,
      channelIndex: 0,
    );
    expect(sentinelHides(s, msg), isFalse);
    await s.setHideFlagged(true);
    expect(sentinelHides(s, msg), isTrue);
    expect(sentinelHides(null, msg), isFalse);
    s.dispose();
  });
}

class SocketLikeError implements Exception {
  const SocketLikeError();
}
