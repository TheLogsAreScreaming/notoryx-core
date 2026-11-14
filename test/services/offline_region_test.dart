import 'dart:io' as io;
import 'package:file/file.dart' show File;
import 'package:file/local.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:meshcore_open/services/app_settings_service.dart';
import 'package:meshcore_open/services/map_tile_cache_service.dart';

/// The smallest complete PNG: signature, a header chunk and IEND.
const _png = [
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, //
  0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52, //
  0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x02, 0x00, 0x00, 0x00,
  0x90, 0x77, 0x53, 0xDE, //
  0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
];

class _LocalCache implements BaseCacheManager {
  final Map<String, File> files = {};
  final List<String> requested = [];
  final List<String> removed = [];

  @override
  Future<void> removeFile(String key) async {
    removed.add(key);
    files.remove(key);
  }

  @override
  Future<FileInfo?> getFileFromCache(
    String key, {
    bool ignoreMemCache = false,
  }) async {
    requested.add(key);
    final file = files[key];
    return file == null
        ? null
        : FileInfo(
            file,
            FileSource.Cache,
            DateTime.now().add(const Duration(days: 1)),
            key,
          );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw StateError('Unexpected cache operation: ${invocation.memberName}');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late io.Directory temp;
  late _LocalCache local;
  late AppSettingsService settings;
  late MapTileCacheService cache;
  final bounds = LatLngBounds(const LatLng(0.1, 0.1), const LatLng(0.2, 0.2));
  const tile = 'https://tile.openstreetmap.org/3/4/3.png';
  setUp(() async {
    temp = await io.Directory.systemTemp.createTemp('bastion-map-test-');
    local = _LocalCache();
    settings = AppSettingsService();
    cache = MapTileCacheService(
      appSettingsService: settings,
      cacheManager: local,
    );
  });
  tearDown(() async {
    cache.dispose();
    settings.dispose();
    await temp.delete(recursive: true);
  });
  test('checks exact selected tiles locally without download calls', () async {
    final file = await const LocalFileSystem()
        .file('${temp.path}/tile.png')
        .writeAsBytes(_png);
    local.files[tile] = file;
    final result = await cache.verifyOfflineRegion(
      bounds: bounds,
      minZoom: 3,
      maxZoom: 3,
    );
    expect(result, (expected: 1, available: 1));
    expect(local.requested, [tile]);
  });
  test(
    'unrelated cached tile and deleted file cannot count as ready',
    () async {
      local.files['https://tile.openstreetmap.org/3/5/3.png'] =
          await const LocalFileSystem()
              .file('${temp.path}/other.png')
              .writeAsBytes([1]);
      local.files[tile] = const LocalFileSystem().file(
        '${temp.path}/deleted.png',
      );
      expect(
        await cache.verifyOfflineRegion(bounds: bounds, minZoom: 3, maxZoom: 3),
        (expected: 1, available: 0),
      );
    },
  );
  test('zero-byte cached files remain missing', () async {
    local.files[tile] = await const LocalFileSystem()
        .file('${temp.path}/empty.png')
        .writeAsBytes([]);
    expect(
      await cache.verifyOfflineRegion(bounds: bounds, minZoom: 3, maxZoom: 3),
      (expected: 1, available: 0),
    );
  });
  test('huge selections stop before reading cache files', () async {
    final world = LatLngBounds(const LatLng(-80, -170), const LatLng(80, 170));
    await expectLater(
      cache.verifyOfflineRegion(bounds: world, minZoom: 18, maxZoom: 18),
      throwsStateError,
    );
    expect(local.requested, isEmpty);
  });

  group('integrity', () {
    Future<File> write(String name, List<int> bytes) =>
        const LocalFileSystem().file('${temp.path}/$name').writeAsBytes(bytes);

    test('a cut-short PNG is damaged, not available', () async {
      local.files[tile] = await write('cut.png', _png.sublist(0, 30));
      final check = await cache.checkOfflineRegion(
        bounds: bounds,
        minZoom: 3,
        maxZoom: 3,
      );
      expect(check.available, 0);
      expect(check.damaged, 1);
      expect(check.missingByZoom, {3: 1});
      expect(local.removed, isEmpty, reason: 'only removed when asked');
    });

    test(
      'an error page saved as a tile is damaged and can be removed',
      () async {
        local.files[tile] = await write(
          'error.png',
          '<html><body>429 Too Many Requests</body></html>'.codeUnits,
        );
        final check = await cache.checkOfflineRegion(
          bounds: bounds,
          minZoom: 3,
          maxZoom: 3,
          removeDamaged: true,
        );
        expect(check.damaged, 1);
        expect(local.removed, [tile]);
        expect(
          await cache.verifyOfflineRegion(
            bounds: bounds,
            minZoom: 3,
            maxZoom: 3,
          ),
          (expected: 1, available: 0),
        );
      },
    );

    test('a complete area reports complete', () async {
      local.files[tile] = await write('ok.png', _png);
      final check = await cache.checkOfflineRegion(
        bounds: bounds,
        minZoom: 3,
        maxZoom: 3,
      );
      expect(check.complete, isTrue);
      expect(check.missingByZoom, isEmpty);
    });

    test('recognises whole JPEG and WebP files only', () {
      final jpeg = [0xFF, 0xD8, 0xFF, 0xE0, ...List.filled(20, 0), 0xFF, 0xD9];
      expect(MapTileCacheService.isCompleteImage(jpeg), isTrue);
      expect(
        MapTileCacheService.isCompleteImage(jpeg.sublist(0, jpeg.length - 2)),
        isFalse,
      );
      final body = [0x57, 0x45, 0x42, 0x50, ...List.filled(8, 0)];
      final size = body.length;
      final webp = [
        0x52, 0x49, 0x46, 0x46, //
        size & 0xff, size >> 8 & 0xff, 0, 0, ...body,
      ];
      expect(MapTileCacheService.isCompleteImage(webp), isTrue);
      expect(MapTileCacheService.isCompleteImage(webp.sublist(0, 14)), isFalse);
      expect(MapTileCacheService.isCompleteImage(const []), isFalse);
    });
  });
}
