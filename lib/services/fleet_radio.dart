import 'dart:async';
import 'package:flutter/foundation.dart';

import '../connector/meshcore_connector.dart';
import '../connector/meshcore_protocol.dart';
import '../models/contact.dart';
import '../models/fleet.dart';
import '../models/path_selection.dart';
import 'repeater_command_service.dart';

/// What a status request brought back.
typedef FleetStatusReply = ({
  int batteryMv,
  int noiseFloor,
  int lastRssi,
  double lastSnr,
  int uptimeSecs,
  int errors,
});

/// The over-the-air requests Fleet makes, one at a time.
abstract class FleetRadio {
  /// True when logged in, false when refused, null on no answer.
  Future<bool?> login(Contact repeater, String password);

  Future<FleetStatusReply?> status(Contact repeater);

  /// The repeater's neighbour count, asking for no entries so the reply
  /// stays small.
  Future<int?> neighbourCount(Contact repeater);

  /// Runs one command-line [command]; null on no answer.
  Future<String?> command(Contact repeater, String command);
}

/// [FleetRadio] over the connected companion radio, with the same frames
/// and timeouts as the repeater screens.
class ConnectorFleetRadio implements FleetRadio {
  ConnectorFleetRadio(this._connector);

  final MeshCoreConnector _connector;

  static bool _samePrefix(Uint8List a, Uint8List b) =>
      a.length >= 6 &&
      b.length >= 6 &&
      listEquals(a.sublist(0, 6), b.sublist(0, 6));

  Future<(Duration, PathSelection)> _timeoutFor(
    Contact repeater,
    int bytes,
  ) async {
    final selection = await _connector.preparePathForContactSend(repeater);
    final ms = _connector.calculateTimeout(
      pathLength: selection.useFlood ? -1 : selection.hopCount,
      messageBytes: bytes < maxFrameSize ? maxFrameSize : bytes,
    );
    return (Duration(milliseconds: ms + 2000), selection);
  }

  /// Sends [frame] and waits for the first received frame [match] maps to
  /// a non-null value.
  Future<T?> _request<T>(
    Contact repeater,
    Uint8List frame,
    T? Function(Uint8List frame) match, {
    int replyBytes = maxFrameSize,
  }) async {
    final (timeout, selection) = await _timeoutFor(repeater, replyBytes);
    final completer = Completer<T?>();
    final sub = _connector.receivedFrames.listen((f) {
      if (f.isEmpty || completer.isCompleted) return;
      final v = match(f);
      if (v != null) completer.complete(v);
    });
    try {
      await _connector.sendFrame(frame);
      final result = await completer.future.timeout(
        timeout,
        onTimeout: () => null,
      );
      _connector.recordRepeaterPathResult(
        repeater,
        selection,
        result != null,
        null,
      );
      return result;
    } finally {
      await sub.cancel();
    }
  }

  @override
  Future<bool?> login(Contact repeater, String password) => _request<bool>(
    repeater,
    buildSendLoginFrame(repeater.publicKey, password),
    (f) {
      if (f[0] != pushCodeLoginSuccess && f[0] != pushCodeLoginFail) {
        return null;
      }
      if (f.length < 8 || !_samePrefix(f.sublist(2, 8), repeater.publicKey)) {
        return null;
      }
      return f[0] == pushCodeLoginSuccess;
    },
  );

  @override
  Future<FleetStatusReply?> status(Contact repeater) =>
      _request(repeater, buildSendStatusRequestFrame(repeater.publicKey), (f) {
        if (f[0] != pushCodeStatusResponse || f.length < 8) return null;
        if (!_samePrefix(f.sublist(2, 8), repeater.publicKey)) return null;
        return parseRepeaterStatusFrame(f);
      }, replyBytes: 60);

  @override
  Future<int?> neighbourCount(Contact repeater) {
    Uint8List? tag;
    return _request<int>(
      repeater,
      buildSendBinaryReq(
        repeater.publicKey,
        // [type][version][count][offset 16-bit][order by][key prefix length]
        payload: Uint8List.fromList([
          reqTypeGetNeighbors,
          0x00,
          0x00,
          0x00,
          0x00,
          0x00,
          0x06,
        ]),
      ),
      (f) {
        if (f[0] == respCodeSent && f.length >= 6) {
          tag ??= f.sublist(2, 6);
          return null;
        }
        if (f[0] != pushCodeBinaryResponse || f.length < 8 || tag == null) {
          return null;
        }
        if (!listEquals(f.sublist(2, 6), tag)) return null;
        return f[6] | (f[7] << 8);
      },
    );
  }

  @override
  Future<String?> command(Contact repeater, String command) async {
    final service = RepeaterCommandService(_connector);
    final sub = _connector.receivedFrames.listen((f) {
      if (f.isEmpty) return;
      if (f[0] != respCodeContactMsgRecv && f[0] != respCodeContactMsgRecvV3) {
        return;
      }
      final parsed = parseContactMessageText(f);
      if (parsed == null ||
          !_samePrefix(parsed.senderPrefix, repeater.publicKey)) {
        return;
      }
      service.handleResponse(repeater, parsed.text);
    });
    try {
      // One retry at most: Fleet is airtime-first.
      return await service.sendCommand(repeater, command, retries: 2);
    } catch (_) {
      return null;
    } finally {
      await sub.cancel();
      service.dispose();
    }
  }
}
