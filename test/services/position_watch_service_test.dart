import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:meshcore_open/connector/meshcore_connector.dart';
import 'package:meshcore_open/connector/meshcore_protocol.dart';
import 'package:meshcore_open/l10n/app_localizations.dart';
import 'package:meshcore_open/models/contact.dart';
import 'package:meshcore_open/models/position_watch.dart';
import 'package:meshcore_open/models/waypoint.dart';
import 'package:meshcore_open/screens/zone_alerts_screen.dart';
import 'package:meshcore_open/services/app_settings_service.dart';
import 'package:meshcore_open/services/position_watch_service.dart';
import 'package:meshcore_open/services/waypoint_store.dart';
import 'package:meshcore_open/storage/prefs_manager.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _lat = 45.0, _lon = -110.0;

Contact person(
  int n, {
  double? lat,
  double? lon,
  bool favorite = true,
  int type = advTypeChat,
}) => Contact(
  publicKey: Uint8List.fromList(List.filled(32, n)),
  name: 'Ridge $n',
  type: type,
  pathLength: 0,
  path: Uint8List(0),
  lastSeen: DateTime(2026, 11, 13),
  latitude: lat,
  longitude: lon,
  flags: favorite ? contactFlagFavorite : 0,
);

class _Radio extends MeshCoreConnector {
  bool connected = true;
  List<Contact> list = [];
  double? lat, lon;
  @override
  bool get isConnected => connected;
  @override
  bool get isLoadingContacts => false;
  @override
  List<Contact> get contacts => list;
  @override
  double? get selfLatitude => lat;
  @override
  double? get selfLongitude => lon;
  void changed() => notifyListeners();

  /// Notifies and waits out the connector's notify throttle.
  Future<void> tick() async {
    changed();
    await Future<void>.delayed(const Duration(milliseconds: 300));
  }
}

