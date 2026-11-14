import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meshcore_open/connector/meshcore_connector.dart';
import 'package:meshcore_open/connector/meshcore_protocol.dart';
import 'package:meshcore_open/l10n/app_localizations.dart';
import 'package:meshcore_open/l10n/app_localizations_en.dart';
import 'package:meshcore_open/models/contact.dart';
import 'package:meshcore_open/models/waypoint.dart';
import 'package:meshcore_open/screens/map_list_screen.dart';
import 'package:meshcore_open/services/app_settings_service.dart';
import 'package:meshcore_open/storage/prefs_manager.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Contact _contact(
  int seed,
  String name,
  double? lat,
  double? lon, {
  int path = 0,
}) => Contact(
  publicKey: Uint8List.fromList(List.generate(32, (i) => i + seed)),
  name: name,
  type: advTypeRepeater,
  path: Uint8List(0),
  pathLength: path,
  latitude: lat,
  longitude: lon,
  lastSeen: DateTime.now().subtract(const Duration(minutes: 5)),
);

class _Radio extends MeshCoreConnector {
  _Radio(this.lat, this.lon, this.all);
  final double? lat, lon;
  final List<Contact> all;
  @override
  double? get selfLatitude => lat;
  @override
  double? get selfLongitude => lon;
  @override
  List<Contact> get allContactsUnfiltered => all;
}

void main() {
  setUp(() async {
    PrefsManager.reset();
    SharedPreferences.setMockInitialValues({});
    await PrefsManager.initialize();
  });

  Future<void> pump(
    WidgetTester tester,
    _Radio radio, {
    List<Waypoint> waypoints = const [],
  }) async {
    tester.view.physicalSize = const Size(1000, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<MeshCoreConnector>.value(value: radio),
          ChangeNotifierProvider<AppSettingsService>(
            create: (_) => AppSettingsService(),
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MapListScreen(waypoints: waypoints),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  test('distance and direction are words', () {
    final l10n = AppLocalizationsEn();
    expect(mapListWhere(l10n, 1.24, 45, imperial: false), '1.2 km north-east');
    expect(
      mapListWhere(l10n, null, null, imperial: false),
      contains('no position'),
    );
  });

  testWidgets('nodes nearest first with distance, freshness and route', (
    tester,
  ) async {
    final radio = _Radio(35.0, -80.0, [
      _contact(1, 'Far peak', 35.1, -80.0, path: 2),
      _contact(2, 'Near hut', 35.01, -79.99),
      _contact(3, 'Nowhere', null, null),
    ]);
    await pump(
      tester,
      radio,
      waypoints: const [
        Waypoint(id: 'w', name: 'Trailhead', lat: 34.99, lon: -80.0),
      ],
    );
    final near = tester.getTopLeft(find.text('Near hut')).dy;
    final far = tester.getTopLeft(find.text('Far peak')).dy;
    expect(near, lessThan(far));
    expect(find.text('Nowhere'), findsNothing);
    expect(find.textContaining('north-east'), findsOneWidget);
    expect(find.textContaining('heard 5m ago'), findsNWidgets(2));
    expect(find.textContaining('south'), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp(r'Nodes \(2\)')), findsOneWidget);
    final handle = tester.ensureSemantics();
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    handle.dispose();
  });

  testWidgets('without your position it says so and lists by name', (
    tester,
  ) async {
    final radio = _Radio(null, null, [
      _contact(1, 'Bravo', 35.1, -80.0),
      _contact(2, 'Alpha', 35.01, -79.99),
    ]);
    await pump(tester, radio);
    expect(
      tester.getTopLeft(find.text('Alpha')).dy,
      lessThan(tester.getTopLeft(find.text('Bravo')).dy),
    );
    expect(find.textContaining('your radio has no position'), findsNWidgets(2));
  });
}
