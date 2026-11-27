import 'package:flutter/material.dart';

import '../l10n/l10n.dart';

/// Quiet "via MQTT" or "via CoreScope" marker for a channel message the
/// radio never heard.
///
/// [color] should be a muted text color already checked for contrast against
/// the bubble it sits on.
class ViaMqttLabel extends StatelessWidget {
  final Color color;
  final double textScale;

  /// Whether the message came from a CoreScope analyzer, not MQTT.
  final bool coreScope;

  const ViaMqttLabel({
    super.key,
    required this.color,
    this.textScale = 1.0,
    this.coreScope = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Semantics(
      label: coreScope
          ? l10n.channels_viaCoreScopeSemantics
          : l10n.channels_viaMqttSemantics,
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            coreScope ? Icons.travel_explore : Icons.cloud_outlined,
            size: 11 * textScale,
            color: color,
          ),
          const SizedBox(width: 2),
          Text(
            coreScope ? l10n.channels_viaCoreScope : l10n.channels_viaMqtt,
            style: TextStyle(fontSize: 10.5 * textScale, color: color),
          ),
        ],
      ),
    );
  }
}
