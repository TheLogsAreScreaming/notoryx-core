import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:meshcore_open/models/position_watch.dart';

// About 111 m per 0.001 degree of latitude.
const _lat = 45.0, _lon = -110.0;

WatchedPosition at(double dLat, double dLon, {String key = 'a'}) =>
    WatchedPosition(key: key, name: 'Alex', lat: _lat + dLat, lon: _lon + dLon);

const camp = Zone(
  id: 'camp',
  name: 'Camp',
  lat: _lat,
  lon: _lon,
  radiusMeters: 200,
);

void main() {
  group('distance', () {
    test('metersBetween matches a known distance', () {
      expect(
        metersBetween(_lat, _lon, _lat + 0.001, _lon),
        closeTo(111.2, 0.5),
      );
    });

    test('metersFromTrail measures to the nearest segment, not vertex', () {
      final trail = [LatLng(_lat, _lon), LatLng(_lat, _lon + 0.01)];
      // Beside the middle of a ~790 m segment, 0.001° north.
      expect(
        metersFromTrail(_lat + 0.001, _lon + 0.005, trail),
        closeTo(111.2, 1),
      );
      // Past the end, measured to the end point.
      expect(
        metersFromTrail(_lat, _lon + 0.011, trail),
        closeTo(metersBetween(_lat, _lon + 0.011, _lat, _lon + 0.01), 1),
      );
      expect(metersFromTrail(_lat, _lon, const []), isNull);
      expect(
        metersFromTrail(_lat + 0.001, _lon, [LatLng(_lat, _lon)]),
        closeTo(111.2, 0.5),
      );
    });

    test('formatShortDistance picks units', () {
      expect(formatShortDistance(120), '120 m');
      expect(formatShortDistance(1500), '1.5 km');
      expect(formatShortDistance(25000), '25 km');
      expect(formatShortDistance(100, imperial: true), '328 ft');
      expect(formatShortDistance(1609.344 * 2.5, imperial: true), '2.5 mi');
    });
  });

  group('Zone json', () {
    test('round-trips and rejects junk', () {
      final back = Zone.fromJson(
        const Zone(
          id: 'z',
          name: 'Trailhead',
          lat: 1,
          lon: 2,
          radiusMeters: 500,
          alertOn: ZoneAlertOn.leave,
        ).toJson(),
      )!;
      expect(back.name, 'Trailhead');
      expect(back.radiusMeters, 500);
      expect(back.alertOn, ZoneAlertOn.leave);
      expect(Zone.fromJson({'id': 'z'}), isNull);
      expect(
        Zone.fromJson({'id': 'z', 'name': 'n', 'lat': 95, 'lon': 0, 'r': 9}),
        isNull,
      );
      expect(
        Zone.fromJson({
          'id': 'z',
          'name': 'n',
          'lat': 1,
          'lon': 0,
          'r': 5,
        })!.radiusMeters,
        Zone.minRadius,
      );
    });
  });

  group('PositionWatcher zones', () {
    test('first sighting only records, even inside a zone', () {
      final w = PositionWatcher();
      expect(w.observe([at(0, 0)], zones: [camp]), isEmpty);
    });

    test('alerts once on leaving and once on coming back', () {
      final w = PositionWatcher();
      w.observe([at(0, 0)], zones: [camp]);
      // 330 m out: well past 200 m + slack.
      final left = w.observe([at(0.003, 0)], zones: [camp]);
      expect(left.single.kind, PositionAlertKind.leftZone);
      expect(left.single.zone!.id, 'camp');
      expect(w.observe([at(0.0035, 0)], zones: [camp]), isEmpty);
      final back = w.observe([at(0.001, 0)], zones: [camp]);
      expect(back.single.kind, PositionAlertKind.enteredZone);
    });

    test('wobbling on the edge does not repeat alerts', () {
      final w = PositionWatcher();
      w.observe([at(0.0017, 0)], zones: [camp]); // ~189 m, inside
      // ~210 m: outside the radius but inside the slack, still in.
      expect(w.observe([at(0.00189, 0)], zones: [camp]), isEmpty);
      expect(w.observe([at(0.0017, 0)], zones: [camp]), isEmpty);
    });

    test('respects enter-only and leave-only zones', () {
      final enterOnly = Zone(
        id: 'e',
        name: 'E',
        lat: _lat,
        lon: _lon,
        radiusMeters: 200,
        alertOn: ZoneAlertOn.enter,
      );
      final w = PositionWatcher();
      w.observe([at(0, 0)], zones: [enterOnly]);
      expect(w.observe([at(0.005, 0)], zones: [enterOnly]), isEmpty);
      expect(w.observe([at(0, 0)], zones: [enterOnly]), hasLength(1));
    });

    test('tracks each person separately', () {
      final w = PositionWatcher();
      w.observe(
        [at(0, 0, key: 'a'), at(0.01, 0, key: 'b')],
        zones: [camp],
      );
      final alerts = w.observe(
        [at(0.01, 0, key: 'a'), at(0, 0, key: 'b')],
        zones: [camp],
      );
      expect(
        {for (final a in alerts) a.key: a.kind},
        {'a': PositionAlertKind.leftZone, 'b': PositionAlertKind.enteredZone},
      );
    });
  });

  group('PositionWatcher trail', () {
    final trail = [LatLng(_lat, _lon), LatLng(_lat, _lon + 0.02)];

    test('alerts once when wandering off, re-arms after coming back', () {
      final w = PositionWatcher();
      List<PositionAlert> look(double dLat) => w.observe(
        [at(dLat, 0.01)],
        zones: const [],
        trail: trail,
        offTrailMeters: 100,
      );
      expect(look(0), isEmpty); // first sighting
      final off = look(0.0015); // ~167 m
      expect(off.single.kind, PositionAlertKind.offTrail);
      expect(off.single.meters, closeTo(166.8, 1));
      expect(look(0.002), isEmpty); // still off
      expect(look(0.0008), isEmpty); // ~89 m: not back yet (needs < 70 m)
      expect(look(0.0003), isEmpty); // back on
      expect(look(0.0015), hasLength(1)); // off again
    });

    test('starting off the trail does not alert', () {
      final w = PositionWatcher();
      expect(
        w.observe([at(0.01, 0.01)], zones: const [], trail: trail),
        isEmpty,
      );
      expect(
        w.observe([at(0.011, 0.01)], zones: const [], trail: trail),
        isEmpty,
      );
    });

    test('forgetTrail starts over', () {
      final w = PositionWatcher();
      w.observe([at(0, 0.01)], zones: const [], trail: trail);
      w.forgetTrail();
      expect(
        w.observe([at(0.01, 0.01)], zones: const [], trail: trail),
        isEmpty,
      );
    });
  });
}
