import 'package:flutter/material.dart';
import '../connector/meshcore_connector.dart';

/// Whether a screen that needs a radio should close: only once the radio is
/// gone for good (disconnected by hand or never connected). While Core is
/// getting a dropped link back by itself, chats stay open so messages typed
/// meanwhile go to the offline outbox and are sent on reconnect.
bool shouldLeaveForDisconnect({
  required bool connected,
  required bool recoveringLink,
}) => !connected && !recoveringLink;

/// Mixin that navigates back to the first screen once the radio is gone.
/// Use in State classes for screens that require a radio.
mixin DisconnectNavigationMixin<T extends StatefulWidget> on State<T> {
  /// Call this in your Widget build method to enable auto-navigation.
  /// Returns true if the screen may stay, false if navigation was triggered.
  bool checkConnectionAndNavigate(MeshCoreConnector connector) {
    if (shouldLeaveForDisconnect(
      connected: connector.isConnected,
      recoveringLink: connector.isRecoveringLink,
    )) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.popUntil(context, (route) => route.isFirst);
        }
      });
      return false;
    }
    return true;
  }
}
