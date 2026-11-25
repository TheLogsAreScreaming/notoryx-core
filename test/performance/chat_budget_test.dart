import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meshcore_open/connector/meshcore_connector.dart';
import 'package:meshcore_open/l10n/app_localizations.dart';
import 'package:meshcore_open/models/channel.dart';
import 'package:meshcore_open/models/channel_message.dart';
import 'package:meshcore_open/screens/channel_chat_screen.dart';
import 'package:meshcore_open/services/app_settings_service.dart';
import 'package:meshcore_open/services/chat_text_scale_service.dart';
import 'package:meshcore_open/services/image_codec_service.dart';
import 'package:meshcore_open/services/received_image_store.dart';
import 'package:meshcore_open/services/translation_service.dart';
import 'package:meshcore_open/storage/prefs_manager.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A radio whose channel holds [count] messages.
class _BusyRadio extends MeshCoreConnector {
  _BusyRadio(int count)
    : messages = List.generate(
        count,
        (i) => ChannelMessage(
          senderName: 'Node ${i % 40}',
          text: 'Message number $i on a busy channel',
          timestamp: DateTime(2026, 11, 1).add(Duration(minutes: i)),
          isOutgoing: i % 9 == 0,
          messageId: 'm$i',
        ),
      );

  final List<ChannelMessage> messages;
  @override
  bool get isConnected => true;
  @override
  String? get selfName => 'Me';
  @override
  List<ChannelMessage> getChannelMessages(Channel channel) => messages;
}

final _channel = Channel(index: 0, name: 'Public', psk: Uint8List(16));

Widget _app(MeshCoreConnector connector) {
  final settings = AppSettingsService();
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<MeshCoreConnector>.value(value: connector),
      ChangeNotifierProvider.value(value: settings),
      ChangeNotifierProvider(create: (_) => ChatTextScaleService()),
      ChangeNotifierProvider(create: (_) => TranslationService(settings)),
      ChangeNotifierProvider(create: (_) => ImageCodecService(settings)),
      ChangeNotifierProvider(create: (_) => ReceivedImageStore()),
    ],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: ChannelChatScreen(channel: _channel),
    ),
  );
}

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    PrefsManager.reset();
    await PrefsManager.initialize();
    final tmp = Directory.systemTemp.createTempSync('chat').path;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (call) async => tmp,
        );
  });

  // Performance budget: a channel with 5,000 messages opens without
  // building them all, and well inside a generous time limit, so a change
  // that makes the chat build every message fails here first.
  testWidgets('5,000 messages: only what fits is built, and it opens fast', (
    tester,
  ) async {
    final watch = Stopwatch()..start();
    await tester.pumpWidget(_app(_BusyRadio(5000)));
    await _settle(tester);
    watch.stop();
    final built = find.textContaining('on a busy channel').evaluate().length;
    expect(built, greaterThan(0));
    expect(built, lessThan(100), reason: 'messages must be built lazily');
    expect(watch.elapsed, lessThan(const Duration(seconds: 10)));
  });
}
