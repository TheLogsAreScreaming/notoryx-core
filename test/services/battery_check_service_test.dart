import 'dart:typed_data';

import 'package:fake_async/fake_async.dart';
import 'package:flutter/material.dart';
import 'package:meshcore_open/l10n/app_localizations.dart';
import 'package:meshcore_open/screens/battery_watch_screen.dart';
import 'package:meshcore_open/services/app_settings_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meshcore_open/connector/meshcore_connector.dart';
import 'package:meshcore_open/connector/meshcore_protocol.dart';
import 'package:meshcore_open/models/battery_trend.dart';
import 'package:meshcore_open/models/contact.dart';
import 'package:meshcore_open/services/battery_check_service.dart';
import 'package:meshcore_open/services/repeater_battery_history.dart';
import 'package:meshcore_open/storage/prefs_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

final radioKey = 'a' * 64;
final ridgeKey = 'bb' * 32;
final t0 = DateTime(2026, 11, 7, 12);

class _Radio extends MeshCoreConnector {
  final sent = <Uint8List>[];
  @override
  bool get isConnected => true;
  @override
  Future<void> sendFrame(
    Uint8List frame, {
    String? channelSendQueueId,
    bool expectsGenericAck = false,
    bool waitForGenericAck = false,
  }) async => sent.add(frame);

  int get telemetryRequests =>
      sent.where((f) => f.isNotEmpty && f[0] == cmdSendBinaryReq).length;
}

List<int> sentFrame(int tag, {int tripMs = 3000}) => [
  respCodeSent,
  0,
  ...[tag & 0xFF, (tag >> 8) & 0xFF, 0, 0],
  ...[tripMs & 0xFF, (tripMs >> 8) & 0xFF, 0, 0],
];

/// A telemetry reply with the battery at [mv] on LPP channel 1.
List<int> replyFrame(int tag, int mv) {
  final v = mv ~/ 10;
  return [
    pushCodeBinaryResponse,
    0,
    ...[tag & 0xFF, (tag >> 8) & 0xFF, 0, 0],
    1,
    116,
    (v >> 8) & 0xFF,
    v & 0xFF,
  ];
}

BatteryTrend trendOf(BatteryWatchStatus status) =>
    BatteryTrend(status: status, latest: BatterySample(t0, 3300), percent: 25);

