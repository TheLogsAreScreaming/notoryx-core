import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meshcore_open/connector/meshcore_connector.dart';
import 'package:meshcore_open/connector/meshcore_protocol.dart';
import 'package:meshcore_open/l10n/app_localizations.dart';
import 'package:meshcore_open/models/contact.dart';
import 'package:meshcore_open/screens/manual_path_trace_screen.dart';
import 'package:provider/provider.dart';

Contact _repeater(String name, int firstByte) => Contact(
  publicKey: Uint8List.fromList([firstByte, ...List.filled(31, 7)]),
  name: name,
  type: advTypeRepeater,
  pathLength: -1,
  path: Uint8List(0),
  lastSeen: DateTime(2026),
);

void main() {
  testWidgets('typed hashes are matched to known repeaters', (tester) async {
    final connector = MeshCoreConnector()
      ..debugSetContacts([_repeater('Hilltop', 0xA1)]);
    addTearDown(connector.dispose);
    await tester.pumpWidget(
      ChangeNotifierProvider<MeshCoreConnector>.value(
        value: connector,
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ManualPathTraceScreen(initialText: 'A1, B2'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Hops (2)'), findsOneWidget);
    expect(find.text('A1'), findsOneWidget);
    expect(find.text('Hilltop'), findsOneWidget);
    expect(find.text('Unknown node'), findsOneWidget);
    // Not connected: the run button is off and says why.
    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'Run path trace'),
          )
          .onPressed,
      isNull,
    );
    expect(find.text('Connect to a radio to run a trace'), findsOneWidget);
  });

  testWidgets('bad input explains itself', (tester) async {
    final connector = MeshCoreConnector();
    addTearDown(connector.dispose);
    await tester.pumpWidget(
      ChangeNotifierProvider<MeshCoreConnector>.value(
        value: connector,
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ManualPathTraceScreen(initialText: 'A1,ZZ'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.text('Only hex characters (0-9, A-F) are allowed'),
      findsOneWidget,
    );
  });
}
