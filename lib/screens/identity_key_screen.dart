import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../connector/meshcore_connector.dart';
import '../connector/meshcore_protocol.dart';
import '../l10n/app_localizations.dart';
import '../l10n/l10n.dart';
import '../theme/mesh_theme.dart';
import '../widgets/ember_backdrop.dart';
import '../widgets/instrument.dart';

/// Back up the connected radio's identity private key, or give the radio
/// an identity from a backup.
class IdentityKeyScreen extends StatefulWidget {
  const IdentityKeyScreen({super.key, this.exportKey, this.importKey});

  /// For tests; the connector's otherwise.
  final Future<Uint8List> Function()? exportKey;
  final Future<void> Function(Uint8List key)? importKey;

  @override
  State<IdentityKeyScreen> createState() => _IdentityKeyScreenState();
}

class _IdentityKeyScreenState extends State<IdentityKeyScreen> {
  final _input = TextEditingController();
  String? _shown;
  bool _busy = false;

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  String _failure(AppLocalizations l10n, Object error) {
    final failure = error is IdentityKeyException
        ? error.failure
        : IdentityKeyFailure.rejected;
    return switch (failure) {
      IdentityKeyFailure.notConnected => l10n.idKey_errNotConnected,
      IdentityKeyFailure.timeout => l10n.idKey_errTimeout,
      IdentityKeyFailure.disabled => l10n.idKey_errDisabled,
      IdentityKeyFailure.rejected => l10n.idKey_errRejected,
    };
  }

  void _say(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  Future<bool> _confirm(String title, String body, String action) async {
    final l10n = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.common_cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(action),
          ),
        ],
      ),
    );
    return ok ?? false;
  }

  Future<void> _show() async {
    final l10n = context.l10n;
    final connector = context.read<MeshCoreConnector>();
    final export = widget.exportKey ?? connector.exportIdentityKey;
    if (!await _confirm(
      l10n.idKey_showConfirmTitle,
      l10n.idKey_showConfirmBody,
      l10n.idKey_show,
    )) {
      return;
    }
    if (!mounted) return;
    setState(() => _busy = true);
    try {
      final key = await export();
      if (!mounted) return;
      setState(() => _shown = _hex(key));
    } catch (e) {
      if (mounted) _say(_failure(l10n, e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _copy() async {
    final shown = _shown;
    if (shown == null) return;
    final l10n = context.l10n;
    await Clipboard.setData(ClipboardData(text: shown));
    if (mounted) _say(l10n.idKey_copied);
  }

  Future<void> _restore() async {
    final key = parseIdentityKeyHex(_input.text);
    if (key == null) return;
    final l10n = context.l10n;
    final connector = context.read<MeshCoreConnector>();
    final import = widget.importKey ?? connector.importIdentityKey;
    if (!await _confirm(
      l10n.idKey_importConfirmTitle,
      l10n.idKey_importConfirmBody,
      l10n.idKey_importButton,
    )) {
      return;
    }
    if (!mounted) return;
    setState(() => _busy = true);
    try {
      await import(key);
      if (!mounted) return;
      _input.clear();
      setState(() => _shown = null);
      _say(l10n.idKey_importDone);
    } catch (e) {
      if (mounted) _say(_failure(l10n, e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  static String _hex(Uint8List bytes) =>
      bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final online = context.watch<MeshCoreConnector>().isConnected;
    final shown = _shown;
    final typed = _input.text.trim();
    final valid = parseIdentityKeyHex(typed) != null;
    final small = TextStyle(color: MeshPalette.ink3, fontSize: 12.5);
    return EmberBackdrop(
      scene: EmberScene.more,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          scrolledUnderElevation: 0,
          title: Text(l10n.idKey_title),
        ),
        body: ListView(
          padding: const EdgeInsets.only(bottom: MeshSpace.lg),
          children: [
            Padding(
              padding: const EdgeInsets.all(MeshSpace.lg),
              child: Text(l10n.idKey_explainer, style: small),
            ),
            if (!online)
              InstrumentRow(
                title: l10n.idKey_errNotConnected,
                titleColor: MeshPalette.ink3,
              ),
            InstrumentLabel(l10n.idKey_backupLabel),
            if (shown == null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: MeshSpace.lg),
                child: InstrumentButton(
                  key: const ValueKey('id-key-show'),
                  label: l10n.idKey_showKey,
                  icon: Icons.key_rounded,
                  onPressed: online && !_busy ? _show : null,
                ),
              )
            else ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: MeshSpace.lg),
                child: SelectableText(
                  shown,
                  key: const ValueKey('id-key-hex'),
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(MeshSpace.lg),
                child: InstrumentButton(
                  key: const ValueKey('id-key-copy'),
                  label: l10n.idKey_copy,
                  icon: Icons.copy_rounded,
                  onPressed: _copy,
                ),
              ),
            ],
            const SizedBox(height: MeshSpace.lg),
            InstrumentLabel(l10n.idKey_importLabel),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: MeshSpace.lg),
              child: TextField(
                key: const ValueKey('id-key-input'),
                controller: _input,
                minLines: 2,
                maxLines: 4,
                autocorrect: false,
                enableSuggestions: false,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                decoration: InputDecoration(
                  hintText: l10n.idKey_importHint,
                  errorText: typed.isEmpty || valid
                      ? null
                      : l10n.idKey_importInvalid,
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(MeshSpace.lg),
              child: InstrumentButton(
                key: const ValueKey('id-key-import'),
                label: l10n.idKey_importButton,
                icon: Icons.restore_rounded,
                danger: true,
                onPressed: online && valid && !_busy ? _restore : null,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: MeshSpace.lg),
              child: Text(l10n.idKey_warning, style: small),
            ),
          ],
        ),
      ),
    );
  }
}
