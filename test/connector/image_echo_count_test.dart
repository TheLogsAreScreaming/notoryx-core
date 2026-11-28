import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:meshcore_open/connector/meshcore_connector.dart';
import 'package:meshcore_open/connector/meshcore_protocol.dart';
import 'package:meshcore_open/models/channel.dart';
import 'package:meshcore_open/services/image_chunk_transport.dart';
import 'package:meshcore_open/storage/prefs_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/mesh_packet_fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final psk = Uint8List.fromList(List.generate(16, (i) => 0xA0 + i));
  final channel = Channel(index: 1, name: 'Hike', psk: psk);
  // Our key starts 0x12 0x34, so our image sender prefix is 0x1234.
  final selfKey = Uint8List.fromList([0x12, 0x34, ...List.filled(30, 9)]);
  late MeshCoreConnector connector;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    PrefsManager.reset();
    await PrefsManager.initialize();
    connector = MeshCoreConnector()
      ..debugSetChannels([channel])
      ..debugSetSelfPublicKey(selfKey);
  });

  tearDown(() => connector.dispose());

  /// A repeater's re-flood of chunk [index] of [total] of image [imgId].
  void heard(
    int index,
    int total, {
    int imgId = 7,
    int prefix = 0x1234,
    List<int> path = const [0x21],
  }) => connector.handleFrameForTest([
    pushCodeLogRxData,
    0x1C,
    0xA4,
    ...groupDataPacket(
      psk: psk,
      dataType: dataTypeAeicImage,
      data: [
        (prefix >> 8) & 0xFF,
        prefix & 0xFF,
        imgId,
        ((index & 0x0F) << 4) | (total & 0x0F),
        1,
        2,
        3,
      ],
      path: path,
    ),
  ]);

  test('counts repeaters for the least-heard chunk of our own image', () {
    expect(connector.imageEchoCount(1, 7), 0);
    heard(0, 3, path: [0x21]);
    heard(1, 3, path: [0x21]);
    // Chunk 2 not heard yet: nothing to report.
    expect(connector.imageEchoCount(1, 7), 0);
    heard(2, 3, path: [0x21]);
    expect(connector.imageEchoCount(1, 7), 1);
    // A second repeater passes on chunks 0 and 1 only: still 1.
    heard(0, 3, path: [0x22]);
    heard(1, 3, path: [0x22]);
    expect(connector.imageEchoCount(1, 7), 1);
    heard(2, 3, path: [0x22]);
    expect(connector.imageEchoCount(1, 7), 2);
    // The same copy heard twice is not another repeater.
    heard(2, 3, path: [0x22]);
    expect(connector.imageEchoCount(1, 7), 2);
  });

  test('ignores other senders, parity chunks and direct hops', () {
    heard(0, 1, prefix: 0x9999);
    expect(connector.imageEchoCount(1, 7), 0);
    heard(1, 1); // index == total: the parity chunk
    expect(connector.imageEchoCount(1, 7), 0);
    heard(0, 1, path: const []); // zero hops: not a repeat
    expect(connector.imageEchoCount(1, 7), 0);
    heard(0, 1);
    expect(connector.imageEchoCount(1, 7), 1);
  });
}
