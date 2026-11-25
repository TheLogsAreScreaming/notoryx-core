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

class _Radio extends MeshCoreConnector {
  _Radio(this.region);
  final String region;
  @override
  bool get isConnected => true;
  @override
  String? get selfName => 'Me';
  @override
  List<ChannelMessage> getChannelMessages(Channel channel) => const [];
  @override
  String getChannelRegion(int channelIndex) => region;
  @override
  bool hasChannelRegion(int channelIndex) => region.isNotEmpty;
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

  testWidgets('a channel without a region says it reaches the whole mesh', (
    tester,
  ) async {
    await tester.pumpWidget(_app(_Radio('')));
    await _settle(tester);
    expect(find.textContaining('Whole mesh'), findsOneWidget);
  });

  testWidgets('a channel with a region names it', (tester) async {
    await tester.pumpWidget(_app(_Radio('pnw')));
    await _settle(tester);
    expect(find.textContaining('Region: pnw'), findsOneWidget);
    expect(find.textContaining('Whole mesh'), findsNothing);
  });
}
