import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meshcore_open/l10n/app_localizations.dart';
import 'package:meshcore_open/screens/coverage_gap_screen.dart';
import 'package:meshcore_open/services/coverage_hex_service.dart';
import 'package:meshcore_open/services/send_gap_log.dart';
import 'package:provider/provider.dart';

class _NoCells implements CellIndexer {
  @override
  String cellOf(double lat, double lon) => 'a';
  @override
  ({double lat, double lon}) centerOf(String cell) => (lat: 0, lon: 0);
  @override
  List<({double lat, double lon})> boundaryOf(String cell) => const [];
}

void main() {
  testWidgets('with no counted sends it explains what will show', (
    tester,
  ) async {
    final outcomes = StreamController<bool>.broadcast();
    final log = SendGapLog(
      outcomes: outcomes.stream,
      indexer: _NoCells(),
      position: () async => null,
    );
    addTearDown(() {
      log.dispose();
      unawaited(outcomes.close());
    });
    await tester.pumpWidget(
      ChangeNotifierProvider<SendGapLog?>.value(
        value: log,
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: CoverageGapScreen(),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('Gap finder'), findsOneWidget);
    expect(find.byKey(const ValueKey('gap-empty')), findsOneWidget);
    expect(find.byTooltip('Clear history'), findsNothing);
  });

  testWidgets('meets the tap-target and label guidelines', (tester) async {
    final handle = tester.ensureSemantics();
    final outcomes = StreamController<bool>.broadcast();
    final log = SendGapLog(
      outcomes: outcomes.stream,
      indexer: _NoCells(),
      position: () async => null,
    );
    addTearDown(() {
      log.dispose();
      unawaited(outcomes.close());
    });
    await tester.pumpWidget(
      ChangeNotifierProvider<SendGapLog?>.value(
        value: log,
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: CoverageGapScreen(),
        ),
      ),
    );
    await tester.pump();
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    handle.dispose();
  });
}
