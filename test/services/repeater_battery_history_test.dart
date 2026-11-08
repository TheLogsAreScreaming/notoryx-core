import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meshcore_open/connector/meshcore_connector.dart';
import 'package:meshcore_open/connector/meshcore_protocol.dart';
import 'package:meshcore_open/l10n/app_localizations.dart';
import 'package:meshcore_open/models/battery_trend.dart';
import 'package:meshcore_open/models/contact.dart';
import 'package:meshcore_open/screens/battery_watch_screen.dart';
import 'package:meshcore_open/services/app_settings_service.dart';
import 'package:meshcore_open/services/repeater_battery_history.dart';
import 'package:meshcore_open/storage/prefs_manager.dart';
import 'package:meshcore_open/widgets/battery_watch_widgets.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

final radio = 'a' * 64;
final ridge = 'b' * 64;
final valley = 'c' * 64;
final t0 = DateTime(2026, 11, 1, 12);

List<BatterySample> series(
  List<int> mvs, {
  Duration step = const Duration(hours: 6),
}) => [for (final (i, mv) in mvs.indexed) BatterySample(t0.add(step * i), mv)];

Duration hours(int h) => Duration(hours: h);

void main() {
  group('analyzeBattery', () {
    BatteryTrend run(List<BatterySample> s, {DateTime? now}) =>
        analyzeBattery(s, chemistry: 'nmc', now: now ?? s.last.at);

    test('no readings is unknown', () {
      expect(
        analyzeBattery([], chemistry: 'nmc', now: t0).status,
        BatteryWatchStatus.unknown,
      );
    });

    test('a steady battery is fine, with a flat slope', () {
      final t = run(series([4000, 4010, 3990, 4000, 4005]));
      expect(t.status, BatteryWatchStatus.ok);
      expect(t.millivoltsPerDay!.abs(), lessThan(20));
      expect(t.daysToEmpty, isNull);
      expect(t.percent, 84);
    });

    test('falling 200 mV a day from 3.8 V is flagged, empty in ~4 days', () {
      // 50 mV every 6 h = 200 mV/day; 3800 - 3000 = 800 mV left.
      final t = run(series([4000, 3950, 3900, 3850, 3800]));
      expect(t.millivoltsPerDay, closeTo(-200, 0.01));
      expect(t.daysToEmpty, closeTo(4, 0.01));
      expect(t.status, BatteryWatchStatus.falling);
    });

    test('a slow fall is not flagged', () {
      final t = run(series([4000, 3995, 3990, 3985, 3980]));
      expect(t.status, BatteryWatchStatus.ok);
      expect(t.daysToEmpty, greaterThan(BatteryTrend.fallingDays));
    });

    test('low wins over falling', () {
      final t = run(series([3300, 3250, 3200]));
      expect(t.percent, lessThanOrEqualTo(BatteryTrend.lowPercent));
      expect(t.status, BatteryWatchStatus.low);
    });

    test('no slope from readings less than 12 hours apart', () {
      final t = run(series([4000, 3900, 3800], step: hours(1)));
      expect(t.millivoltsPerDay, isNull);
      expect(t.status, BatteryWatchStatus.ok);
    });

    test('no slope from only two readings', () {
      expect(
        run(series([4000, 3000], step: hours(24))).millivoltsPerDay,
        isNull,
      );
    });

    test('only the last week counts toward the slope', () {
      // A big drop three weeks ago, then a steady week.
      final s = [
        BatterySample(t0, 4200),
        BatterySample(t0.add(const Duration(days: 2)), 3500),
        ...[
          for (var d = 0; d <= 6; d++)
            BatterySample(t0.add(Duration(days: 14 + d)), 3900),
        ],
      ];
      final t = run(s);
      expect(t.millivoltsPerDay, closeTo(0, 0.01));
    });

    test('quiet after three days without a reading', () {
      final s = series([4000, 4000, 4000]);
      final t = run(s, now: s.last.at.add(const Duration(days: 3)));
      expect(t.status, BatteryWatchStatus.quiet);
    });

    test('uses the chemistry for empty and percent', () {
      final s = series([3250, 3240, 3230, 3220, 3210]);
      final nmc = analyzeBattery(s, chemistry: 'nmc', now: s.last.at);
      final lfp = analyzeBattery(s, chemistry: 'lifepo4', now: s.last.at);
      expect(nmc.status, BatteryWatchStatus.low);
      expect(lfp.percent, greaterThan(nmc.percent!));
      expect(lfp.daysToEmpty, greaterThan(nmc.daysToEmpty!));
    });
  });

  group('RepeaterBatteryHistory', () {
    late DateTime now;
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      now = t0;
    });

    RepeaterBatteryHistory make() =>
        RepeaterBatteryHistory(prefs, clock: () => now)..setScope(radio);

    test('records nothing without a radio', () {
      final h = RepeaterBatteryHistory(prefs, clock: () => now);
      h.record(ridge, 4000);
      expect(h.repeaterKeys, isEmpty);
    });

    test('readings within 10 minutes replace each other', () {
      final h = make();
      h.record(ridge, 4000);
      now = now.add(const Duration(minutes: 5));
      h.record(ridge, 3990);
      expect(h.samplesFor(ridge).map((s) => s.millivolts), [3990]);
      now = now.add(const Duration(minutes: 20));
      h.record(ridge, 3980);
      expect(h.samplesFor(ridge), hasLength(2));
    });

    test('drops readings older than 30 days and bad values', () {
      final h = make();
      h.record(ridge, 4000, at: now.subtract(const Duration(days: 31)));
      h.record(ridge, 0);
      h.record(ridge, 99999);
      h.record('not-a-key', 4000);
      expect(h.repeaterKeys, isEmpty);
    });

    test('caps the readings per repeater', () {
      final h = make();
      for (
        var i = 0;
        i < RepeaterBatteryHistory.maxSamplesPerRepeater + 20;
        i++
      ) {
        h.record(
          ridge,
          4000,
          at: t0.subtract(Duration(minutes: 11 * (500 - i))),
        );
      }
      expect(
        h.samplesFor(ridge),
        hasLength(RepeaterBatteryHistory.maxSamplesPerRepeater),
      );
    });

    test('saves per radio and loads back', () async {
      final h = make();
      h.record(ridge, 4000);
      now = now.add(const Duration(hours: 1));
      h.record(ridge, 3950);
      await h.flush();

      final again = make();
      expect(again.samplesFor(ridge).map((s) => s.millivolts), [4000, 3950]);

      again.setScope('d' * 64);
      expect(again.repeaterKeys, isEmpty, reason: 'another radio');
    });

    test('a corrupt store is ignored', () {
      prefs.setString('repeater_battery_history_v1_$radio', '{not json');
      expect(make().repeaterKeys, isEmpty);
    });

    test('clear forgets one repeater', () {
      final h = make();
      h.record(ridge, 4000);
      h.record(valley, 4000);
      h.clear(ridge);
      expect(h.repeaterKeys, [valley]);
    });

    test('the connector records every repeater battery update', () {
      final h = make();
      final connector = MeshCoreConnector()..batteryHistory = h;
      connector.updateRepeaterBatterySnapshot(ridge, 3870, source: 'status');
      expect(h.samplesFor(ridge).single.millivolts, 3870);
      connector.dispose();
    });
  });

  group('Battery watch UI', () {
    late SharedPreferences prefs;
    late DateTime now;
    late RepeaterBatteryHistory history;
    late MeshCoreConnector connector;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      PrefsManager.reset();
      await PrefsManager.initialize();
      prefs = await SharedPreferences.getInstance();
      now = DateTime.now();
      history = RepeaterBatteryHistory(prefs, clock: () => now)
        ..setScope(radio);
      connector = MeshCoreConnector()
        ..debugSetContacts([
          Contact(
            publicKey: Uint8List.fromList(List.filled(32, 0xbb)),
            name: 'Ridge',
            type: advTypeRepeater,
            pathLength: -1,
            path: Uint8List(0),
            lastSeen: now,
          ),
        ]);
    });

    // Let the history's one-second save timer run before the test ends.
    Future<void> settle(WidgetTester tester) =>
        tester.pump(const Duration(seconds: 2));

    tearDown(() => connector.dispose());

    Future<void> pump(WidgetTester tester, Widget child) => tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AppSettingsService()),
          ChangeNotifierProvider<MeshCoreConnector>.value(value: connector),
          ChangeNotifierProvider<RepeaterBatteryHistory?>.value(value: history),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: child,
        ),
      ),
    );

    testWidgets('empty screen explains where readings come from', (
      tester,
    ) async {
      await pump(tester, const BatteryWatchScreen());
      expect(
        find.textContaining('No repeater battery readings yet'),
        findsOneWidget,
      );
    });

    testWidgets('lists the most worrying repeater first, with a chart', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      for (var i = 4; i >= 0; i--) {
        history.record(valley, 4000, at: now.subtract(Duration(hours: 6 * i)));
        history.record(
          ridge,
          3800 + 50 * i,
          at: now.subtract(Duration(hours: 6 * i)),
        );
      }
      await pump(tester, const BatteryWatchScreen());
      expect(find.text('Ridge'), findsOneWidget);
      expect(find.text('Unknown repeater'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('Ridge')).dy,
        lessThan(tester.getTopLeft(find.text('Unknown repeater')).dy),
      );
      expect(find.text('Falling fast'), findsOneWidget);
      expect(find.text('Looks fine'), findsOneWidget);
      expect(find.text('Empty in about 4 days at this rate'), findsOneWidget);
      expect(find.text('−0.20 V a day over the last week'), findsOneWidget);
      expect(
        find.bySemanticsLabel(
          'Battery chart: 5 readings, between 3.80 V and 4.00 V',
        ),
        findsOneWidget,
      );
      handle.dispose();
      await settle(tester);
    });

    testWidgets('clear removes a repeater', (tester) async {
      history.record(ridge, 4000);
      await pump(tester, const BatteryWatchScreen());
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Clear history'));
      await tester.pumpAndSettle();
      expect(find.text('Ridge'), findsNothing);
      expect(find.text('History cleared'), findsOneWidget);
      await settle(tester);
    });

    testWidgets('trend card hides until there is a reading', (tester) async {
      await pump(tester, Scaffold(body: BatteryTrendCard(repeaterKey: ridge)));
      expect(find.text('Battery history'), findsNothing);
      history.record(ridge, 4000);
      await tester.pump();
      expect(find.text('Battery history'), findsOneWidget);
      expect(find.text('Readings in 30 days: 1'), findsOneWidget);
      expect(find.text('Not enough readings yet'), findsNothing);
      await settle(tester);
    });

    testWidgets('fits a 320-wide screen at large text', (tester) async {
      tester.view.physicalSize = const Size(320, 800);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      for (var i = 4; i >= 0; i--) {
        history.record(
          ridge,
          3800 + 50 * i,
          at: now.subtract(Duration(hours: 6 * i)),
        );
      }
      await pump(tester, const BatteryWatchScreen());
      expect(tester.takeException(), isNull);
      await settle(tester);
    });
  });
}