void main() {
  late _Radio radio;
  late List<PositionAlert> alerts;
  late PositionWatchService watch;

  PositionWatchService make({List<TrailOption> trails = const []}) =>
      PositionWatchService(
        radio,
        prefs: PrefsManager.instance,
        trails: () => trails,
        notify: (a) async => alerts.add(a),
        selfName: () => 'Me',
      );

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    PrefsManager.reset();
    await PrefsManager.initialize();
    radio = _Radio();
    alerts = [];
  });

  tearDown(() {
    watch.dispose();
    radio.dispose();
  });

  const camp = Zone(
    id: 'camp',
    name: 'Camp',
    lat: _lat,
    lon: _lon,
    radiusMeters: 200,
  );

  test('settings and zones survive a restart', () async {
    watch = make();
    await watch.setEnabled(true);
    await watch.setScope(WatchScope.everyone);
    await watch.setIncludeSelf(false);
    await watch.setTrail('track:1');
    await watch.setOffTrailMeters(250);
    await watch.saveZone(camp);
    watch.dispose();

    watch = make();
    expect(watch.enabled, isTrue);
    expect(watch.scope, WatchScope.everyone);
    expect(watch.includeSelf, isFalse);
    expect(watch.trailRef, 'track:1');
    expect(watch.offTrailMeters, 250);
    expect(watch.zones.single.name, 'Camp');
    await watch.deleteZone('camp');
    expect(watch.zones, isEmpty);
  });

  test('watches favourites with positions, and your own radio', () async {
    radio
      ..lat = _lat
      ..lon = _lon
      ..list = [
        person(1, lat: _lat, lon: _lon),
        person(2, lat: _lat, lon: _lon, favorite: false),
        person(3), // no position
        person(4, lat: _lat, lon: _lon, type: advTypeRepeater),
      ];
    watch = make();
    expect(watch.watchedPositions().map((p) => p.name), ['Me', 'Ridge 1']);
    await watch.setScope(WatchScope.everyone);
    expect(watch.watchedPositions().map((p) => p.name), [
      'Me',
      'Ridge 1',
      'Ridge 2',
    ]);
    await watch.setIncludeSelf(false);
    expect(watch.watchedPositions().first.name, 'Ridge 1');
  });

  test('alerts when a favourite leaves a zone, only while on', () async {
    radio.list = [person(1, lat: _lat, lon: _lon)];
    watch = make();
    await watch.saveZone(camp);
    radio.list = [person(1, lat: _lat + 0.01, lon: _lon)];
    await radio.tick();
    expect(alerts, isEmpty, reason: 'alerts are off');

    radio.list = [person(1, lat: _lat, lon: _lon)];
    await watch.setEnabled(true); // baseline: inside
    radio.list = [person(1, lat: _lat + 0.01, lon: _lon)];
    await radio.tick();
    expect(alerts.single.kind, PositionAlertKind.leftZone);
    expect(alerts.single.name, 'Ridge 1');
  });

  test('alerts when your radio wanders off the watched trail', () async {
    radio
      ..lat = _lat
      ..lon = _lon + 0.005;
    watch = make(
      trails: [
        TrailOption(
          ref: 'route:r',
          name: 'Ridge loop',
          points: [LatLng(_lat, _lon), LatLng(_lat, _lon + 0.01)],
        ),
      ],
    );
    await watch.setTrail('route:r');
    await watch.setEnabled(true);
    expect(watch.trail!.name, 'Ridge loop');
    radio.lat = _lat + 0.002; // ~220 m off
    await radio.tick();
    expect(alerts.single.kind, PositionAlertKind.offTrail);
    expect(alerts.single.key, WatchedPosition.selfKey);
    expect(alerts.single.name, 'Me');
  });

  test('a disconnect starts over without alerting', () async {
    radio.list = [person(1, lat: _lat, lon: _lon)];
    watch = make();
    await watch.saveZone(camp);
    await watch.setEnabled(true);
    radio.connected = false;
    await radio.tick();
    radio
      ..connected = true
      ..list = [person(1, lat: _lat + 0.01, lon: _lon)];
    await radio.tick();
    expect(alerts, isEmpty);
  });

  test('alert text names the person, zone and trail', () {
    final l10n = lookupAppLocalizations(const Locale('en'));
    final left = positionAlertText(
      l10n,
      const PositionAlert(
        kind: PositionAlertKind.leftZone,
        key: 'k',
        name: 'Sam',
        zone: camp,
      ),
    );
    expect(left.title, 'Left Camp');
    expect(left.body, 'Sam has left Camp.');
    final off = positionAlertText(
      l10n,
      const PositionAlert(
        kind: PositionAlertKind.offTrail,
        key: 'k',
        name: 'Sam',
        meters: 240,
      ),
      trailName: 'Ridge loop',
    );
    expect(off.body, 'Sam is 240 m from Ridge loop.');
    watch = make();
  });

  testWidgets('the screen adds a zone around a waypoint', (tester) async {
    final waypoints = WaypointStore(PrefsManager.instance);
    await waypoints.add(
      const Waypoint(id: 'w', name: 'Trailhead', lat: _lat, lon: _lon),
    );
    watch = make();
    final settings = AppSettingsService();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<MeshCoreConnector>.value(value: radio),
          ChangeNotifierProvider<WaypointStore>.value(value: waypoints),
          ChangeNotifierProvider<AppSettingsService>.value(value: settings),
          ChangeNotifierProvider<PositionWatchService?>.value(value: watch),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ZoneAlertsScreen(),
        ),
      ),
    );
    expect(find.textContaining('No zones yet'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('zones-add')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('zone-name')), 'Camp');
    await tester.tap(find.byKey(const ValueKey('zone-save')));
    await tester.pumpAndSettle();
    expect(watch.zones.single.name, 'Camp');
    expect(watch.zones.single.lat, _lat);
    expect(find.text('Camp'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('zones-enabled')));
    await tester.pumpAndSettle();
    expect(watch.enabled, isTrue);
  });
}
