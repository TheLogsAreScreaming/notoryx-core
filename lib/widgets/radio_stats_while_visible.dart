import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../connector/meshcore_connector.dart';

/// Keeps the radio's live stats (noise floor, last RSSI and SNR, airtime)
/// coming in while [child] is on screen.
///
/// Screens that only read `latestRadioStats` otherwise show "No data" until
/// the Live radio stats screen has been opened, because nothing asks the
/// radio for them.
class RadioStatsWhileVisible extends StatefulWidget {
  const RadioStatsWhileVisible({super.key, required this.child});

  final Widget child;

  @override
  State<RadioStatsWhileVisible> createState() => _RadioStatsWhileVisibleState();
}

class _RadioStatsWhileVisibleState extends State<RadioStatsWhileVisible> {
  MeshCoreConnector? _connector;

  @override
  void initState() {
    super.initState();
    _connector = context.read<MeshCoreConnector>()..acquireRadioStatsPolling();
  }

  @override
  void dispose() {
    _connector?.releaseRadioStatsPolling();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
