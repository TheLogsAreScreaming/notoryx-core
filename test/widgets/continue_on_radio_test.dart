import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meshcore_open/connector/meshcore_connector.dart';
import 'package:meshcore_open/connector/meshcore_protocol.dart';
import 'package:meshcore_open/connector/radio_manager.dart';
import 'package:meshcore_open/l10n/app_localizations.dart';
import 'package:meshcore_open/models/channel.dart';
import 'package:meshcore_open/models/contact.dart';
import 'package:meshcore_open/storage/prefs_manager.dart';
import 'package:meshcore_open/widgets/continue_on_radio.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Contact _contact(int seed, int hops) => Contact(
  publicKey: Uint8List.fromList(List.generate(32, (i) => i + seed)),
  name: 'Sam',
  type: advTypeChat,
  path: Uint8List(0),
  pathLength: hops,
  lastSeen: DateTime(2026, 11, 13),
);

final _sam = _contact(1, 2);
final _hikingKey = Uint8List.fromList(List.filled(16, 7));

/// A connected radio that knows a fixed set of contacts and channels.
class _Radio extends MeshCoreConnector {
  _Radio({super.slot, this.known = const [], this.channelList = const []});

  final List<Contact> known;
  final List<Channel> channelList;
  bool connected = true;

  @override
  bool get isConnected => connected;
  @override
  Contact? getContactByPubKeyHex(String hex) =>
      known.where((c) => c.publicKeyHex == hex).firstOrNull;
  @override
  List<Channel> get channels => channelList;
}

Widget _host(RadioManager radios, Widget button) =>
    ChangeNotifierProvider.value(
      value: radios,
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(appBar: AppBar(actions: [button])),
      ),
    );

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    PrefsManager.reset();
    await PrefsManager.initialize();
  });
  tearDown(PrefsManager.reset);

  RadioManager twoRadios(_Radio second) =>
      RadioManager(_Radio(), create: (_) => second)..add();

  group('lookups', () {
    test('finds other connected radios that know a contact', () {
      final hill = _Radio(slot: 'r2', known: [_contact(1, 0)]);
      final radios = twoRadios(hill);
      expect(radios.otherRadiosForContact(_sam.publicKeyHex), [
        (radio: hill, hops: 0),
      ]);
      hill.connected = false;
      expect(radios.otherRadiosForContact(_sam.publicKeyHex), isEmpty);
    });

    test('never offers the radio in use', () {
      final hill = _Radio(slot: 'r2', known: [_sam]);
      final radios = twoRadios(hill)..setActive(hill);
      expect(radios.otherRadiosForContact(_sam.publicKeyHex), isEmpty);
    });

    test('matches channels by key, not by slot', () {
      final hill = _Radio(
        slot: 'r2',
        channelList: [
          Channel(index: 0, name: 'Public', psk: Uint8List(16)),
          Channel(index: 4, name: '#hiking', psk: _hikingKey),
        ],
      );
      final radios = twoRadios(hill);
      expect(radios.otherRadiosForChannel(_hikingKey), [
        (radio: hill, index: 4),
      ]);
      expect(
        radios.otherRadiosForChannel(Uint8List.fromList(List.filled(16, 9))),
        isEmpty,
      );
    });
  });

  group('button', () {
    testWidgets('hidden with one radio', (tester) async {
      final radios = RadioManager(_Radio(known: [_sam]));
      await tester.pumpWidget(
        _host(radios, ContinueOnRadioButton.contact(_sam.publicKeyHex)),
      );
      expect(find.byKey(const ValueKey('continue-on-radio')), findsNothing);
    });

    testWidgets('hidden when no other radio knows the contact', (tester) async {
      final radios = twoRadios(_Radio(slot: 'r2'));
      await tester.pumpWidget(
        _host(radios, ContinueOnRadioButton.contact(_sam.publicKeyHex)),
      );
      expect(find.byKey(const ValueKey('continue-on-radio')), findsNothing);
    });

    testWidgets('shows the route and switches to the chosen radio', (
      tester,
    ) async {
      final hill = _Radio(slot: 'r2', known: [_sam]);
      final radios = twoRadios(hill);
      await tester.pumpWidget(
        _host(radios, ContinueOnRadioButton.contact(_sam.publicKeyHex)),
      );
      await tester.tap(find.byKey(const ValueKey('continue-on-radio')));
      await tester.pumpAndSettle();
      expect(find.textContaining('Continue on '), findsOneWidget);
      expect(find.text('Hops: 2'), findsOneWidget);
      await tester.tap(find.textContaining('Continue on '));
      await tester.pumpAndSettle();
      expect(radios.active, hill);
      expect(radios.takeHandOff(), (
        payload: 'message:r2/${_sam.publicKeyHex}',
        reply: null,
      ));
    });

    testWidgets('a channel opens at its slot on the other radio', (
      tester,
    ) async {
      final hill = _Radio(
        slot: 'r2',
        channelList: [Channel(index: 4, name: '#hiking', psk: _hikingKey)],
      );
      final radios = twoRadios(hill);
      await tester.pumpWidget(
        _host(radios, ContinueOnRadioButton.channel(_hikingKey)),
      );
      await tester.tap(find.byKey(const ValueKey('continue-on-radio')));
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('Continue on '));
      await tester.pumpAndSettle();
      expect(radios.takeHandOff()?.payload, 'channel:r2/4');
    });
  });
}
