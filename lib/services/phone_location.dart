import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

/// One phone GPS reading.
typedef PhoneFix = ({
  double lat,
  double lon,
  double accuracyMeters,
  DateTime time,
});

/// The only file that uses the phone's GPS. The lite build (tool/lite)
/// replaces it with one that has none, which removes Google Play Services;
/// callers then fall back to the radio's position.
PhoneFix _fix(Position p) => (
  lat: p.latitude,
  lon: p.longitude,
  accuracyMeters: p.accuracy,
  time: p.timestamp,
);

/// Asks for permission if needed; null without permission.
Future<PhoneFix?> askForPhoneFix() async {
  var permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }
  if (permission == LocationPermission.denied ||
      permission == LocationPermission.deniedForever) {
    return null;
  }
  final p =
      await Geolocator.getLastKnownPosition() ??
      await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          timeLimit: Duration(seconds: 10),
        ),
      );
  return _fix(p);
}

/// A high-accuracy fix, reusing one under [maxAge] old. Throws without GPS.
Future<PhoneFix> freshPhoneFix(DateTime now, Duration maxAge) async {
  final last = await Geolocator.getLastKnownPosition();
  if (last != null && now.difference(last.timestamp) < maxAge) {
    return _fix(last);
  }
  return _fix(
    await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 8),
      ),
    ),
  );
}

/// Text for the notification Android shows while [phoneFixStream] runs
/// with the screen off. The app sets it in its own language.
({String title, String text}) backgroundFixNotice = (
  title: 'Wardrive running',
  text: 'Tracking your position for the coverage map',
);

/// High-accuracy fixes every 20 m. Throws without permission. With
/// [background] on Android, fixes keep coming with the screen off, behind a
/// notification ([backgroundFixNotice]).
Stream<PhoneFix> phoneFixStream({bool background = false}) async* {
  var permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }
  if (permission == LocationPermission.denied ||
      permission == LocationPermission.deniedForever) {
    throw StateError('Location permission was not granted.');
  }
  final LocationSettings settings =
      background && defaultTargetPlatform == TargetPlatform.android
      ? AndroidSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 20,
          foregroundNotificationConfig: ForegroundNotificationConfig(
            notificationTitle: backgroundFixNotice.title,
            notificationText: backgroundFixNotice.text,
            enableWakeLock: true,
          ),
        )
      : const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 20,
        );
  yield* Geolocator.getPositionStream(locationSettings: settings).map(_fix);
}

/// The last known fix, only if permission was already granted; never asks.
Future<PhoneFix?> lastKnownPhoneFix() async {
  final permission = await Geolocator.checkPermission();
  if (permission != LocationPermission.whileInUse &&
      permission != LocationPermission.always) {
    return null;
  }
  final p = await Geolocator.getLastKnownPosition();
  return p == null ? null : _fix(p);
}
