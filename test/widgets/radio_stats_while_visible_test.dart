import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meshcore_open/connector/meshcore_connector.dart';
import 'package:meshcore_open/connector/meshcore_protocol.dart';
import 'package:meshcore_open/widgets/radio_stats_while_visible.dart';
import 'package:provider/provider.dart';

class _StatsRadio extends MeshCoreConnector {
  final List<Uint8List> sent = [];

  @override
  bool get isConnected => true;

  @override
  bool get supportsCompanionRadioStats => true;

  @override
  Future<void> sendFrame(
    Uint8List frame, {
    String? channelSendQueueId,
    bool expectsGenericAck = false,
    bool waitForGenericAck = false,
  }) async {
    sent.add(frame);
  }
}

void main() {
  testWidgets('asks the radio for stats as soon as the screen shows', (
    tester,
  ) async {
    final radio = _StatsRadio();
    final statsFrame = buildGetStatsFrame(statsTypeRadio);
    await tester.pumpWidget(
      ChangeNotifierProvider<MeshCoreConnector>.value(
        value: radio,
        child: const MaterialApp(
          home: RadioStatsWhileVisible(child: Text('home')),
        ),
      ),
    );
    await tester.pump();
    expect(radio.sent.where((f) => listEquals(f, statsFrame)), hasLength(1));

    // Leaving the screen stops the polling.
    await tester.pumpWidget(
      ChangeNotifierProvider<MeshCoreConnector>.value(
        value: radio,
        child: const MaterialApp(home: Text('elsewhere')),
      ),
    );
    radio.sent.clear();
    await tester.pump(const Duration(minutes: 2));
    expect(radio.sent.where((f) => listEquals(f, statsFrame)), isEmpty);
  });
}