void main() {
  group('BatteryCheckBudget', () {
    const budget = BatteryCheckBudget();
    final watched = ['r1', 'r2'];

    test('picks the most overdue repeater', () {
      expect(
        budget.next(
          watched: watched,
          lastTried: {
            'r1': t0.subtract(const Duration(hours: 7)),
            'r2': t0.subtract(const Duration(hours: 9)),
          },
          sent: [],
          interval: const Duration(hours: 6),
          now: t0,
        ),
        'r2',
      );
    });

    test('nothing before the interval is up', () {
      expect(
        budget.next(
          watched: ['r1'],
          lastTried: {'r1': t0.subtract(const Duration(hours: 5))},
          sent: [],
          interval: const Duration(hours: 6),
          now: t0,
        ),
        isNull,
      );
    });

    test('keeps 2 minutes between checks', () {
      expect(
        budget.next(
          watched: watched,
          lastTried: {},
          sent: [t0.subtract(const Duration(seconds: 90))],
          interval: const Duration(hours: 1),
          now: t0,
        ),
        isNull,
      );
    });

    test('at most 6 an hour', () {
      final sent = [
        for (var i = 1; i <= 6; i++) t0.subtract(Duration(minutes: i * 9)),
      ];
      expect(
        budget.next(
          watched: watched,
          lastTried: {},
          sent: sent,
          interval: const Duration(hours: 1),
          now: t0,
        ),
        isNull,
      );
      expect(
        budget.next(
          watched: watched,
          lastTried: {},
          sent: sent.sublist(1),
          interval: const Duration(hours: 1),
          now: t0,
        ),
        isNotNull,
      );
    });

    test('the interval floor is one hour', () {
      expect(BatteryCheckBudget.intervals.first, 1);
    });
  });

  group('BatteryAlertLatch', () {
    test('raises each kind once, until the repeater recovers', () {
      final latch = BatteryAlertLatch();
      expect(
        latch.update('r', trendOf(BatteryWatchStatus.falling), 0)?.kind,
        BatteryAlertKind.falling,
      );
      expect(latch.update('r', trendOf(BatteryWatchStatus.falling), 0), isNull);
      expect(
        latch.update('r', trendOf(BatteryWatchStatus.low), 0)?.kind,
        BatteryAlertKind.low,
      );
      expect(
        latch.update('r', trendOf(BatteryWatchStatus.falling), 0),
        isNull,
        reason: 'no "falling" after "low"',
      );
      expect(latch.update('r', trendOf(BatteryWatchStatus.ok), 0), isNull);
      expect(
        latch.update('r', trendOf(BatteryWatchStatus.low), 0)?.kind,
        BatteryAlertKind.low,
        reason: 'raised again after recovering',
      );
    });

    test('silent after 3 unanswered checks, cleared when it answers', () {
      final latch = BatteryAlertLatch();
      final ok = trendOf(BatteryWatchStatus.ok);
      expect(latch.update('r', ok, 2), isNull);
      expect(latch.update('r', ok, 3)?.kind, BatteryAlertKind.silent);
      expect(latch.update('r', ok, 4), isNull);
      expect(latch.update('r', ok, 0), isNull);
      expect(latch.update('r', ok, 3)?.kind, BatteryAlertKind.silent);
    });

    test('survives a save and load', () {
      final latch = BatteryAlertLatch()
        ..update('r', trendOf(BatteryWatchStatus.low), 0);
      final again = BatteryAlertLatch()..load(latch.toJson());
      expect(again.update('r', trendOf(BatteryWatchStatus.low), 0), isNull);
    });
  });

  group('BatteryCheckService', () {
    // Made inside each fakeAsync zone where timing matters: the connector's
    // first queued future must belong to that zone.
    _Radio makeRadio() => _Radio()
      ..debugSetContacts([
        Contact(
          publicKey: Uint8List.fromList(List.filled(32, 0xbb)),
          name: 'Ridge',
          type: advTypeRepeater,
          pathLength: 0,
          path: Uint8List(0),
          lastSeen: t0,
        ),
      ]);

    late _Radio radio;
    late RepeaterBatteryHistory history;
    late SharedPreferences prefs;
    late List<BatteryAlert> alerts;
    late DateTime now;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      PrefsManager.reset();
      await PrefsManager.initialize();
      prefs = await SharedPreferences.getInstance();
      now = t0;
      alerts = [];
      radio = makeRadio();
      history = RepeaterBatteryHistory(prefs, clock: () => now)
        ..setScope(radioKey);
      radio.batteryHistory = history;
    });

    BatteryCheckService make() =>
        BatteryCheckService(
            connector: radio,
            history: history,
            prefs: prefs,
            chemistryFor: (_) => 'nmc',
            alert: (a) async => alerts.add(a),
            clock: () => now,
          )
          ..start()
          ..setScope(radioKey);

    test('does nothing until a repeater is watched', () async {
      final checks = make();
      await checks.checkDue();
      expect(radio.telemetryRequests, 0);
      checks.dispose();
    });

    test('asks a watched repeater and records the answer', () {
      fakeAsync((async) {
        radio = makeRadio()..batteryHistory = history;
        final checks = make();
        checks.setWatched(ridgeKey, true);
        async.flushMicrotasks();
        checks.checkDue();
        // Path setup waits 100 ms.
        async.elapse(const Duration(milliseconds: 300));
        expect(radio.telemetryRequests, 1);
        expect(checks.isChecking, isTrue);

        radio.handleFrameForTest(sentFrame(7));
        radio.handleFrameForTest(replyFrame(99, 3500)); // someone else's
        expect(history.samplesFor(ridgeKey), isEmpty);
        radio.handleFrameForTest(replyFrame(7, 3870));
        async.flushMicrotasks();
        expect(history.samplesFor(ridgeKey).single.millivolts, 3870);
        expect(checks.isChecking, isFalse);

        // Not again until the interval is up.
        now = now.add(const Duration(hours: 1));
        checks.checkDue();
        // Path setup waits 100 ms.
        async.elapse(const Duration(milliseconds: 300));
        expect(radio.telemetryRequests, 1);
        now = now.add(const Duration(hours: 6));
        checks.checkDue();
        // Path setup waits 100 ms.
        async.elapse(const Duration(milliseconds: 300));
        expect(radio.telemetryRequests, 2);
        checks.dispose();
        async.elapse(const Duration(minutes: 1));
      });
    });

    test('no reply counts as a failure; three raise a silent alert', () {
      fakeAsync((async) {
        radio = makeRadio()..batteryHistory = history;
        final checks = make();
        checks.setWatched(ridgeKey, true);
        async.flushMicrotasks();
        for (var i = 0; i < 3; i++) {
          checks.checkDue();
          // Path setup waits 100 ms.
          async.elapse(const Duration(milliseconds: 300));
          radio.handleFrameForTest(sentFrame(10 + i));
          async.elapse(const Duration(seconds: 9)); // trip 3 s + 5 s
          now = now.add(const Duration(hours: 7));
        }
        expect(checks.failuresFor(ridgeKey), 3);
        expect(alerts.map((a) => a.kind), [BatteryAlertKind.silent]);
        checks.dispose();
      });
    });

    test('a low reading raises a low alert once', () {
      fakeAsync((async) {
        radio = makeRadio()..batteryHistory = history;
        final checks = make();
        checks.setWatched(ridgeKey, true);
        async.flushMicrotasks();
        history.record(ridgeKey, 3150);
        history.record(
          ridgeKey,
          3140,
          at: now.subtract(const Duration(hours: 1)),
        );
        async.flushMicrotasks();
        expect(alerts.map((a) => a.kind), [BatteryAlertKind.low]);
        history.record(ridgeKey, 3130);
        async.flushMicrotasks();
        expect(alerts, hasLength(1));
        checks.dispose();
        async.elapse(const Duration(seconds: 2));
      });
    });

    test('readings of unwatched repeaters never alert', () {
      fakeAsync((async) {
        radio = makeRadio()..batteryHistory = history;
        final checks = make();
        history.record(ridgeKey, 3100);
        async.flushMicrotasks();
        expect(alerts, isEmpty);
        checks.dispose();
        async.elapse(const Duration(seconds: 2));
      });
    });

    test('the watch list and interval are kept per radio', () async {
      final checks = make();
      await checks.setWatched(ridgeKey, true);
      await checks.setIntervalHours(12);
      await checks.setIntervalHours(2); // not allowed
      checks.dispose();

      final again = make();
      expect(again.isWatched(ridgeKey), isTrue);
      expect(again.intervalHours, 12);
      again.setScope('c' * 64);
      expect(again.watched, isEmpty);
      again.dispose();
    });
  });

  test('battery voltage comes from LPP channel 1', () {
    expect(
      batteryMillivoltsFromTelemetry(
        Uint8List.fromList([2, 116, 0x01, 0x90, 1, 116, 0x01, 0x83]),
      ),
      3870,
    );
    expect(batteryMillivoltsFromTelemetry(Uint8List(0)), isNull);
  });

  testWidgets('add a repeater, pick an interval, at 320 px and 2x text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 900);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    SharedPreferences.setMockInitialValues({});
    PrefsManager.reset();
    await PrefsManager.initialize();
    final prefs = await SharedPreferences.getInstance();
    final radio = _Radio()
      ..debugSetContacts([
        Contact(
          publicKey: Uint8List.fromList(List.filled(32, 0xbb)),
          name: 'Ridge',
          type: advTypeRepeater,
          pathLength: 0,
          path: Uint8List(0),
          lastSeen: t0,
        ),
      ]);
    final history = RepeaterBatteryHistory(prefs)..setScope(radioKey);
    final checks = BatteryCheckService(
      connector: radio,
      history: history,
      prefs: prefs,
      chemistryFor: (_) => 'nmc',
      alert: (_) async {},
    )..setScope(radioKey);
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AppSettingsService()),
          ChangeNotifierProvider<MeshCoreConnector>.value(value: radio),
          ChangeNotifierProvider<RepeaterBatteryHistory?>.value(value: history),
          ChangeNotifierProvider<BatteryCheckService?>.value(value: checks),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const BatteryWatchScreen(),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.byKey(const ValueKey('battery-add')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('battery-add')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ridge'));
    await tester.pumpAndSettle();
    expect(checks.isWatched(ridgeKey), isTrue);
    expect(find.text('Ridge'), findsOneWidget);
    expect(find.text('Not enough readings yet'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.ensureVisible(find.byKey(const ValueKey('battery-interval')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('battery-interval')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('12 h').last);
    await tester.pumpAndSettle();
    expect(checks.intervalHours, 12);

    final toggle = find.byKey(ValueKey('auto-$ridgeKey'));
    await tester.ensureVisible(toggle);
    await tester.pumpAndSettle();
    await tester.tap(toggle);
    await tester.pumpAndSettle();
    expect(checks.isWatched(ridgeKey), isFalse);
    checks.dispose();
    radio.dispose();
  });
}
