import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:meshcore_open/connector/meshcore_protocol.dart';
import 'package:meshcore_open/helpers/path_hop_resolver.dart';
import 'package:meshcore_open/l10n/app_localizations.dart';
import 'package:meshcore_open/models/contact.dart';
import 'package:meshcore_open/screens/hop_tie_memory_screen.dart';
import 'package:meshcore_open/services/hop_tie_memory.dart';
import 'package:shared_preferences/shared_preferences.dart';

Contact _repeater(
  int prefix,
  int tag,
  String name, [
  double? lat,
  double? lon,
]) => Contact(
  publicKey: Uint8List(32)
    ..first = prefix
    ..last = tag,
  name: name,
  type: advTypeRepeater,
  pathLength: 0,
  path: Uint8List(0),
  latitude: lat,
  longitude: lon,
  lastSeen: DateTime.utc(2026),
);

void main() {
  const home = LatLng(47.6, -122.3);
  var now = DateTime.utc(2026, 11, 13);
  late HopTieMemory memory;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    now = DateTime.utc(2026, 11, 13);
    memory = HopTieMemory(
      prefs: await SharedPreferences.getInstance(),
      clock: () => now,
    );
  });

  final north = _repeater(0x3d, 1, 'North', 47.70, -122.30);
  final south = _repeater(0x3d, 2, 'South', 47.50, -122.30);

  List<String?> names(List<Contact> contacts, {LatLng? from = home}) =>
      PathHopResolver.resolve(
        pathBytes: [0x3d],
        contacts: contacts,
        endpoint: from,
        memory: memory,
      ).map((c) => c?.name).toList();

  test('a located pick is used again when there is no position', () {
    expect(names([north, _repeater(0x3d, 2, 'Far', 47.95, -122.3)]), ['North']);
    expect(names([north, _repeater(0x3d, 2, 'Far')], from: null), ['North']);
  });

  test('without a remembered pick, no position still means no name', () {
    expect(names([north, south], from: null), [null]);
  });

  test('picks expire after the TTL', () {
    names([north, _repeater(0x3d, 2, 'Far', 47.95, -122.3)]);
    now = now.add(const Duration(days: 31));
    expect(names([north, south], from: null), [null]);
  });

  test('a near tie goes to the remembered pick', () {
    // South is remembered for this spot.
    names([south, _repeater(0x3d, 1, 'Far', 47.95, -122.3)]);
    // North is about 11 m closer than South: a tie within 5 %.
    final nearlyNorth = _repeater(0x3d, 1, 'North', 47.6999, -122.30);
    expect(names([nearlyNorth, south]), ['South']);
  });

  test('a clear winner beats the remembered pick', () {
    names([south, _repeater(0x3d, 1, 'Far', 47.95, -122.3)]);
    final close = _repeater(0x3d, 1, 'Close', 47.61, -122.30);
    expect(names([close, south]), ['Close']);
  });

  test('margin 0 only lets exact ties use the memory', () {
    memory.marginPercent = 0;
    expect(memory.isTie(1000, 1000), isTrue);
    expect(memory.isTie(1000, 1001), isFalse);
    memory.marginPercent = 5;
    expect(memory.isTie(1000, 1050), isTrue);
    expect(memory.isTie(1000, 1051), isFalse);
  });

  test('settings and picks survive a restart; forget clears picks', () async {
    memory.ttlDays = 400;
    memory.marginPercent = -3;
    expect(memory.ttlDays, HopTieMemory.maxTtlDays);
    expect(memory.marginPercent, 0);
    memory.remember('self', '3d', 'abc');
    final again = HopTieMemory(
      prefs: await SharedPreferences.getInstance(),
      clock: () => now,
    );
    expect(again.ttlDays, HopTieMemory.maxTtlDays);
    expect(again.winner('self', '3D'), 'abc');
    again.forgetAll();
    expect(again.count, 0);
  });

  testWidgets('the screen steps the settings and forgets', (tester) async {
    memory.remember('self', '3d', 'abc');
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: HopTieMemoryScreen(memory: memory),
      ),
    );
    expect(find.text('30 d'), findsOneWidget);
    await tester.tap(
      find.descendant(
        of: find.byKey(const ValueKey('hop-tie-ttl')),
        matching: find.byTooltip('More'),
      ),
    );
    await tester.pump();
    expect(find.text('31 d'), findsOneWidget);
    expect(memory.ttlDays, 31);

    final forget = find.byKey(const ValueKey('hop-tie-forget'));
    await tester.ensureVisible(forget);
    expect(find.text('Forget remembered picks (1)'), findsOneWidget);
    await tester.tap(forget);
    await tester.pump();
    expect(memory.count, 0);
  });
}
