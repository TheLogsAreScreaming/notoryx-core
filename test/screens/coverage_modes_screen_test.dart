import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meshcore_open/l10n/app_localizations.dart';
import 'package:meshcore_open/screens/coverage_modes_screen.dart';
import 'package:meshcore_open/storage/prefs_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late List<CoverageMode> built;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    PrefsManager.reset();
    await PrefsManager.initialize();
    built = [];
  });

  Widget app({CoverageMode? initial}) => MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: CoverageModesScreen(
      initial: initial,
      screenFor: (m) {
        built.add(m);
        return Center(child: Text('tool:${m.name}'));
      },
    ),
  );

  testWidgets('opens on Capture and only builds tools as they are opened', (
    tester,
  ) async {
    await tester.pumpWidget(app());
    expect(find.text('tool:capture'), findsOneWidget);
    expect(built, [CoverageMode.capture]);
    for (final label in [
      'Capture',
      'Wardrive',
      'Hexagons',
      'Gaps',
      'Antenna',
      'Hunt',
    ]) {
      expect(find.text(label), findsOneWidget, reason: label);
    }
    await tester.tap(find.text('Gaps'));
    await tester.pumpAndSettle();
    expect(find.text('tool:gaps'), findsOneWidget);
    expect(built.toSet(), {CoverageMode.capture, CoverageMode.gaps});
  });

  testWidgets('remembers the last mode', (tester) async {
    await tester.pumpWidget(app());
    await tester.tap(find.text('Wardrive'));
    await tester.pumpAndSettle();
    expect(
      PrefsManager.instance.getString(CoverageModesScreen.lastModeKey),
      'wardrive',
    );
    built.clear();
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(app());
    expect(built, [CoverageMode.wardrive]);
  });

  testWidgets('a link can open a given mode', (tester) async {
    await tester.pumpWidget(app(initial: CoverageMode.hunt));
    expect(find.text('tool:hunt'), findsOneWidget);
  });

  testWidgets('mode bar meets the tap-target and label guidelines', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(app());
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    handle.dispose();
  });
}
