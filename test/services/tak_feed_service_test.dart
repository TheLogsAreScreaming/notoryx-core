import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:meshcore_open/connector/meshcore_connector.dart';
import 'package:meshcore_open/connector/meshcore_protocol.dart';
import 'package:meshcore_open/models/contact.dart';
import 'package:meshcore_open/services/tak_feed_service.dart';
import 'package:meshcore_open/storage/prefs_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _now = DateTime.utc(2026, 11, 27, 12);

Contact _node(
  String name,
  int b, {
  int type = advTypeChat,
  double? lat = 44.5,
  double? lon = -72.1,
  Duration age = const Duration(minutes: 5),
}) => Contact(
  publicKey: Uint8List.fromList(List.filled(32, b)),
  name: name,
  type: type,
  pathLength: -1,
  path: Uint8List(0),
  latitude: lat,
  longitude: lon,
  lastSeen: _now.subtract(age),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MeshCoreConnector connector;
  late List<(String, int, List<List<int>>)> sent;
  late TakFeedService feed;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    PrefsManager.reset();
    await PrefsManager.initialize();
    connector = MeshCoreConnector()
      ..debugSetContacts([
        _node('Hiker', 0x11),
        _node('Ridge <RPT>', 0x22, type: advTypeRepeater),
        _node('No fix', 0x33, lat: null, lon: null),
        _node('Old', 0x44, age: const Duration(days: 2)),
      ]);
    sent = [];
    feed = TakFeedService(
      connector: () => connector,
      send: (h, p, d) async => sent.add((h, p, d)),
      clock: () => _now,
    )..load();
  });

  tearDown(() {
    feed.dispose();
    connector.dispose();
  });

  test('off until turned on; sends nothing while off', () async {
    expect(feed.enabled, isFalse);
    await feed.sendNow();
    expect(sent, isEmpty);
  });

  test('sends recent nodes with a position, typed by role', () async {
    await feed.setEnabled(true);
    expect(sent, hasLength(1));
    final (host, port, datagrams) = sent.single;
    expect((host, port), ('127.0.0.1', 4242));
    final xml = datagrams.map(utf8.decode).toList();
    expect(xml, hasLength(2), reason: 'no-fix and 2-day-old nodes left out');
    expect(xml[0], contains('callsign="Hiker"'));
    expect(xml[0], contains('type="a-f-G-U-C"'));
    expect(xml[1], contains('type="a-f-G-I-U-T"'));
    // Names are escaped, never raw XML.
    expect(xml[1], contains('callsign="Ridge &lt;RPT&gt;"'));
    expect(xml[0], contains('stale="2026-11-27T12:03:00.000Z"'));
    expect(xml[0], contains('lat="44.500000" lon="-72.100000"'));
    expect(feed.lastSentCount, 2);
    expect(PrefsManager.instance.getBool(TakFeedService.enabledKey), isTrue);
  });

  test('uids are stable per node', () {
    final a = TakFeedService.pointFor(_node('A', 0xAB), _now);
    final b = TakFeedService.pointFor(_node('A renamed', 0xAB), _now);
    expect(a.uid, b.uid);
    expect(a.uid, startsWith('MESHCORE-ABABABAB'));
  });

  test('a bad target is refused and nothing changes', () async {
    expect(await feed.setTarget('', 4242), isFalse);
    expect(await feed.setTarget('10.0.0.9', 70000), isFalse);
    expect(feed.host, '127.0.0.1');
    expect(await feed.setTarget(' 10.0.0.9 ', 6969), isTrue);
    expect((feed.host, feed.port), ('10.0.0.9', 6969));
  });

  test('a send failure is reported, not thrown', () async {
    final failing = TakFeedService(
      connector: () => connector,
      send: (_, _, _) async => throw StateError('no route'),
      clock: () => _now,
    );
    addTearDown(failing.dispose);
    await failing.setEnabled(true);
    expect(failing.lastError, contains('no route'));
  });
}
