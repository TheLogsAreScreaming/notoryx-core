import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Moves the app's task to the background on Android, like pressing Home.
///
/// Closing the activity instead (Android's default for Back on the first
/// screen) tears down the Flutter engine, and the Bluetooth plugin then
/// disconnects every radio. The background service keeps running but has no
/// link, so messages and SOS alerts stop until the app is opened again.
class AppTask {
  AppTask._();

  /// Channel handled by `MainActivity` on Android.
  static const channel = MethodChannel('notoryx/app_task');

  /// Sends the app to the background. Returns false where that isn't
  /// supported (not Android, or the call failed), so the caller can fall
  /// back to the normal Back behaviour.
  static Future<bool> moveToBack() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return false;
    }
    try {
      return await channel.invokeMethod<bool>('moveTaskToBack') ?? false;
    } on PlatformException catch (e) {
      debugPrint('moveTaskToBack failed: $e');
      return false;
    } on MissingPluginException {
      return false;
    }
  }
}

/// Wraps the app's first screen so that Back, while a radio is connected,
/// sends the app to the background instead of closing it and dropping the
/// radio link.
class BackKeepsRunning extends StatelessWidget {
  const BackKeepsRunning({
    super.key,
    required this.connected,
    required this.child,
    @visibleForTesting this.moveToBack = AppTask.moveToBack,
  });

  /// Whether a radio is connected. When not, Back behaves normally.
  final bool connected;

  final Widget child;

  /// Sends the app to the background; injectable for tests.
  final Future<bool> Function() moveToBack;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !connected,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        moveToBack();
      },
      child: child,
    );
  }
}
