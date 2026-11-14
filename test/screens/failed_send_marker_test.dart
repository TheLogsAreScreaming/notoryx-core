// A failed message shows in the chat list, and its fixes send it once.
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    show FlutterLocalNotificationsPlatform;
import 'package:flutter_test/flutter_test.dart';
import 'package:meshcore_open/connector/meshcore_connector.dart';
import 'package:meshcore_open/connector/meshcore_protocol.dart';
import 'package:meshcore_open/l10n/app_localizations.dart';
import 'package:meshcore_open/models/contact.dart';
import 'package:meshcore_open/models/message.dart';
import 'package:meshcore_open/screens/contacts_screen.dart';
import 'package:meshcore_open/services/app_settings_service.dart';
import 'package:meshcore_open/services/ui_view_state_service.dart';
import 'package:meshcore_open/storage/prefs_manager.dart';
import 'package:meshcore_open/theme/mesh_theme.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Notifications extends FlutterLocalNotificationsPlatform {
  @override
  Future<void> cancel({required int id}) async {}
}

class _Radio extends MeshCoreConnector {
  final known = <Contact>[];
  final resent = <({Contact to, Message message})>[];

  @override
  bool get isConnected => true;
  @override
  bool get isLoadingContacts => false;
  @override
  bool get hasLoadedContacts => true;
  @override
  List<Contact> get contacts => known;
  @override
  Contact? getContactByPubKeyHex(String contactPubKeyHex) =>
      known.where((c) => c.publicKeyHex == contactPubKeyHex).firstOrNull;
  @override
  Future<bool> resendMessage(Contact contact, Message message) async {
    resent.add((to: contact, message: message));
    return true;
  }
}

final sam = Contact(
  publicKey: Uint8List.fromList(List.filled(32, 7)),
  name: 'Sam',
  type: advTypeChat,
  pathLength: 2,
  path: Uint8List.fromList([0xA1, 0x3F]),
  lastSeen: DateTime.now().subtract(const Duration(minutes: 3)),
);

Message _sent(MessageStatus status, {String text = 'At camp', int at = 0}) =>
    Message(
      senderKey: sam.publicKey,
      text: text,
      timestamp: DateTime(2026, 11, 14, 9, at),
      isOutgoing: true,
      status: status,
      retryCount: status == MessageStatus.failed ? 6 : 0,
      sentAt: DateTime(2026, 11, 14, 9, at, 2),
      pathLength: 2,
      pathBytes: Uint8List.fromList([0xA1, 0x3F]),
    );

void main() {
  late _Radio radio;
  late UiViewStateService viewState;
  late AppSettingsService settings;

  setUp(() async {
    FlutterLocalNotificationsPlatform.instance = _Notifications();
    SharedPreferences.setMockInitialValues({});
    PrefsManager.reset();
    await PrefsManager.initialize();
    radio = _Radio()..known.add(sam);
    viewState = UiViewStateService();
    settings = AppSettingsService();
  });

  tearDown(() {
    radio.dispose();
    viewState.dispose();
    settings.dispose();
    PrefsManager.reset();
  });

  group('last failed message', () {
    test('is the last one sent, when it failed', () {
      radio.debugAddMessage(_sent(MessageStatus.delivered));
      radio.debugAddMessage(_sent(MessageStatus.failed, text: 'Late', at: 1));
      expect(radio.lastFailedMessage(sam)?.text, 'Late');
    });

    test('a later send that got through or is going clears it', () {
      radio.debugAddMessage(_sent(MessageStatus.failed));
      radio.debugAddMessage(_sent(MessageStatus.pending, at: 1));
      expect(radio.lastFailedMessage(sam), isNull);
    });

    test('a reply received after it does not hide it', () {
      radio.debugAddMessage(_sent(MessageStatus.failed));
      radio.debugAddMessage(
        Message(
          senderKey: sam.publicKey,
          text: 'Hi',
          timestamp: DateTime(2026, 11, 14, 9, 5),
          isOutgoing: false,
          status: MessageStatus.delivered,
        ),
      );
      expect(radio.lastFailedMessage(sam), isNotNull);
    });

    test('nothing sent, nothing failed', () {
      expect(radio.lastFailedMessage(sam), isNull);
    });
  });

  Future<void> pumpList(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(420, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<MeshCoreConnector>.value(value: radio),
          ChangeNotifierProvider<UiViewStateService>.value(value: viewState),
          ChangeNotifierProvider<AppSettingsService>.value(value: settings),
        ],
        child: MaterialApp(
          theme: MeshTheme.dark(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ContactsScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    // Let each row's fade-in finish; until then it isn't read out.
    await tester.pump(const Duration(milliseconds: 400));
  }

  final marker = find.byKey(ValueKey('failed-send-${sam.publicKeyHex}'));

  testWidgets('no marker while nothing has failed', (tester) async {
    radio.debugAddMessage(_sent(MessageStatus.delivered));
    await pumpList(tester);
    expect(find.text('Sam'), findsOneWidget);
    expect(marker, findsNothing);
  });

  testWidgets('a failed send is marked and says so to screen readers', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    radio.debugAddMessage(_sent(MessageStatus.failed));
    await pumpList(tester);
    expect(marker, findsOneWidget);
    expect(find.text('Not delivered'), findsOneWidget);
    const spoken =
        "Your last message to Sam wasn't delivered. "
        'Shows why and how to fix it.';
    expect(find.bySemanticsLabel(spoken), findsOneWidget);
    expect(
      tester.getSemantics(find.bySemanticsLabel(spoken)),
      matchesSemantics(label: spoken, isButton: true, hasTapAction: true),
    );
    expect(tester.getSize(marker).height, greaterThanOrEqualTo(44));
    semantics.dispose();
  });

  testWidgets('retry by flood sends once, without changing the route', (
    tester,
  ) async {
    final failed = _sent(MessageStatus.failed);
    radio.debugAddMessage(failed);
    await pumpList(tester);
    await tester.tap(marker);
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('delivery-sheet')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('delivery-retry-flood')));
    await tester.pumpAndSettle();

    expect(radio.resent, hasLength(1));
    expect(radio.resent.single.message, same(failed));
    expect(radio.resent.single.to.pathOverride, -1);
    expect(radio.known.single.pathOverride, isNull);
    expect(find.text('Retrying message'), findsOneWidget);
  });

  testWidgets('plain retry sends once by the usual route', (tester) async {
    radio.debugAddMessage(_sent(MessageStatus.failed));
    await pumpList(tester);
    await tester.tap(marker);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('delivery-retry')));
    await tester.pumpAndSettle();

    expect(radio.resent, hasLength(1));
    expect(radio.resent.single.to.pathOverride, isNull);
  });
}
