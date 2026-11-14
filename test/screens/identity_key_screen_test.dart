import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meshcore_open/connector/meshcore_connector.dart';
import 'package:meshcore_open/connector/meshcore_protocol.dart';
import 'package:meshcore_open/l10n/app_localizations.dart';
import 'package:meshcore_open/screens/identity_key_screen.dart';
import 'package:provider/provider.dart';

final _key = Uint8List.fromList(List.generate(64, (i) => i));
final _hex = _key.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

class _Radio extends MeshCoreConnector {
  final frames = StreamController<Uint8List>.broadcast();
  final sent = <Uint8List>[];
  List<int>? answer;
  bool connected = true;

  @override
  bool get isConnected => connected;
  @override
  Stream<Uint8List> get receivedFrames => frames.stream;
  @override
  Future<void> sendFrame(
    Uint8List data, {
    String? channelSendQueueId,
    bool expectsGenericAck = false,
    bool waitForGenericAck = false,
  }) async {
    sent.add(data);
    final reply = answer;
    if (reply != null && data[0] != cmdAppStart) {
      frames.add(Uint8List.fromList(reply));
    }
  }
}

Widget _app(_Radio radio, Widget child) =>
    ChangeNotifierProvider<MeshCoreConnector>.value(
      value: radio,
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: child,
      ),
    );

void main() {
  group('protocol', () {
    test('parses a key in hex, ignoring spaces and a 0x prefix', () {
      expect(parseIdentityKeyHex(_hex), _key);
      expect(parseIdentityKeyHex('0x${_hex.toUpperCase()}'), _key);
      expect(
        parseIdentityKeyHex('${_hex.substring(0, 64)}\n ${_hex.substring(64)}'),
        _key,
      );
    });

    test('rejects wrong length or non-hex', () {
      expect(parseIdentityKeyHex(_hex.substring(2)), isNull);
      expect(parseIdentityKeyHex('zz${_hex.substring(2)}'), isNull);
      expect(parseIdentityKeyHex(''), isNull);
    });

    test('builds frames and parses the export reply', () {
      expect(buildExportPrivateKeyFrame(), [cmdExportPrivateKey]);
      expect(buildImportPrivateKeyFrame(_key), [cmdImportPrivateKey, ..._key]);
      expect(
        () => buildImportPrivateKeyFrame(Uint8List(32)),
        throwsArgumentError,
      );
      expect(
        parsePrivateKeyFrame(Uint8List.fromList([respCodePrivateKey, ..._key])),
        _key,
      );
      expect(parsePrivateKeyFrame(Uint8List.fromList([respCodeOk])), isNull);
    });
  });

  group('connector', () {
    test('exports the key', () async {
      final radio = _Radio()..answer = [respCodePrivateKey, ..._key];
      expect(await radio.exportIdentityKey(), _key);
      expect(radio.sent.single, [cmdExportPrivateKey]);
    });

    test('reports firmware with key backup turned off', () async {
      final radio = _Radio()..answer = [respCodeDisabled];
      await expectLater(
        radio.exportIdentityKey(),
        throwsA(
          isA<IdentityKeyException>().having(
            (e) => e.failure,
            'failure',
            IdentityKeyFailure.disabled,
          ),
        ),
      );
    });

    test('reports an older firmware as turned off', () async {
      final radio = _Radio()..answer = [respCodeErr, errCodeUnsupportedCmd];
      await expectLater(
        radio.importIdentityKey(_key),
        throwsA(
          isA<IdentityKeyException>().having(
            (e) => e.failure,
            'failure',
            IdentityKeyFailure.disabled,
          ),
        ),
      );
    });

    test('imports the key then rereads self info', () async {
      final radio = _Radio()..answer = [respCodeOk];
      await radio.importIdentityKey(_key);
      expect(radio.sent.first, [cmdImportPrivateKey, ..._key]);
      expect(radio.sent.last.first, cmdAppStart);
    });

    test('a refused import throws rejected', () async {
      final radio = _Radio()..answer = [respCodeErr, 6];
      await expectLater(
        radio.importIdentityKey(_key),
        throwsA(
          isA<IdentityKeyException>().having(
            (e) => e.failure,
            'failure',
            IdentityKeyFailure.rejected,
          ),
        ),
      );
    });

    test('no answer times out', () async {
      final radio = _Radio();
      await expectLater(
        radio.exportIdentityKey(timeout: const Duration(milliseconds: 10)),
        throwsA(
          isA<IdentityKeyException>().having(
            (e) => e.failure,
            'failure',
            IdentityKeyFailure.timeout,
          ),
        ),
      );
    });

    test('not connected fails at once', () async {
      final radio = _Radio()..connected = false;
      await expectLater(
        radio.exportIdentityKey(),
        throwsA(isA<IdentityKeyException>()),
      );
      expect(radio.sent, isEmpty);
    });
  });

  group('screen', () {
    testWidgets('shows the key only after confirming', (tester) async {
      await tester.pumpWidget(
        _app(_Radio(), IdentityKeyScreen(exportKey: () async => _key)),
      );
      expect(find.byKey(const ValueKey('id-key-hex')), findsNothing);
      await tester.tap(find.byKey(const ValueKey('id-key-show')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();
      expect(find.text(_hex), findsOneWidget);
    });

    testWidgets('restore needs a valid key and a confirmation', (tester) async {
      Uint8List? imported;
      await tester.pumpWidget(
        _app(_Radio(), IdentityKeyScreen(importKey: (k) async => imported = k)),
      );
      final button = find.byKey(const ValueKey('id-key-import'));
      await tester.enterText(find.byKey(const ValueKey('id-key-input')), 'abc');
      await tester.pump();
      expect(find.textContaining('128 hex'), findsOneWidget);

      await tester.enterText(find.byKey(const ValueKey('id-key-input')), _hex);
      await tester.pump();
      await tester.ensureVisible(button);
      await tester.tap(button);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(imported, isNull);

      await tester.tap(button);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Replace identity'));
      await tester.pumpAndSettle();
      expect(imported, _key);
      expect(find.text('Identity replaced.'), findsOneWidget);
    });

    testWidgets('a turned-off radio says so', (tester) async {
      await tester.pumpWidget(
        _app(
          _Radio(),
          IdentityKeyScreen(
            exportKey: () async =>
                throw const IdentityKeyException(IdentityKeyFailure.disabled),
          ),
        ),
      );
      await tester.tap(find.byKey(const ValueKey('id-key-show')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();
      expect(find.textContaining('key backup turned off'), findsOneWidget);
    });
  });
}
