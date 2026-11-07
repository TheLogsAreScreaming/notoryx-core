import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meshcore_open/connector/meshcore_protocol.dart';
import 'package:meshcore_open/models/app_settings.dart';
import 'package:meshcore_open/services/app_settings_service.dart';
import 'package:meshcore_open/storage/prefs_manager.dart';
import 'package:meshcore_open/theme/mesh_theme.dart';
import 'package:meshcore_open/widgets/theme_picker.dart';

double contrast(Color a, Color b) {
  final x = a.computeLuminance(), y = b.computeLuminance();
  return x > y ? (x + .05) / (y + .05) : (y + .05) / (x + .05);
}

/// Every palette a person can end up seeing: the seven fixed themes and
/// each season and holiday inside Seasonal.
final allPalettes = <String, BastionPalette>{
  for (final t in BastionTheme.values)
    if (t != BastionTheme.seasonal) t.label: t.palette,
  for (final s in BastionSeason.values) 'Seasonal ${s.label}': s.palette,
};

Future<AppSettingsService> freshSettings() async {
  SharedPreferences.setMockInitialValues({});
  PrefsManager.reset();
  await PrefsManager.initialize();
  final settings = AppSettingsService();
  await settings.loadSettings();
  return settings;
}

Widget pickerApp(AppSettingsService settings, {double textScale = 1}) =>
    ChangeNotifierProvider.value(
      value: settings,
      child: MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: Scaffold(
          body: SingleChildScrollView(
            child: ThemePicker(now: DateTime(2026, 11, 7)),
          ),
        ),
      ),
    );

