import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meshcore_open/connector/meshcore_connector.dart';
import 'package:meshcore_open/connector/meshcore_protocol.dart';
import 'package:meshcore_open/l10n/app_localizations.dart';
import 'package:meshcore_open/models/automation_rule.dart';
import 'package:meshcore_open/models/channel.dart';
import 'package:meshcore_open/models/contact.dart';
import 'package:meshcore_open/models/message.dart';
import 'package:meshcore_open/screens/automation_screen.dart';
import 'package:meshcore_open/services/automation_service.dart';
import 'package:meshcore_open/storage/prefs_manager.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _peak = Contact(
  publicKey: Uint8List.fromList(List.filled(32, 9)),
  name: 'Peak',
  type: advTypeChat,
  pathLength: 0,
  path: Uint8List(0),
  lastSeen: DateTime(2026, 11, 13),
);

class _Radio extends MeshCoreConnector {
  final direct = StreamController<Message>.broadcast();
  final sentTo = <String>[];
  final joined = <(int, String)>[];
  final list = [Channel.empty(0), Channel.empty(1)];

  @override
  bool get isConnected => true;
  @override
  int? get batteryPercent => 55;
  @override
  int get maxChannels => 2;
  @override
  List<Channel> get channels => list;
  @override
  List<Contact> get contacts => [_peak];
  @override
  Contact? getContactByPubKeyHex(String hex) =>
      hex == _peak.publicKeyHex ? _peak : null;
  @override
  Stream<Message> get receivedDirectMessages => direct.stream;
  @override
  Future<void> sendMessage(
    Contact contact,
    String text, {
    String? originalText,
    String? translatedLanguageCode,
    String? translationModelId,
  }) async => sentTo.add('${contact.name}:$text');
  @override
  Future<void> setChannel(int index, String name, Uint8List psk) async {
    joined.add((index, name));
    list[index] = Channel(index: index, name: name, psk: psk);
  }
}

AutomationRule _onMessage(List<AutomationStep> steps) => AutomationRule(
  id: 'm',
  name: 'Reply',
  enabled: true,
  conditions: const [
    AutomationCondition(
      trigger: AutomationTrigger.messageReceived,
      contains: 'status',
    ),
  ],
  steps: steps,
);

void main() {
  final now = DateTime(2026, 11, 13, 18);

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    PrefsManager.reset();
    await PrefsManager.initialize();
  });
  tearDown(PrefsManager.reset);

  Message msg(String text, {Duration age = Duration.zero}) => Message(
    senderKey: _peak.publicKey,
    text: text,
    timestamp: now.subtract(age),
    isOutgoing: false,
  );

  test('a message runs reply, sound, join and logs each', () async {
    final radio = _Radio();
    var sounds = 0;
    final s = AutomationService(
      radio,
      clock: () => now,
      tick: Duration.zero,
      playSound: () async => sounds++,
      notify: (_, _) async {},
    );
    await s.save(
      _onMessage(const [
        AutomationStep(
          action: AutomationAction.send,
          target:
              'message:0909090909090909090909090909090909090909090909090909090909090909',
          text: 'hi {node}, battery {battery}',
        ),
        AutomationStep(action: AutomationAction.playSound),
        AutomationStep(action: AutomationAction.joinChannel, text: 'hikers'),
      ]),
    );
    radio.direct.add(msg('old status', age: const Duration(hours: 1)));
    radio.direct.add(msg('[NOTORYX Bot] status'));
    await pumpEventQueue();
    expect(s.runs, isEmpty);
    radio.direct.add(msg('Status?'));
    await pumpEventQueue();
    expect(radio.sentTo, ['Peak:[NOTORYX Bot] hi Peak, battery 55%']);
    expect(sounds, 1);
    expect(radio.joined, [(0, '#hikers')]);
    expect(s.runs.map((r) => r.outcome), everyElement(AutomationOutcome.done));
    s.dispose();
    radio.dispose();
  });

  test('webhooks are off by default and post JSON once allowed', () async {
    final radio = _Radio();
    final posts = <(Uri, String)>[];
    var t = now;
    final s = AutomationService(
      radio,
      clock: () => t,
      tick: Duration.zero,
      post: (url, body) async {
        posts.add((url, body));
        return 200;
      },
    );
    expect(s.webhooksAllowed, isFalse);
    await s.save(
      _onMessage(const [
        AutomationStep(
          action: AutomationAction.webhook,
          target: 'https://example.org/hook',
        ),
      ]),
    );
    radio.direct.add(msg('status'));
    await pumpEventQueue();
    expect(posts, isEmpty);
    expect(s.runs.single.outcome, AutomationOutcome.webOff);

    await s.setWebhooksAllowed(true);
    expect(
      PrefsManager.instance.getBool('automation_webhooks_allowed_v1'),
      isTrue,
    );
    t = t.add(const Duration(minutes: 16));
    radio.direct.add(
      Message(
        senderKey: _peak.publicKey,
        text: 'status now',
        timestamp: t,
        isOutgoing: false,
      ),
    );
    await pumpEventQueue();
    expect(posts.single.$1.host, 'example.org');
    final body = jsonDecode(posts.single.$2) as Map<String, dynamic>;
    expect(body['rule'], 'Reply');
    expect(body['node'], 'Peak');
    expect(body['text'], 'status now');
    s.dispose();
    radio.dispose();
  });

  testWidgets('builds an AND rule with a webhook in the editor', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(500, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final radio = _Radio();
    final s = AutomationService(radio, tick: Duration.zero);
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<MeshCoreConnector>.value(value: radio),
          ChangeNotifierProvider.value(value: s),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: AutomationScreen(),
        ),
      ),
    );
    final web = tester.widget<SwitchListTile>(
      find.byKey(const ValueKey('auto-web-switch')),
    );
    expect(web.value, isFalse);
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));

    await tester.tap(find.byTooltip('Add rule'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'Evening');

    // Condition 1: battery (the default).
    await tester.tap(find.text('Add condition'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    // Condition 2: a message.
    await tester.tap(find.text('Add condition'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('auto-trigger')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('A message arrives').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('auto-contains')), 'ok');
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('All (AND)'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add action'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('auto-action')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Call a webhook').last);
    await tester.pumpAndSettle();
    expect(find.textContaining('Needs internet'), findsOneWidget);
    await tester.enterText(
      find.byKey(const ValueKey('auto-url')),
      'https://example.org/x',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    final rule = s.rules.single;
    expect(rule.name, 'Evening');
    expect(rule.combine, AutomationCombine.all);
    expect(rule.conditions.map((c) => c.trigger), [
      AutomationTrigger.batteryBelow,
      AutomationTrigger.messageReceived,
    ]);
    expect(rule.conditions.last.contains, 'ok');
    expect(rule.steps.single.target, 'https://example.org/x');
    expect(rule.enabled, isFalse);
    expect(find.textContaining('Needs internet'), findsOneWidget);
    handle.dispose();
    await tester.pumpWidget(const SizedBox());
    s.dispose();
    radio.dispose();
  });
}
