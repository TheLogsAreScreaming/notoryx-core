import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meshcore_open/connector/meshcore_connector.dart';
import 'package:meshcore_open/connector/meshcore_protocol.dart';
import 'package:meshcore_open/l10n/app_localizations.dart';
import 'package:meshcore_open/models/contact.dart';
import 'package:meshcore_open/models/wardrive.dart';
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
}
