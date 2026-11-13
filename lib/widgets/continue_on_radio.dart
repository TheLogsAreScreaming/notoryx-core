import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../connector/meshcore_connector.dart';
import '../connector/radio_manager.dart';
import '../l10n/l10n.dart';
import '../services/notification_service.dart';
import 'radio_list.dart';

/// In a chat, offers to continue it on another connected radio that can
/// also reach this contact or channel. Choosing one switches to that radio
/// and opens the same chat there, so each chat's history stays with the
/// radio that sent it. Hidden when no other radio can.
class ContinueOnRadioButton extends StatelessWidget {
  /// For the direct chat with [publicKeyHex].
  const ContinueOnRadioButton.contact(String this.publicKeyHex, {super.key})
    : psk = null;

  /// For the channel using [psk].
  const ContinueOnRadioButton.channel(Uint8List this.psk, {super.key})
    : publicKeyHex = null;

  final String? publicKeyHex;
  final Uint8List? psk;

  @override
  Widget build(BuildContext context) {
    final RadioManager radios;
    try {
      radios = context.watch<RadioManager>();
    } on ProviderNotFoundException {
      return const SizedBox.shrink();
    }
    if (!radios.hasMultiple) return const SizedBox.shrink();
    return ListenableBuilder(
      listenable: Listenable.merge(radios.radios),
      builder: (context, _) {
        final choices = _choices(context, radios);
        if (choices.isEmpty) return const SizedBox.shrink();
        return PopupMenuButton<int>(
          key: const ValueKey('continue-on-radio'),
          tooltip: context.l10n.radios_continueOn,
          icon: const Icon(Icons.alt_route_rounded),
          onSelected: (i) =>
              radios.switchFor(choices[i].radio, choices[i].payload),
          itemBuilder: (_) => [
            for (var i = 0; i < choices.length; i++)
              PopupMenuItem(
                value: i,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.settings_input_antenna_rounded),
                  title: Text(
                    context.l10n.radios_continueOnName(
                      radioLabel(context, radios, choices[i].radio),
                    ),
                  ),
                  subtitle: choices[i].route == null
                      ? null
                      : Text(choices[i].route!),
                ),
              ),
          ],
        );
      },
    );
  }

  List<({MeshCoreConnector radio, String payload, String? route})> _choices(
    BuildContext context,
    RadioManager radios,
  ) {
    final l10n = context.l10n;
    final key = publicKeyHex;
    if (key != null) {
      return [
        for (final (:radio, :hops) in radios.otherRadiosForContact(key))
          (
            radio: radio,
            payload: 'message:${NotificationService.tagged(radio.slot, key)}',
            route: hops < 0
                ? l10n.radios_routeFlood
                : hops == 0
                ? l10n.radios_routeDirect
                : l10n.radios_routeHops(hops),
          ),
      ];
    }
    final channelKey = psk;
    if (channelKey == null) return const [];
    final seen = <MeshCoreConnector>{};
    return [
      for (final (:radio, :index) in radios.otherRadiosForChannel(channelKey))
        if (seen.add(radio))
          (
            radio: radio,
            payload: 'channel:${NotificationService.tagged(radio.slot, index)}',
            route: null,
          ),
    ];
  }
}
