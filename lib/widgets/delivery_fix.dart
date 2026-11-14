import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../connector/meshcore_connector.dart';
import '../helpers/snack_bar_builder.dart';
import '../l10n/l10n.dart';
import '../models/contact.dart';
import '../models/message.dart';
import '../screens/route_picker_screen.dart';
import 'delivery_sheet.dart';

/// Shows [message]'s delivery details with each fix wired to the radio:
/// send again, send again by flood, or choose a route and send again.
Future<void> showDeliveryFixSheet(
  BuildContext context, {
  required Message message,
  required Contact contact,
}) {
  final connector = context.read<MeshCoreConnector>();
  Contact live() =>
      connector.getContactByPubKeyHex(contact.publicKeyHex) ?? contact;

  Future<void> resend(Contact to) async {
    final l10n = context.l10n;
    final sent = await connector.resendMessage(to, message);
    if (!context.mounted) return;
    showDismissibleSnackBar(
      context,
      content: Text(
        sent ? l10n.chat_retryingMessage : l10n.chat_resendNeedsRadio,
      ),
    );
  }

  Future<void> pickRouteThenResend() async {
    final before = live();
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RoutePickerScreen(contact: before),
      ),
    );
    if (!context.mounted) return;
    final after = live();
    // Backing out without a change sends nothing.
    if (sameRoute(before, after)) return;
    await resend(after);
  }

  return showDeliverySheet(
    context,
    message: message,
    contact: live(),
    onRetry: () => unawaited(resend(live())),
    // A one-off copy, so the route the user chose stays as it is.
    onRetryByFlood: () => unawaited(resend(live().copyWith(pathOverride: -1))),
    onPickRoute: () => unawaited(pickRouteThenResend()),
  );
}

/// Whether [a] and [b] would send by the same route.
@visibleForTesting
bool sameRoute(Contact a, Contact b) =>
    a.pathOverride == b.pathOverride &&
    listEquals(a.pathOverrideBytes, b.pathOverrideBytes) &&
    a.pathLength == b.pathLength &&
    listEquals(a.path, b.path);