void main() {
  tearDown(() => MeshPalette.current = BastionTheme.fallback.palette);

  test('exactly eight themes, in order, with Blaze the default', () {
    expect(BastionTheme.values.map((t) => t.id), [
      'blaze',
      'neon_anarchy',
      'tactical',
      'pink_overload',
      'bare_beauty',
      'okabe_ito',
      'night_ops',
      'seasonal',
    ]);
    expect(AppSettings().appTheme, 'blaze');
    expect(BastionTheme.fromId(null), BastionTheme.blaze);
    expect(BastionTheme.fromId('nope'), BastionTheme.blaze);
    expect(BastionTheme.values.map((t) => t.label).toSet(), hasLength(8));
  });

  test('saved themes from earlier versions open as their replacement', () {
    const expected = {
      'blaze': BastionTheme.blaze,
      'autumn_frost': BastionTheme.seasonal,
      'christmas': BastionTheme.seasonal,
      'bubble_gum': BastionTheme.pinkOverload,
      'topo_night': BastionTheme.pinkOverload,
      'bronzed_blush': BastionTheme.bareBeauty,
      'red_light': BastionTheme.nightOps,
      'okabe_ito': BastionTheme.okabeIto,
      'okabe_ito_slate': BastionTheme.okabeIto,
      'alpine_day': BastionTheme.blaze,
      'halloween': BastionTheme.blaze,
    };
    for (final e in expected.entries) {
      expect(BastionTheme.fromId(e.key), e.value, reason: e.key);
    }
    // No old id is still a theme of its own.
    for (final old in BastionTheme.migrations.keys) {
      expect(BastionTheme.values.any((t) => t.id == old), isFalse);
    }
    // The saved value is left alone, so going back a version still works.
    final saved = AppSettings().copyWith(appTheme: 'bronzed_blush');
    expect(AppSettings.fromJson(saved.toJson()).appTheme, 'bronzed_blush');
  });

  test('the brand colors are used as given', () {
    final blaze = BastionTheme.blaze.palette;
    expect(blaze.bg, const Color(0xFF111820));
    expect(blaze.bg3, const Color(0xFF273443));
    expect(blaze.accent, const Color(0xFFFF8A00));
    expect(blaze.secondary, const Color(0xFFE76F00));
    expect(blaze.ink, const Color(0xFFF4F6F8));
    expect(blaze.ink3, const Color(0xFFAAB5C3));

    final neon = BastionTheme.neonAnarchy.palette;
    expect(neon.bg, const Color(0xFF08060D));
    expect(neon.bg3, const Color(0xFF21112F));
    expect(neon.accent, const Color(0xFFADFF2F));
    expect(neon.tertiaryContainer, const Color(0xFF7022C4));
    expect(neon.ink, const Color(0xFFF1E9FF));

    final tactical = BastionTheme.tactical.palette;
    expect(tactical.bg, const Color(0xFF171C19));
    expect(tactical.bg3, const Color(0xFF303B32));
    expect(tactical.accent, const Color(0xFFA8BA79));
    expect(tactical.tertiary, const Color(0xFFC2A66B));

    final pink = BastionTheme.pinkOverload.palette;
    expect(pink.brightness, Brightness.light);
    expect(pink.bg, const Color(0xFFFFF0FA));
    expect(pink.bg3, const Color(0xFFFFC1E3));
    expect(pink.accentDim, const Color(0xFFFF1493));
    expect(pink.ink, const Color(0xFF542044));

    final bare = BastionTheme.bareBeauty.palette;
    expect(bare.brightness, Brightness.light);
    expect(bare.bg, const Color(0xFFFFF0E7));
    expect(bare.bg3, const Color(0xFFE8B69E));
    expect(bare.secondary, const Color(0xFF754B43));
    expect(bare.ink, const Color(0xFF38232B));

    final okabe = BastionTheme.okabeIto.palette;
    expect(okabe.bg, const Color(0xFF161A20));
    expect(okabe.bg3, const Color(0xFF343C48));
    expect(okabe.me, OkabeIto.blue);
    expect(okabe.secondary, OkabeIto.orange);
    expect(okabe.ink, const Color(0xFFFFFFFF));

    final night = BastionTheme.nightOps.palette;
    expect(night.bg, const Color(0xFF080808));
    expect(night.bg3, const Color(0xFF251010));
    expect(night.accentDim, const Color(0xFF852722));
    expect(night.ink, const Color(0xFFF3D6D3));
  });

  test('Pink Overload and Bare Beauty look nothing alike', () {
    final pink = BastionTheme.pinkOverload.palette;
    final bare = BastionTheme.bareBeauty.palette;
    for (final pair in [
      (pink.bg, bare.bg),
      (pink.accent, bare.accent),
      (pink.bg3, bare.bg3),
      (pink.me, bare.me),
    ]) {
      expect(pair.$1 == pair.$2, isFalse);
    }
    // Pink Overload is far more saturated.
    expect(
      HSLColor.fromColor(pink.accent).saturation,
      greaterThan(HSLColor.fromColor(bare.accent).saturation + .3),
    );
  });

  test('Night Ops uses only reds', () {
    final p = BastionTheme.nightOps.palette;
    for (final c in [p.accent, p.secondary, p.tertiary, p.ink, p.alert]) {
      expect(c.r, greaterThan(c.g), reason: '$c');
      expect(c.r, greaterThan(c.b), reason: '$c');
    }
  });

  test('every palette keeps text, buttons and SOS readable (WCAG AA)', () {
    for (final entry in allPalettes.entries) {
      final p = entry.value;
      final s = MeshTheme.forPalette(p).colorScheme;
      final text = {
        'text': contrast(s.onSurface, s.surface),
        'secondary text': contrast(s.onSurfaceVariant, s.surfaceContainerHigh),
        'muted text': contrast(p.ink3, p.bg2),
        'faint text': contrast(p.ink4, p.bg),
        'button text': contrast(s.onPrimary, s.primary),
        'accent on page': contrast(p.accent, p.bg),
        'SOS on cards': contrast(p.alert, p.bg2),
        'SOS on page': contrast(p.alert, p.bg),
        'good signal on cards': contrast(p.signal, p.bg2),
        'warning on cards': contrast(p.warn, p.bg2),
        'chat bubble': contrast(p.meInk, p.me),
        'second color on page': contrast(p.secondary, p.bg),
        'third color on page': contrast(p.tertiary, p.bg),
        'second color on cards': contrast(p.secondary, p.bg2),
        'third color on cards': contrast(p.tertiary, p.bg2),
        'text on first container': contrast(p.ink, p.primaryContainer),
        'text on second container': contrast(p.ink, p.secondaryContainer),
        'text on third container': contrast(p.ink, p.tertiaryContainer),
      };
      final controls = {
        'strong lines': contrast(p.line3, p.bg),
        'accent on cards': contrast(p.accent, p.bg2),
      };
      for (final c in text.entries) {
        expect(
          c.value,
          greaterThanOrEqualTo(4.5),
          reason: '${entry.key}: ${c.key} ${c.value.toStringAsFixed(2)}',
        );
      }
      for (final c in controls.entries) {
        expect(
          c.value,
          greaterThanOrEqualTo(3),
          reason: '${entry.key}: ${c.key} ${c.value.toStringAsFixed(2)}',
        );
      }
      expect(s.brightness, p.brightness);
    }
  });

  test('SOS, warning and good signal stay three different colors', () {
    for (final entry in allPalettes.entries) {
      final p = entry.value;
      expect({p.signal, p.warn, p.alert}, hasLength(3), reason: entry.key);
      expect(p.alert == p.accent, isFalse, reason: entry.key);
    }
  });

  test('every palette has three distinct hues, not one accent on grey', () {
    for (final entry in allPalettes.entries) {
      final p = entry.value;
      expect(
        {p.accent, p.secondary, p.tertiary},
        hasLength(3),
        reason: entry.key,
      );
      final s = MeshTheme.forPalette(p).colorScheme;
      expect(s.secondary, p.secondary, reason: entry.key);
      expect(s.tertiary, p.tertiary, reason: entry.key);
      expect(s.secondary == p.warn, isFalse, reason: entry.key);
    }
  });

  test('the Okabe-Ito palette and node colors match the reference', () {
    expect(OkabeIto.categorical, const [
      Color(0xFFE69F00),
      Color(0xFF56B4E9),
      Color(0xFF009E73),
      Color(0xFFF0E442),
      Color(0xFF0072B2),
      Color(0xFFD55E00),
      Color(0xFFCC79A7),
    ]);
    final p = BastionTheme.okabeIto.palette;
    expect(p.accent, OkabeIto.skyBlue);
    expect(p.warn, OkabeIto.yellow);
    final types = [advTypeChat, advTypeRepeater, advTypeRoom, advTypeSensor];
    final colors = types.map(OkabeIto.nodeType).toSet();
    expect(colors, hasLength(4));
    expect(colors.every(OkabeIto.categorical.contains), isTrue);
    expect(MapPalette.repeater, OkabeIto.nodeType(advTypeRepeater));
    expect(MapPalette.sensor, OkabeIto.nodeType(advTypeSensor));
  });

  group('Seasonal', () {
    BastionSeason on(int month, int day, {bool holidays = true}) =>
        BastionSeason.forDate(DateTime(2026, month, day), holidays: holidays);

    test('follows the calendar', () {
      expect(on(3, 1), BastionSeason.spring);
      expect(on(5, 31), BastionSeason.spring);
      expect(on(6, 1), BastionSeason.summer);
      expect(on(8, 31), BastionSeason.summer);
      expect(on(9, 1), BastionSeason.autumn);
      expect(on(11, 30), BastionSeason.autumn);
      expect(on(12, 1), BastionSeason.winter);
      expect(on(1, 15), BastionSeason.winter);
      expect(on(2, 28), BastionSeason.winter);
    });

    test('switches to holidays only when they are on', () {
      expect(on(10, 16), BastionSeason.autumn);
      expect(on(10, 17), BastionSeason.halloween);
      expect(on(10, 31), BastionSeason.halloween);
      expect(on(11, 1), BastionSeason.autumn);
      expect(on(12, 10), BastionSeason.christmas);
      expect(on(12, 26), BastionSeason.christmas);
      expect(on(12, 27), BastionSeason.winter);
      expect(on(2, 6), BastionSeason.winter);
      expect(on(2, 14), BastionSeason.valentine);
      expect(on(2, 15), BastionSeason.winter);
      expect(on(10, 31, holidays: false), BastionSeason.autumn);
      expect(on(12, 25, holidays: false), BastionSeason.winter);
      expect(on(2, 14, holidays: false), BastionSeason.winter);
    });

    test('a chosen season overrides the date', () {
      final july = DateTime(2026, 7, 4);
      expect(BastionSeason.resolve('winter', now: july), BastionSeason.winter);
      expect(BastionSeason.resolve('auto', now: july), BastionSeason.summer);
      expect(
        BastionSeason.resolve('nonsense', now: july),
        BastionSeason.summer,
      );
    });

    test('only the Seasonal theme ever changes with the date', () {
      for (final t in BastionTheme.values) {
        if (t == BastionTheme.seasonal) continue;
        for (final date in [DateTime(2026, 1, 1), DateTime(2026, 10, 31)]) {
          expect(
            BastionTheme.paletteFor(t.id, season: 'spring', now: date),
            same(t.palette),
          );
        }
      }
      expect(
        BastionTheme.paletteFor('seasonal', now: DateTime(2026, 7, 1)),
        same(BastionSeason.summer.palette),
      );
      expect(
        BastionTheme.paletteFor(
          'seasonal',
          season: 'winter',
          now: DateTime(2026, 7, 1),
        ),
        same(BastionSeason.winter.palette),
      );
      // Autumn Frost people land on Seasonal and see autumn in the fall.
      expect(
        BastionTheme.paletteFor('autumn_frost', now: DateTime(2026, 11, 7)),
        same(BastionSeason.autumn.palette),
      );
    });

    test('the season choice survives a save and load', () {
      final saved = AppSettings().copyWith(
        seasonalSeason: 'valentine',
        seasonalHolidays: false,
      );
      final loaded = AppSettings.fromJson(saved.toJson());
      expect(loaded.seasonalSeason, 'valentine');
      expect(loaded.seasonalHolidays, isFalse);
      expect(AppSettings().seasonalSeason, 'auto');
      expect(AppSettings().seasonalHolidays, isTrue);
    });
  });

  test('the palette follows the chosen theme', () {
    MeshPalette.current = BastionTheme.pinkOverload.palette;
    expect(MeshPalette.accent, BastionTheme.pinkOverload.palette.accent);
    MeshPalette.current = BastionTheme.blaze.palette;
    expect(MeshPalette.accent, const Color(0xFFFF8A00));
    expect(MeshTheme.light().brightness, Brightness.light);
    expect(MeshTheme.dark().brightness, Brightness.dark);
  });

  for (final width in [280.0, 360.0, 800.0]) {
    testWidgets('eight cards at width $width and 2x text; choice persists', (
      tester,
    ) async {
      final settings = await freshSettings();
      await tester.binding.setSurfaceSize(Size(width, 1400));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(pickerApp(settings, textScale: 2));
      expect(tester.takeException(), isNull);
      for (final t in BastionTheme.values) {
        expect(find.byKey(ValueKey('theme-${t.id}')), findsOneWidget);
      }
      for (final old in ['Autumn Frost', 'Bubble Gum', 'Red light']) {
        expect(find.text(old), findsNothing);
      }
      final neon = find.byKey(const ValueKey('theme-neon_anarchy'));
      await tester.ensureVisible(neon);
      await tester.tap(neon);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(settings.settings.appTheme, 'neon_anarchy');
      final restored = AppSettingsService();
      await restored.loadSettings();
      expect(restored.settings.appTheme, 'neon_anarchy');
      await tester.pumpWidget(const SizedBox.shrink());
      restored.dispose();
      settings.dispose();
    });
  }

  testWidgets('the selected card says so in words, for screen readers too', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    final settings = await freshSettings();
    await tester.pumpWidget(pickerApp(settings));
    expect(find.text('Selected'), findsOneWidget);
    expect(
      tester.getSemantics(find.byKey(const ValueKey('theme-blaze'))),
      isSemantics(
        label: 'Blaze theme. Charcoal slate with hi-vis orange. Selected',
        isButton: true,
        isSelected: true,
        hasTapAction: true,
      ),
    );
    await tester.tap(find.byKey(const ValueKey('theme-tactical')));
    await tester.pumpAndSettle();
    expect(
      tester.getSemantics(find.byKey(const ValueKey('theme-tactical'))),
      isSemantics(
        label: 'Tactical theme. Olive, gunmetal and earth tones. Selected',
      ),
    );
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    handle.dispose();
    settings.dispose();
  });

  testWidgets('Seasonal shows its options and saves a chosen season', (
    tester,
  ) async {
    final settings = await freshSettings();
    await tester.binding.setSurfaceSize(const Size(400, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(pickerApp(settings));
    expect(find.text('Seasonal palette'), findsNothing);
    expect(find.text('Now: Autumn'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('theme-seasonal')));
    await tester.pumpAndSettle();
    expect(find.text('Seasonal palette'), findsOneWidget);
    expect(find.text('Following the date: Autumn.'), findsOneWidget);

    final winter = find.byKey(const ValueKey('season-winter'));
    await tester.ensureVisible(winter);
    await tester.tap(winter);
    await tester.pumpAndSettle();
    expect(settings.settings.seasonalSeason, 'winter');
    expect(find.text('Always Winter.'), findsOneWidget);
    // Holidays only apply when following the date.
    expect(
      tester
          .widget<SwitchListTile>(find.byKey(const ValueKey('season-holidays')))
          .onChanged,
      isNull,
    );

    final auto = find.byKey(const ValueKey('season-auto'));
    await tester.ensureVisible(auto);
    await tester.tap(auto);
    await tester.pumpAndSettle();
    final holidays = find.byKey(const ValueKey('season-holidays'));
    await tester.ensureVisible(holidays);
    await tester.tap(holidays);
    await tester.pumpAndSettle();
    expect(settings.settings.seasonalSeason, 'auto');
    expect(settings.settings.seasonalHolidays, isFalse);

    final restored = AppSettingsService();
    await restored.loadSettings();
    expect(restored.settings.appTheme, 'seasonal');
    expect(restored.settings.seasonalHolidays, isFalse);
    await tester.pumpWidget(const SizedBox.shrink());
    restored.dispose();
    settings.dispose();
  });
}
