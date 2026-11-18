import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:meshcore_open/connector/meshcore_protocol.dart';
import 'package:meshcore_open/l10n/app_localizations.dart';
import 'package:meshcore_open/models/contact.dart';
import 'package:meshcore_open/models/radio_rx_packet.dart';
import 'package:meshcore_open/models/traffic_route.dart';
import 'package:meshcore_open/services/traffic_controller.dart';
import 'package:meshcore_open/widgets/map_toolbar.dart';
import 'package:meshcore_open/widgets/traffic_route_card.dart';

final _t0 = DateTime.now();

Contact _repeater(int first, String name, {double? lat, double? lon}) =>
    Contact(
      publicKey: Uint8List.fromList([first, ...List.filled(31, 1)]),
      name: name,
      type: advTypeRepeater,
      pathLength: -1,
      path: Uint8List(0),
      latitude: lat,
      longitude: lon,
      lastSeen: _t0,
    );

RadioRxPacket _channelPacket(List<int> path, {int salt = 0}) => RadioRxPacket(
  raw: Uint8List.fromList([
    (payloadTypeGRPTXT << 2) | 1,
    path.length,
    ...path,
    0x11,
    salt,
    2,
    3,
  ]),
  snr: 12,
  rssi: -33,
  receivedAt: _t0,
);

Widget _app(Widget child) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: child),
);

void main() {
  final contacts = [
    _repeater(0xA1, 'Alpha', lat: 40.3, lon: -75.3),
    _repeater(0xB2, 'Bravo'),
    _repeater(0xD4, 'Delta', lat: 40.1, lon: -75.1),
  ];

  test('controller builds routes, drops repeats and hidden types', () async {
    final packets = StreamController<RadioRxPacket>();
    final c = TrafficController(
      packets: packets.stream,
      contacts: () => contacts,
      selfPosition: () => const LatLng(40, -75),
      selfLabel: () => 'You',
      clock: () => _t0,
    );
    addTearDown(c.dispose);

    c.add(_channelPacket([0xA1, 0xB2, 0xD4]));
    expect(c.latest!.kind, TrafficKind.channel);
    expect(c.latest!.pathHops.map((h) => h.label), ['Alpha', 'Bravo', 'Delta']);
    expect(c.queue.active, hasLength(1));

    // The same flood heard again through another repeater.
    c.add(_channelPacket([0xA1, 0xD4]));
    expect(c.queue.active, hasLength(1));

    c.shown = {TrafficKind.advert};
    expect(c.latest, isNull);
    c.add(_channelPacket([0xA1], salt: 9));
    expect(c.latest, isNull);
    await packets.close();
  });

  testWidgets('route card shows route, type, signal and legend', (
    tester,
  ) async {
    final route = TrafficRoute(
      kind: TrafficKind.path,
      hops: const [
        TrafficHop(id: '1F', role: TrafficHopRole.origin),
        TrafficHop(id: 'A1', name: 'Alpha', point: LatLng(40.3, -75.3)),
        TrafficHop(id: 'B2', name: 'Bravo'),
        TrafficHop(
          id: 'You',
          name: 'You',
          point: LatLng(40, -75),
          role: TrafficHopRole.self,
        ),
      ],
      snr: 12,
      rssi: -33,
      hopCount: 2,
      isFlood: true,
      receivedAt: DateTime.now(),
      packetHash: 'x',
    );
    await tester.pumpWidget(_app(TrafficRouteCard(route: route, dark: true)));
    expect(find.text('1F → Alpha → Bravo'), findsOneWidget);
    expect(find.text('Heard from Bravo · 12 dB'), findsOneWidget);
    expect(
      find.textContaining('Flood 2 · -33 dBm · SNR 12 · 2 not on map'),
      findsOneWidget,
    );
    expect(find.text('Not on map: 1F, Bravo'), findsOneWidget);
    // Pill + legend both say "Path".
    expect(find.text('Path'), findsNWidgets(2));
    for (final label in [
      'Advert',
      'Direct message',
      'Channel message',
      'Acknowledgement',
      'Trace',
    ]) {
      expect(find.text(label), findsOneWidget);
    }
  });

  testWidgets('route card waits for the first packet', (tester) async {
    await tester.pumpWidget(
      _app(const TrafficRouteCard(route: null, dark: false)),
    );
    expect(find.text('Listening for packets…'), findsOneWidget);
  });

  testWidgets('toolbar buttons fire and the active mode is marked', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      _app(
        Align(
          alignment: Alignment.centerRight,
          child: MapToolbar(
            dark: true,
            items: [
              MapToolbarItem(
                key: const ValueKey('t'),
                icon: Icons.route,
                label: 'Traffic',
                selected: true,
                onPressed: () => taps++,
              ),
              MapToolbarItem(
                icon: Icons.open_in_full,
                label: 'Fit all',
                showLabel: false,
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
    await tester.tap(find.byKey(const ValueKey('t')));
    expect(taps, 1);
    expect(find.text('Traffic'), findsOneWidget);
    expect(find.text('Fit all'), findsNothing);
    expect(find.byTooltip('Fit all'), findsOneWidget);
    expect(
      tester.getSemantics(find.bySemanticsLabel('Traffic')),
      matchesSemantics(
        label: 'Traffic',
        isButton: true,
        hasToggledState: true,
        isToggled: true,
        hasTapAction: true,
        hasEnabledState: true,
        isEnabled: true,
      ),
    );
  });
}
