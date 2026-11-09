import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../l10n/l10n.dart';
import '../services/encrypted_backup_service.dart';
import '../widgets/ember_backdrop.dart';

class EncryptedBackupScreen extends StatefulWidget {
  const EncryptedBackupScreen({super.key});
  @override
  State<EncryptedBackupScreen> createState() => _EncryptedBackupScreenState();
}

class _EncryptedBackupScreenState extends State<EncryptedBackupScreen> {
  final _passphrase = TextEditingController();
  final _confirmation = TextEditingController();
  final _restorePassphrase = TextEditingController();
  bool _busy = false;
  String? _status;

  @override
  void dispose() {
    _passphrase.dispose();
    _confirmation.dispose();
    _restorePassphrase.dispose();
    super.dispose();
  }

  Future<void> _export() async {
    if (_passphrase.text.length < 12 ||
        _passphrase.text != _confirmation.text) {
      setState(() => _status = context.l10n.bk_mismatch);
      return;
    }
    setState(() {
      _busy = true;
      _status = null;
    });
    File? file;
    try {
      final service = EncryptedBackupService();
      final encrypted = await service.seal(
        service.snapshot(includeChats: false),
        _passphrase.text,
      );
      final directory = await getTemporaryDirectory();
      file = File(
        '${directory.path}/bastion-backup-${DateTime.now().millisecondsSinceEpoch}.json',
      );
      await file.writeAsString(encrypted, flush: true);
      if (!mounted) return;
      final box = context.findRenderObject() as RenderBox?;
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          sharePositionOrigin: box == null
              ? null
              : box.localToGlobal(Offset.zero) & box.size,
        ),
      );
      _passphrase.clear();
      _confirmation.clear();
      if (mounted) {
        setState(() => _status = context.l10n.bk_done);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _status = context.l10n.bk_failed);
      }
    } finally {
      if (file != null && await file.exists()) await file.delete();
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _restore() async {
    final XFile? file;
    try {
      file = await openFile();
    } catch (_) {
      setState(() => _status = context.l10n.bk_cantOpen);
      return;
    }
    if (file == null || !mounted) return;
    setState(() {
      _busy = true;
      _status = null;
    });
    try {
      final service = EncryptedBackupService();
      final Map<String, Object> values;
      try {
        values = await service.open(
          await file.readAsString(),
          _restorePassphrase.text,
        );
      } catch (_) {
        if (mounted) {
          setState(() => _status = context.l10n.bk_wrongPass);
        }
        return;
      }
      if (!mounted) return;
      final count = values.keys
          .where(EncryptedBackupService.isRestorable)
          .length;
      final go = await showDialog<bool>(
        context: context,
        builder: (dialog) => AlertDialog(
          title: Text(context.l10n.bk_confirmTitle),
          content: Text(context.l10n.bk_confirmBody(count)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialog, false),
              child: Text(context.l10n.common_cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialog, true),
              child: Text(context.l10n.bk_restore),
            ),
          ],
        ),
      );
      if (go != true) return;
      final restored = await service.restore(values);
      _restorePassphrase.clear();
      if (mounted) {
        setState(() => _status = context.l10n.bk_restored(restored));
      }
    } catch (_) {
      if (mounted) {
        setState(() => _status = context.l10n.bk_partial);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => EmberBackdrop(
    scene: EmberScene.more,
    child: Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        title: Text(context.l10n.bk_title),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(context.l10n.bk_intro),
          const SizedBox(height: 16),
          Text(context.l10n.bk_keep),
          const SizedBox(height: 16),
          TextField(
            controller: _passphrase,
            obscureText: true,
            enabled: !_busy,
            autocorrect: false,
            enableSuggestions: false,
            decoration: InputDecoration(labelText: context.l10n.bk_pass),
          ),
          TextField(
            controller: _confirmation,
            obscureText: true,
            enabled: !_busy,
            autocorrect: false,
            enableSuggestions: false,
            decoration: InputDecoration(labelText: context.l10n.bk_confirm),
          ),
          FilledButton(
            onPressed: _busy ? null : _export,
            child: Text(_busy ? context.l10n.bk_working : context.l10n.bk_save),
          ),
          const Divider(height: 40),
          Text(
            context.l10n.bk_restoreTitle,
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          TextField(
            key: const ValueKey('restore-passphrase'),
            controller: _restorePassphrase,
            obscureText: true,
            enabled: !_busy,
            autocorrect: false,
            enableSuggestions: false,
            decoration: InputDecoration(labelText: context.l10n.bk_restorePass),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            key: const ValueKey('restore-backup'),
            onPressed: _busy ? null : _restore,
            child: Text(context.l10n.bk_choose),
          ),
          if (_status != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(_status!),
            ),
        ],
      ),
    ),
  );
}
