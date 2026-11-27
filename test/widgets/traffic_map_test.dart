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
import 'package:meshcore_open/theme/mesh_theme.dart';
import 'package:meshcore_open/widgets/map_toolbar.dart';
import 'package:meshcore_open/widgets/node_map_pin.dart';
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
    expect(c.latestEntry!.info.hash, c.latest!.packetHash);

    // The same flood heard again through another repeater is drawn as a
    // branch of the same packet; the card keeps the first copy.
    final first = c.latest;
    c.add(_channelPacket([0xD4]));
    expect(c.queue.active, hasLength(2));
    expect(c.queue.activePackets, 1);
    expect(c.latest, same(first));
    // A copy that draws the same line adds nothing.
    c.add(_channelPacket([0xD4]));
    c.add(_channelPacket([0xA1, 0xD4]));
    expect(c.queue.active, hasLength(2));

    c.shown = {TrafficKind.advert};
    expect(c.latest, isNull);
    expect(c.latestEntry, isNull);
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
    // Bravo relayed it, so its SNR is only the last leg.
    expect(find.text('Last hop Bravo · 12 dB'), findsOneWidget);
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

  testWidgets('route card says heard from when the sender was heard direct', (
    tester,
  ) async {
    final route = TrafficRoute(
      kind: TrafficKind.advert,
      hops: const [
        TrafficHop(id: '1F', name: 'Foxtrot', role: TrafficHopRole.origin),
        TrafficHop(id: 'You', name: 'You', role: TrafficHopRole.self),
      ],
      snr: 7,
      rssi: -80,
      hopCount: 0,
      isFlood: true,
      receivedAt: DateTime.now(),
      packetHash: 'y',
    );
    await tester.pumpWidget(_app(TrafficRouteCard(route: route, dark: false)));
    expect(find.text('Heard from Foxtrot · 7 dB'), findsOneWidget);
    expect(find.textContaining('Last hop'), findsNothing);
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

  testWidgets('repeater pins are rounded squares, green-ringed when heard', (
    tester,
  ) async {
    Widget pin({required bool repeater, required bool online}) => _app(
      Center(
        child: NodeMapPin(
          key: const ValueKey('wrap'),
          color: MapPalette.repeater,
          icon: Icons.cell_tower,
          dotBorderColor: MapPalette.panelDark,
          repeater: repeater,
          online: online,
        ),
      ),
    );
    Finder body() => find.descendant(
      of: find.byKey(const ValueKey('wrap')),
      matching: find.byType(Container),
    );

    await tester.pumpWidget(pin(repeater: true, online: true));
    var d = tester.widget<Container>(body().first).decoration! as BoxDecoration;
    expect(d.shape, BoxShape.rectangle);
    expect(d.borderRadius, isNotNull);
    expect((d.border! as Border).top.color, MapPalette.online);
    expect(find.byIcon(Icons.cell_tower), findsOneWidget);

    await tester.pumpWidget(pin(repeater: true, online: false));
    d = tester.widget<Container>(body().first).decoration! as BoxDecoration;
    expect((d.border! as Border).top.color, MapPalette.markerOutline);

    await tester.pumpWidget(pin(repeater: false, online: true));
    d = tester.widget<Container>(body().first).decoration! as BoxDecoration;
    expect(d.shape, BoxShape.circle);
  });

  testWidgets('toolbar drops labels when its height is short', (tester) async {
    Widget bar(double height) => _app(
      Align(
        alignment: Alignment.topRight,
        child: SizedBox(
          height: height,
          child: Align(
            alignment: Alignment.centerRight,
            child: MapToolbar(
              dark: true,
              items: [
                for (var i = 0; i < 7; i++)
                  MapToolbarItem(
                    icon: Icons.route,
                    label: 'Tool $i',
                    onPressed: () {},
                  ),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.pumpWidget(bar(600));
    expect(find.text('Tool 6'), findsOneWidget);

    await tester.pumpWidget(bar(330));
    expect(find.text('Tool 6'), findsNothing);
    expect(find.byTooltip('Tool 6'), findsOneWidget);
    // Seven 44 px buttons plus padding fit in 330 px without scrolling.
    expect(tester.getSize(find.byType(MapToolbar)).height, lessThan(330));
    expect(find.bySemanticsLabel('Tool 6'), findsOneWidget);
  });

  test('a channel streak starts at the sender when the app knows where', () {
    final packets = StreamController<RadioRxPacket>();
    final asked = <String>[];
    final c = TrafficController(
      packets: packets.stream,
      contacts: () => contacts,
      selfPosition: () => const LatLng(40, -75),
      selfLabel: () => 'You',
      clock: () => _t0,
      channelSender: (hash) {
        asked.add(hash);
        return const TrafficHop(
          id: 'AB',
          name: 'Sender',
          point: LatLng(40.5, -75.5),
          role: TrafficHopRole.origin,
        );
      },
    );
    addTearDown(c.dispose);
    c.add(_channelPacket([0xA1]));
    expect(asked, [c.latest!.packetHash]);
    expect(c.latest!.hops.first.label, 'Sender');
    expect(c.latest!.mapPoints.first, const LatLng(40.5, -75.5));
    unawaited(packets.close());
  });
}
