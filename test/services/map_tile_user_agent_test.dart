import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:meshcore_open/services/map_tile_cache_service.dart';

/// Tile servers ask each app to name itself in the User-Agent. These checks
/// keep every map in the app sending this app's own ID.
void main() {
  test('tile requests name this app', () {
    final gradle = File('android/app/build.gradle.kts').readAsStringSync();
    final appId = RegExp(
      r'applicationId\s*=\s*"([^"]+)"',
    ).firstMatch(gradle)!.group(1);

    expect(MapTileCacheService.userAgentPackageName, appId);
  });

  test('no map layer hard-codes its own User-Agent ID', () {
    final literal = RegExp(r"userAgentPackageName:\s*'");
    final offenders = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .where((f) => literal.hasMatch(f.readAsStringSync()))
        .map((f) => f.path)
        .toList();

    expect(
      offenders,
      isEmpty,
      reason: 'use MapTileCacheService.userAgentPackageName',
    );
  });
}
