import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meshcore_open/connector/meshcore_connector.dart';
import 'package:meshcore_open/connector/meshcore_protocol.dart';
import 'package:meshcore_open/l10n/app_localizations.dart';
import 'package:meshcore_open/models/contact.dart';
import 'package:meshcore_open/models/wardrive.dart';
import 'package:meshcore_open/models/wardrive_coverage.dart';
import 'package:meshcore_open/screens/wardrive_noise_screen.dart';
import 'package:meshcore_open/screens/wardrive_screen.dart';
import 'package:meshcore_open/services/coverage_hex_service.dart';
import 'package:meshcore_open/services/wardrive_service.dart';
import 'package:meshcore_open/storage/prefs_manager.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Radio extends MeshCoreConnector {
  @override
  bool get isConnected => false;
  @override
  List<Contact> get allContactsUnfiltered => [
    Contact(
      publicKey: Uint8List.fromList([0xA1, 0xB2, ...List.filled(30, 7)]),
      name: 'Hilltop',
      type: advTypeRepeater,
      pathLength: 0,
      path: Uint8List(0),
      lastSeen: DateTime.now(),
    ),
  ];
}

void main() {
  late _Radio radio;
  late WardriveService service;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    PrefsManager.reset();
    await PrefsManager.initialize();
    radio = _Radio();
    service = WardriveService(
      radio,
      fixes: () => const Stream<PositionFix>.empty(),
    )..load();
  });
  tearDown(() => service.dispose());

  Future<void> open(WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<MeshCoreConnector>.value(value: radio),
          ChangeNotifierProvider<WardriveService>.value(value: service),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: WardriveScreen(),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('picking a mode changes what timed pings send', (tester) async {
    await open(tester);
    await tester.tap(find.text('Trace'));
    await tester.pump();
    expect(service.settings.mode, WardriveMode.trace);
    expect(
      find.textContaining('zero-hop trace to the repeater you picked'),
      findsOneWidget,
    );
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('settings: toggles and the repeater picker', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);
    await open(tester);
    await tester.tap(find.byKey(const ValueKey('wardrive-settings')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    await tester.pump(const Duration(seconds: 1));
    await tester.ensureVisible(find.byKey(const ValueKey('wardrive-passive')));
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.byKey(const ValueKey('wardrive-passive')));
    await tester.pump();
    expect(service.settings.passive, isFalse);

    await tester.ensureVisible(
      find.byKey(const ValueKey('wardrive-trace-target')),
    );
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.byKey(const ValueKey('wardrive-trace-target')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text('Hilltop').last);
    await tester.pump(const Duration(seconds: 1));
    expect(service.settings.traceTarget, 'a1b2070707070707');
    expect(find.text('Hilltop'), findsWidgets);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('map chips, repeater stats and showing one repeater', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);
    final drive = WardriveSession(
      id: '1',
      startedAt: DateTime.utc(2026, 11, 20),
      pings: [
        WardrivePing(
          at: DateTime.utc(2026, 11, 20, 1),
          latitude: 41.328,
          longitude: -73.094,
          replies: const [
            WardriveReply(prefix: 'a1b2', snrThere: 3, snrHere: 5),
          ],
        ),
      ],
    );
    await PrefsManager.instance.setString(
      'notoryx_wardrive_sessions_v1',
      jsonEncode([drive.toJson()]),
    );
    service.load();
    await open(tester);

    await tester.tap(find.byKey(const ValueKey('wardrive-grid-size')));
    await tester.pump();
    expect(find.text('100 m squares'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('wardrive-all-drives')));
    await tester.pump();
    expect(find.text('All drives'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('wardrive-repeater-stats')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.textContaining('1 squares · best 3.0 dB'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('wardrive-stats-a1b2')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Only Hilltop'), findsOneWidget);

    await tester.tap(find.byTooltip('Show all'));
    await tester.pump();
    expect(find.text('Only Hilltop'), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('the guide opens from the menu, with no links', (tester) async {
    await open(tester);
    await tester.tap(find.byKey(const ValueKey('wardrive-menu')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.byKey(const ValueKey('wardrive-menu-guide')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Wardriving guide'), findsOneWidget);
    expect(find.text('Getting started'), findsOneWidget);
    expect(find.textContaining('http'), findsNothing);
    await tester.tap(find.text('Airtime manners'));
    await tester.pump(const Duration(seconds: 1));
    expect(find.textContaining('25 m rule'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('noise graph: summary and tapping a marker', (tester) async {
    final t0 = DateTime.utc(2026, 11, 21, 12);
    final drive = WardriveSession(
      id: 'n',
      startedAt: t0,
      noise: [
        for (var i = 0; i < 5; i++)
          NoiseSample(t0.add(Duration(minutes: i)), -115 + i * 5),
      ],
      pings: [
        WardrivePing(
          at: t0.add(const Duration(minutes: 2)),
          latitude: 1,
          longitude: 2,
          noiseFloor: -105,
          replies: const [WardriveReply(prefix: 'a1b2', snrHere: 4)],
        ),
      ],
    );
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: WardriveNoiseScreen(session: drive, nameOf: (_) => 'Hilltop'),
      ),
    );
    await tester.pump();
    expect(find.text('-115 to -95 dBm, average -105 dBm'), findsOneWidget);
    // The marker sits mid-way along the chart, at -105 dBm.
    final chart = tester.getRect(
      find.byKey(const ValueKey('wardrive-noise-chart')),
    );
    final x = chart.left + 28 + (chart.width - 28 - 8) / 2;
    final y = chart.top + 8 + (chart.height - 24) * (-90 - -105) / 30;
    await tester.tapAt(Offset(x, y));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Hilltop'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  test('the five square colours are told apart on every look', () {
    final colours = [
      for (final s in SquareStatus.values) wardriveStatusColor(s),
    ];
    expect(colours.toSet(), hasLength(SquareStatus.values.length));
    // Far enough apart in hue to read as different colours, not shades.
    final hues = [for (final c in colours) HSVColor.fromColor(c).hue];
    for (var i = 0; i < hues.length; i++) {
      for (var j = i + 1; j < hues.length; j++) {
        final d = (hues[i] - hues[j]).abs();
        expect(d > 180 ? 360 - d : d, greaterThan(15));
      }
    }
  });
}
