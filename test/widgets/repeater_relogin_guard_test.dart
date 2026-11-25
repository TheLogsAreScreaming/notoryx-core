import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meshcore_open/connector/meshcore_connector.dart';
import 'package:meshcore_open/connector/meshcore_protocol.dart';
import 'package:meshcore_open/l10n/app_localizations.dart';
import 'package:meshcore_open/models/contact.dart';
import 'package:meshcore_open/widgets/repeater_relogin_guard.dart';

class _Radio extends MeshCoreConnector {
  bool up = true;
  @override
  bool get isConnected => up;
  void set(bool value) {
    up = value;
    notifyListeners();
  }
}

final _rpt = Contact(
  publicKey: Uint8List.fromList(List.generate(32, (i) => i + 3)),
  name: 'Ridge',
  type: advTypeRepeater,
  path: Uint8List(0),
  pathLength: 0,
  lastSeen: DateTime(2026, 11, 25),
);

void main() {
  Future<int> run(WidgetTester tester, {bool? answer, String pw = 'pw'}) async {
    final radio = _Radio();
    var logins = 0;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: RepeaterReloginGuard(
            connector: radio,
            repeater: _rpt,
            password: pw,
            settle: Duration.zero,
            login: (c, r, p) async {
              logins++;
              return answer;
            },
            child: const Text('hub'),
          ),
        ),
      ),
    );
    // Staying connected does nothing.
    radio.set(true);
    await tester.pump(const Duration(milliseconds: 100));
    expect(logins, 0);
    // The connector batches change notices (50 ms).
    radio.set(false);
    await tester.pump(const Duration(milliseconds: 100));
    radio.set(true);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();
    return logins;
  }

  testWidgets('logs in once after the radio comes back', (tester) async {
    expect(await run(tester, answer: true), 1);
    expect(find.text('Radio reconnected: logged in to Ridge again.'), findsOne);
  });

  testWidgets('says so when the repeater does not answer', (tester) async {
    expect(await run(tester, answer: null), 1);
    expect(find.textContaining("Ridge didn't answer"), findsOneWidget);
  });

  testWidgets('without a password nothing is sent', (tester) async {
    expect(await run(tester, pw: ''), 0);
  });
}
