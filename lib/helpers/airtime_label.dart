import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../connector/meshcore_connector.dart';
import '../l10n/l10n.dart';
import '../utils/lora_airtime.dart';

/// Short "≈0.4 s on air" text for a message of [textBytes] on the
/// connected radio, or null when its LoRa settings aren't known.
String? airtimeEstimateLabel(
  BuildContext context,
  MeshCoreConnector connector,
  int textBytes,
) {
  final airtime = estimateTextMessageAirtime(
    textBytes: textBytes,
    spreadingFactor: connector.currentSf,
    bandwidthHz: connector.currentBwHz,
    codingRate: connector.currentCr,
  );
  if (airtime == null) return null;
  final seconds = airtime.inMicroseconds / Duration.microsecondsPerSecond;
  final locale = Localizations.localeOf(context).toLanguageTag();
  final text = NumberFormat('0.0', locale).format(seconds);
  return context.l10n.chat_airtimeEstimate(text);
}
