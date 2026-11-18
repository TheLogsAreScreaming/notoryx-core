// Renders the live traffic map (route mid-flight, route card, toolbar) to a
// PNG for design review. Skipped unless PREVIEW_OUT is set:
//   PREVIEW_OUT=/some/dir flutter test test/preview/traffic_map_preview_test.dart
import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:meshcore_open/connector/meshcore_protocol.dart';
import 'package:meshcore_open/l10n/app_localizations.dart';
import 'package:meshcore_open/models/contact.dart';
import 'package:meshcore_open/models/radio_rx_packet.dart';
import 'package:meshcore_open/services/traffic_controller.dart';
import 'package:meshcore_open/theme/mesh_theme.dart';
import 'package:meshcore_open/widgets/map_toolbar.dart';
import 'package:meshcore_open/widgets/traffic_map_layer.dart';
import 'package:meshcore_open/widgets/traffic_route_card.dart';

Future<void> _loadFonts() async {
  Future<void> load(String family, List<String> paths) async {
    final loader = FontLoader(family);
    for (final p in paths) {
      final bytes = File(p).readAsBytesSync();
      loader.addFont(Future.value(ByteData.view(bytes.buffer)));
    }
    await loader.load();
  }

  List<String> files(String prefix) => Directory('assets/fonts')
      .listSync()
      .whereType<File>()
      .map((f) => f.path)
      .where((p) => p.split('/').last.startsWith(prefix) && p.endsWith('.ttf'))
      .toList();
  await load('Inter', files('Inter-'));
  await load(MeshFonts.mono, files('JetBrainsMono-'));
  final sdk = Platform.environment['FLUTTER_ROOT']!;
  await load('MaterialIcons', [
    '$sdk/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
  ]);
}

Contact _repeater(int first, String name, double lat, double lon) => Contact(
  publicKey: Uint8List.fromList([first, ...List.filled(31, first)]),
  name: name,
  type: advTypeRepeater,
  pathLength: -1,
  path: Uint8List(0),
  latitude: lat,
  longitude: lon,
  lastSeen: DateTime.now(),
);

void main() {
  final out = Platform.environment['PREVIEW_OUT'];

  testWidgets('traffic map', (tester) async {
    await tester.runAsync(_loadFonts);
    await tester.binding.setSurfaceSize(const Size(390, 844));
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    const self = LatLng(40.0, -75.0);
    final repeaters = [
      _repeater(0x1F, 'Ridge North', 40.62, -75.55),
      _repeater(0xF5, 'Hollow Tower', 40.42, -75.32),
      _repeater(0xC7, 'Water Tank', 40.25, -75.18),
      _repeater(0xBF, 'Mill Hill', 40.12, -75.06),
    ];
    final unlocated = Contact(
      publicKey: Uint8List.fromList([0x0D, ...List.filled(31, 9)]),
      name: 'Valley Relay',
      type: advTypeRepeater,
      pathLength: -1,
      path: Uint8List(0),
      lastSeen: DateTime.now(),
    );
    final t0 = DateTime.now();
    var now = t0;
    final packets = StreamController<RadioRxPacket>();
    final traffic = TrafficController(
      packets: packets.stream,
      contacts: () => [...repeaters, unlocated],
      selfPosition: () => self,
      selfLabel: () => 'You',
      clock: () => now,
    );
    addTearDown(traffic.dispose);

    traffic.add(
      RadioRxPacket(
        raw: Uint8List.fromList([
          (payloadTypePATH << 2) | 1,
          5,
          0x1F,
          0xF5,
          0x0D,
          0xC7,
          0xBF,
          0x01,
          0xA0,
          5,
          6,
        ]),
        snr: 12,
        rssi: -33,
        receivedAt: t0,
      ),
    );
    // Part way along the third mapped leg.
    now = t0.add(const Duration(milliseconds: 1400));

    Marker tower(LatLng p, {bool fresh = true}) => Marker(
      point: p,
      width: 40,
      height: 40,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF4F46E5),
          borderRadius: BorderRadius.circular(MeshRadii.sm),
          border: Border.all(
            color: fresh ? MapPalette.online : MapPalette.markerOutline,
            width: 3,
          ),
        ),
        child: const Icon(Icons.cell_tower, color: Colors.white, size: 20),
      ),
    );

    final boundary = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: boundary,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(brightness: Brightness.dark, fontFamily: 'Inter'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            backgroundColor: const Color(0xFF1B1D22),
            body: Stack(
              children: [
                FlutterMap(
                  options: const MapOptions(
                    backgroundColor: Color(0xFF1B1D22),
                    initialCenter: LatLng(40.3, -75.25),
                    initialZoom: 9.2,
                  ),
                  children: [
                    MarkerLayer(
                      markers: [
                        for (final r in repeaters)
                          tower(LatLng(r.latitude!, r.longitude!)),
                        tower(const LatLng(40.5, -74.9), fresh: false),
                        tower(const LatLng(40.05, -75.5), fresh: false),
                      ],
                    ),
                    TrafficMapLayer(controller: traffic),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: self,
                          width: 36,
                          height: 36,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: MapPalette.panelDark,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.person_pin_circle,
                              color: MapPalette.selected,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Positioned(
                  right: 12,
                  top: 90,
                  child: MapToolbar(
                    dark: true,
                    items: [
                      MapToolbarItem(
                        icon: Icons.near_me_outlined,
                        label: 'Locate',
                        onPressed: () {},
                      ),
                      MapToolbarItem(
                        icon: Icons.campaign_outlined,
                        label: 'Advert',
                        onPressed: () {},
                      ),
                      MapToolbarItem(
                        icon: Icons.filter_list,
                        label: 'Filter',
                        onPressed: () {},
                      ),
                      MapToolbarItem(
                        icon: Icons.route,
                        label: 'Traffic',
                        selected: true,
                        onPressed: () {},
                      ),
                      MapToolbarItem(
                        icon: Icons.search,
                        label: 'Search',
                        onPressed: () {},
                      ),
                      MapToolbarItem(
                        icon: Icons.open_in_full,
                        label: 'Fit all',
                        showLabel: false,
                        onPressed: () {},
                      ),
                      MapToolbarItem(
                        icon: Icons.more_horiz,
                        label: 'Options',
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 24,
                  child: TrafficRouteCard(route: traffic.latest, dark: true),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 16));

    await tester.runAsync(() async {
      final ro =
          boundary.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await ro.toImage(pixelRatio: 2);
      final png = await image.toByteData(format: ui.ImageByteFormat.png);
      File('$out/traffic_map_dark.png')
        ..createSync(recursive: true)
        ..writeAsBytesSync(png!.buffer.asUint8List());
    });
    await packets.close();
  }, skip: out == null);
}
