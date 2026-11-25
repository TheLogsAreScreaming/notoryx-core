import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../connector/meshcore_connector.dart';
import '../connector/meshcore_protocol.dart';
import '../l10n/l10n.dart';
import '../models/contact.dart';
import '../utils/app_logger.dart';

/// Sends one login to [repeater] and waits for its answer: true when it
/// accepted, false when it refused, null when nothing came back in [timeout].
Future<bool?> sendRepeaterLogin(
  MeshCoreConnector connector,
  Contact repeater,
  String password, {
  Duration timeout = const Duration(seconds: 20),
}) async {
  final prefix = repeater.publicKey.sublist(0, 6);
  final answer = Completer<bool?>();
  final sub = connector.receivedFrames.listen((frame) {
    if (frame.length < 8) return;
    final code = frame[0];
    if (code != pushCodeLoginSuccess && code != pushCodeLoginFail) return;
    if (!listEquals(frame.sublist(2, 8), prefix)) return;
    if (!answer.isCompleted) answer.complete(code == pushCodeLoginSuccess);
  });
  try {
    await connector.sendFrame(
      buildSendLoginFrame(repeater.publicKey, password),
    );
    return await answer.future.timeout(timeout, onTimeout: () => null);
  } finally {
    await sub.cancel();
  }
}

/// Wraps a repeater's admin screens. When the radio drops and comes back
/// while they're open, it logs in to the repeater once more with the same
/// password, so later commands don't fail for a lost login, and says how it
/// went. It never retries on its own beyond that one attempt.
class RepeaterReloginGuard extends StatefulWidget {
  const RepeaterReloginGuard({
    super.key,
    required this.connector,
    required this.repeater,
    required this.password,
    required this.child,
    this.settle = const Duration(seconds: 3),
    this.login = sendRepeaterLogin,
  });

  final MeshCoreConnector connector;
  final Contact repeater;
  final String password;
  final Widget child;

  /// Wait after reconnecting, so the radio finishes its own sync first.
  final Duration settle;

  @visibleForTesting
  final Future<bool?> Function(MeshCoreConnector, Contact, String) login;

  @override
  State<RepeaterReloginGuard> createState() => _RepeaterReloginGuardState();
}

class _RepeaterReloginGuardState extends State<RepeaterReloginGuard> {
  late bool _wasConnected = widget.connector.isConnected;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    widget.connector.addListener(_onConnector);
  }

  @override
  void dispose() {
    widget.connector.removeListener(_onConnector);
    super.dispose();
  }

  void _onConnector() {
    final now = widget.connector.isConnected;
    final cameBack = now && !_wasConnected;
    _wasConnected = now;
    if (cameBack && !_busy && widget.password.isNotEmpty) {
      unawaited(_relogin());
    }
  }

  Future<void> _relogin() async {
    _busy = true;
    final messenger = ScaffoldMessenger.maybeOf(context);
    final l10n = context.l10n;
    try {
      await Future<void>.delayed(widget.settle);
      if (!mounted || !widget.connector.isConnected) return;
      bool? ok;
      try {
        ok = await widget.login(
          widget.connector,
          widget.repeater,
          widget.password,
        );
      } catch (e) {
        appLogger.warn('Re-login not sent: $e', tag: 'RepeaterLogin');
      }
      appLogger.info('Re-login after reconnect: $ok', tag: 'RepeaterLogin');
      if (!mounted) return;
      messenger?.showSnackBar(
        SnackBar(
          key: const ValueKey('repeater-relogin'),
          content: Text(
            ok == true
                ? l10n.relogin_done(widget.repeater.name)
                : l10n.relogin_failed(widget.repeater.name),
          ),
        ),
      );
    } finally {
      _busy = false;
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
