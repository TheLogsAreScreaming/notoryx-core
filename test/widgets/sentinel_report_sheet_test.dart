import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:meshcore_open/l10n/app_localizations.dart';
import 'package:meshcore_open/services/sentinel_service.dart';
import 'package:meshcore_open/storage/prefs_manager.dart';
import 'package:meshcore_open/widgets/sentinel_report_sheet.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late List<http.Request> reports;
  late SentinelService sentinel;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    PrefsManager.reset();
    await PrefsManager.initialize();
    reports = [];
    sentinel = SentinelService(
      baseUrl: 'https://relay.test',
      httpClient: MockClient((req) async {
        if (req.url.path.endsWith('/reports')) {
          reports.add(req);
          return http.Response(
            jsonEncode({'caseRef': 'SNT-42', 'status': 'received'}),
            201,
          );
        }
        return http.Response(jsonEncode({'bans': []}), 200);
      }),
    );
    await sentinel.start();
  });

  tearDown(() => sentinel.dispose());

  Future<void> pumpHost(WidgetTester tester) => tester.pumpWidget(
    ChangeNotifierProvider.value(
      value: sentinel,
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showSentinelReportSheet(
                context,
                nodeId: sentinelNameId('Spammer'),
                nodeName: 'Spammer',
                messageExcerpt: 'BUY CHEAP ANTENNAS',
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ),
  );

  testWidgets('asks to opt in, then sends the chosen report', (tester) async {
    await pumpHost(tester);
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('Turn on community moderation?'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('sentinel-turn-on')));
    await tester.pumpAndSettle();
    expect(sentinel.enabled, isTrue);

    expect(find.text('Report Spammer'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('sentinel-reason-flooding')));
    await tester.enterText(
      find.byKey(const ValueKey('sentinel-note')),
      'every minute',
    );
    // Untick the message: it must not be sent.
    await tester.tap(find.byKey(const ValueKey('sentinel-include-message')));
    await tester.ensureVisible(
      find.byKey(const ValueKey('sentinel-send-report')),
    );
    await tester.tap(find.byKey(const ValueKey('sentinel-send-report')));
    await tester.pumpAndSettle();

    expect(find.text('Report sent (SNT-42)'), findsOneWidget);
    final body = jsonDecode(reports.single.body) as Map<String, dynamic>;
    expect(body['nodeId'], 'name:Spammer');
    expect(body['reason'], 'Flooding the mesh: every minute');
    expect(body.containsKey('messageExcerpt'), isFalse);
    // Stop the six-hourly sync timer before the test ends.
    await sentinel.setEnabled(false);
  });

  testWidgets('declining the opt-in sends nothing', (tester) async {
    await pumpHost(tester);
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(sentinel.enabled, isFalse);
    expect(find.text('Report Spammer'), findsNothing);
    expect(reports, isEmpty);
  });

  testWidgets('flag chip shows only for listed nodes', (tester) async {
    await sentinel.setEnabled(true);
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: sentinel,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(
            body: Column(
              children: [
                SentinelFlag.forName('Nobody'),
                SentinelFlag.forKey('abcd'),
              ],
            ),
          ),
        ),
      ),
    );
    expect(find.text('Flagged'), findsNothing);
    await sentinel.setEnabled(false);
  });
}
