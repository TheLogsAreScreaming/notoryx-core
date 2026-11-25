// Coverage tools live together in Map + coverage; More lists that one
// entry, still finds each tool by search, and says once what moved.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meshcore_open/l10n/app_localizations.dart';
import 'package:meshcore_open/screens/bastion_map_hub_screen.dart';
import 'package:meshcore_open/screens/bastion_tools_screen.dart';
import 'package:meshcore_open/storage/prefs_manager.dart';
import 'package:meshcore_open/widgets/glass_action_row.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _moved = [
  'Wardrive',
  'Coverage hexagons',
  'Antenna coverage',
  'Antenna hunt',
];

Future<void> _pump(
  WidgetTester tester,
  Widget home, {
  Size size = const Size(420, 2400),
  double textScale = 1,
}) async {
  await tester.binding.setSurfaceSize(size);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
      home: home,
    ),
  );
  await tester.pumpAndSettle();
}

Finder _row(String title) =>
    find.byWidgetPredicate((w) => w is Text && w.data == title);

void main() {
  tearDown(PrefsManager.reset);

  group('More', () {
    testWidgets('lists one Map + coverage entry, not each coverage tool', (
      tester,
    ) async {
      await _pump(tester, const BastionToolsScreen());
      expect(_row('Map + coverage'), findsOneWidget);
      for (final title in [..._moved, 'Repeater ping', 'Repeater IDs']) {
        expect(_row(title), findsNothing, reason: title);
      }
      // Tools that didn't move are still listed.
      expect(_row('Waypoints'), findsOneWidget);
      expect(_row('Repeater tools'), findsOneWidget);
    });

    testWidgets('search still finds every moved tool', (tester) async {
      await _pump(tester, const BastionToolsScreen());
      for (final title in _moved) {
        await tester.enterText(find.byType(TextField), title);
        await tester.pumpAndSettle();
        expect(_row(title), findsOneWidget, reason: title);
      }
    });

    testWidgets('the note about what moved shows once', (tester) async {
      SharedPreferences.setMockInitialValues({});
      await PrefsManager.initialize();
      await _pump(tester, const BastionToolsScreen());
      final note = find.byKey(const ValueKey('tools-moved-note'));
      expect(note, findsOneWidget);
      expect(
        find.textContaining('now together in Map + coverage'),
        findsOneWidget,
      );
      expect(find.textContaining('only in Repeater tools'), findsOneWidget);

      // Hidden while searching, back when the search is cleared.
      await tester.enterText(find.byType(TextField), 'backup');
      await tester.pumpAndSettle();
      expect(note, findsNothing);
      await tester.enterText(find.byType(TextField), '');
      await tester.pumpAndSettle();
      expect(note, findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('tools-moved-ok')));
      await tester.pumpAndSettle();
      expect(note, findsNothing);
      expect(
        PrefsManager.instance.getBool(_BastionToolsKeys.movedNote),
        isTrue,
      );

      // Opening More again doesn't bring it back.
      await tester.pumpWidget(const SizedBox());
      await _pump(tester, const BastionToolsScreen());
      expect(note, findsNothing);
    });
  });

  testWidgets('the note lines up with the rows below it', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await PrefsManager.initialize();
    await _pump(tester, const BastionToolsScreen());
    final note = find.byKey(const ValueKey('tools-moved-note'));
    final row = find.ancestor(
      of: _row('Settings'),
      matching: find.byType(GlassActionRow),
    );
    expect(tester.getTopLeft(note).dx, tester.getTopLeft(row).dx);
    expect(tester.getTopRight(note).dx, tester.getTopRight(row).dx);
  });

  testWidgets('large text on a narrow phone fits without overflow', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await PrefsManager.initialize();
    for (final screen in const [BastionToolsScreen(), BastionMapHubScreen()]) {
      await _pump(tester, screen, size: const Size(320, 1400), textScale: 2);
      expect(tester.takeException(), isNull, reason: '$screen');
    }
    // The note's text is all there at that size.
    await _pump(
      tester,
      const BastionToolsScreen(),
      size: const Size(320, 1400),
      textScale: 2,
    );
    expect(find.textContaining('Searching here still finds'), findsOneWidget);
  });

  testWidgets('the hub is called Map + coverage everywhere', (tester) async {
    await _pump(tester, const BastionMapHubScreen());
    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text('Map + coverage'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('Map + coverage has one Coverage entry and the map tools', (
    tester,
  ) async {
    await _pump(tester, const BastionMapHubScreen());
    expect(find.text('COVERAGE'), findsOneWidget);
    expect(find.text('MAPS'), findsOneWidget);
    // The coverage tools are modes of one entry now, not rows here.
    expect(find.byKey(const ValueKey('map-hub-coverage')), findsOneWidget);
    for (final title in ['Coverage capture', ..._moved]) {
      expect(_row(title), findsNothing, reason: title);
    }
    for (final title in [
      'Live mesh map',
      'Offline map packs',
      'Region profiles',
    ]) {
      expect(find.textContaining(title), findsWidgets, reason: title);
    }
    // Coverage comes before the maps.
    expect(
      tester.getTopLeft(find.byKey(const ValueKey('map-hub-coverage'))).dy,
      lessThan(tester.getTopLeft(find.text('MAPS')).dy),
    );
  });
}

/// The saved-settings key the More screen uses for the note.
abstract final class _BastionToolsKeys {
  static const movedNote = 'tools_moved_note_coverage_v1';
}
