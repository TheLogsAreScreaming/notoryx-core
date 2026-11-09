import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../connector/meshcore_connector.dart';
import '../connector/meshcore_protocol.dart';
import '../l10n/l10n.dart';
import '../models/field_report.dart';
import '../services/field_ops_service.dart';
import 'mesh_ui.dart';

/// Opens the SALUTE / 9-Line form. It goes to the SOS recipients.
Future<void> showFieldReportSheet(BuildContext context) =>
    showMeshSheet<void>(context, builder: (_) => const _FieldReportSheet());

class _FieldReportSheet extends StatefulWidget {
  const _FieldReportSheet();

  @override
  State<_FieldReportSheet> createState() => _FieldReportSheetState();
}

class _FieldReportSheetState extends State<_FieldReportSheet> {
  var _kind = FieldReportKind.salute;
  final _controllers = <String, TextEditingController>{};
  var _sending = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controllers.isEmpty) _resetFields();
  }

  void _resetFields() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    _controllers.clear();
    final radio = context.read<MeshCoreConnector>();
    for (final field in _kind.fields) {
      _controllers[field.code] = TextEditingController();
    }
    final lat = radio.selfLatitude;
    final lon = radio.selfLongitude;
    if (lat != null && lon != null) {
      _controllers[_kind.locationCode]!.text =
          '${lat.toStringAsFixed(5)},${lon.toStringAsFixed(5)}';
    }
    final timeCode = _kind.timeCode;
    if (timeCode != null) {
      final now = DateTime.now().toUtc();
      String two(int n) => n.toString().padLeft(2, '0');
      _controllers[timeCode]!.text = '${two(now.hour)}${two(now.minute)}Z';
    }
  }

  List<String> _encoded(MeshCoreConnector radio) => encodeFieldReport(
    _kind,
    {for (final e in _controllers.entries) e.key: e.value.text},
    // The tighter of the two limits, since it can go to both.
    maxChannelMessageBytes(radio.selfName),
  );

  Future<void> _send() async {
    final radio = context.read<MeshCoreConnector>();
    final ops = context.read<FieldOpsService>();
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    setState(() => _sending = true);
    try {
      await ops.sendFieldReport(_encoded(radio));
      navigator.pop();
      messenger.showSnackBar(SnackBar(content: Text(l10n.report_sent)));
    } catch (e) {
      if (!mounted) return;
      setState(() => _sending = false);
      messenger.showSnackBar(SnackBar(content: Text(l10n.sos_notSent('$e'))));
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final radio = context.watch<MeshCoreConnector>();
    final parts = _encoded(radio);
    final canSend = !_sending && radio.isConnected && parts.isNotEmpty;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.report_title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            SegmentedButton<FieldReportKind>(
              segments: [
                ButtonSegment(
                  value: FieldReportKind.salute,
                  label: Text(l10n.report_salute),
                ),
                ButtonSegment(
                  value: FieldReportKind.nineLine,
                  label: Text(l10n.report_nineLine),
                ),
              ],
              selected: {_kind},
              onSelectionChanged: (s) => setState(() {
                _kind = s.first;
                _resetFields();
              }),
            ),
            const SizedBox(height: 12),
            for (final field in _kind.fields)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: TextField(
                  key: ValueKey('report-${_kind.name}-${field.code}'),
                  controller: _controllers[field.code],
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    labelText: field.label,
                    hintText: field.hint,
                  ),
                ),
              ),
            if (parts.length > 1) Text(l10n.report_parts(parts.length)),
            const SizedBox(height: 8),
            FilledButton(
              key: const ValueKey('report-send'),
              onPressed: canSend ? _send : null,
              child: Text(l10n.report_send),
            ),
          ],
        ),
      ),
    );
  }
}
