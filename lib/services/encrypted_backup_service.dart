import 'dart:convert';

import 'package:cryptography/cryptography.dart';

import '../storage/db/history_backup.dart';
import '../storage/db/message_db.dart';
import '../storage/prefs_manager.dart';
import '../storage/secure_prefs.dart';

/// Thrown when a backup would be bigger than [EncryptedBackupService.maxBytes].
class BackupTooLargeException implements Exception {
  const BackupTooLargeException();
}

/// A settings restore failed and every setting was put back as it was.
class RestoreRolledBackException implements Exception {
  const RestoreRolledBackException(this.cause);
  final Object cause;
  @override
  String toString() => 'Restore rolled back: $cause';
}

/// Portable authenticated backup. Never sends settings to a server or radio.
class EncryptedBackupService {
  static const _iterations = 310000;

  /// The largest backup file this app writes or reads.
  static const maxBytes = 96 * 1024 * 1024;
  final _cipher = AesGcm.with256bits();
  final _kdf = Pbkdf2(
    macAlgorithm: Hmac.sha256(),
    iterations: _iterations,
    bits: 256,
  );

  Future<String> seal(Map<String, Object> values, String passphrase) async {
    if (passphrase.length < 12) {
      throw const FormatException('Use at least 12 characters.');
    }
    _validate(values);
    final salt = SecretKeyData.random(length: 32).bytes;
    final key = await _kdf.deriveKey(
      secretKey: SecretKey(utf8.encode(passphrase)),
      nonce: salt,
    );
    final box = await _cipher.encrypt(
      utf8.encode(jsonEncode(values)),
      secretKey: key,
      aad: utf8.encode('bastion-meshcore-backup-v1'),
    );
    final sealed = jsonEncode({
      'format': 'bastion-meshcore-backup',
      'version': 1,
      'iterations': _iterations,
      'salt': base64Encode(salt),
      'nonce': base64Encode(box.nonce),
      'ciphertext': base64Encode(box.cipherText),
      'tag': base64Encode(box.mac.bytes),
    });
    if (sealed.length > maxBytes) throw const BackupTooLargeException();
    return sealed;
  }

  Future<Map<String, Object>> open(String text, String passphrase) async {
    if (text.length > maxBytes) {
      throw const FormatException('Backup is too large.');
    }
    final json = jsonDecode(text);
    if (json is! Map ||
        json['format'] != 'bastion-meshcore-backup' ||
        json['version'] != 1 ||
        json['iterations'] != _iterations) {
      throw const FormatException('Unsupported backup format.');
    }
    final salt = base64Decode(json['salt'] as String);
    final nonce = base64Decode(json['nonce'] as String);
    final tag = base64Decode(json['tag'] as String);
    if (salt.length != 32 || nonce.length != 12 || tag.length != 16) {
      throw const FormatException('Invalid backup header.');
    }
    final key = await _kdf.deriveKey(
      secretKey: SecretKey(utf8.encode(passphrase)),
      nonce: salt,
    );
    final bytes = await _cipher.decrypt(
      SecretBox(
        base64Decode(json['ciphertext'] as String),
        nonce: nonce,
        mac: Mac(tag),
      ),
      secretKey: key,
      aad: utf8.encode('bastion-meshcore-backup-v1'),
    );
    final decoded = jsonDecode(utf8.decode(bytes));
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid settings.');
    }
    final values = decoded.map((key, value) => MapEntry(key, value as Object));
    _validate(values);
    return values;
  }

  static void _validate(Map<String, Object> values) {
    if (values.length > 20000) {
      throw const FormatException('Too many settings.');
    }
    for (final entry in values.entries) {
      final v = entry.value;
      if (entry.key.isEmpty ||
          entry.key.length > 512 ||
          !(v is String ||
              v is bool ||
              v is int ||
              v is double ||
              v is List && v.every((item) => item is String))) {
        throw const FormatException('Unsupported setting value.');
      }
    }
  }

  /// Whether a backed-up setting may be written back on this device.
  ///
  /// Security switches stay as this device has them. Old chat keys are
  /// skipped because message history lives in the database now, and is
  /// restored by [restoreHistory].
  static bool isRestorable(String key) =>
      key != HistoryBackup.key &&
      key != journalKey &&
      key != MessageDb.encryptPrefKey &&
      key != 'app_lock_enabled' &&
      !key.startsWith('messages_') &&
      !key.startsWith('channel_messages');

  /// Holds the settings as they were before a restore, until it finishes.
  /// Kept in the encrypted store, because it can hold contacts and keys.
  static const journalKey = 'restore_journal_v1';

  /// Writes [values] back and returns how many were restored. Settings not
  /// in the backup are left alone. The app must restart to use them.
  ///
  /// All or nothing: the current value of every setting it will touch is
  /// saved first. If any write fails, they are all put back and
  /// [RestoreRolledBackException] is thrown. If the app stops part way,
  /// [recoverInterruptedRestore] puts them back at the next start.
  Future<int> restore(Map<String, Object> values) async {
    _validate(values);
    final writes = {
      for (final e in values.entries)
        if (isRestorable(e.key)) e.key: e.value,
    };
    final before = <String, Object?>{
      for (final key in writes.keys) key: _current(key),
    };
    await SecurePrefs.setString(journalKey, jsonEncode(before));
    try {
      for (final entry in writes.entries) {
        await _write(entry.key, entry.value);
      }
    } catch (e) {
      await _rollBack(before);
      throw RestoreRolledBackException(e);
    }
    await SecurePrefs.remove(journalKey);
    return writes.length;
  }

  /// Puts settings back after a restore the app didn't finish. Call once
  /// at startup, after [SecurePrefs.initialize]. Returns whether anything
  /// was put back.
  static Future<bool> recoverInterruptedRestore() async {
    final String? raw;
    try {
      raw = SecurePrefs.getString(journalKey);
    } on StateError {
      return false;
    }
    if (raw == null) return false;
    try {
      final before = (jsonDecode(raw) as Map<String, dynamic>)
          .cast<String, Object?>();
      await _rollBack(before);
      return true;
    } on FormatException {
      // Unreadable journal: nothing safe to put back.
      await SecurePrefs.remove(journalKey);
      return false;
    }
  }

  static Object? _current(String key) {
    if (SecurePrefs.isSensitive(key)) return SecurePrefs.getString(key);
    return PrefsManager.instance.get(key);
  }

  static Future<void> _write(String key, Object value) async {
    final prefs = PrefsManager.instance;
    switch (value) {
      case final String v when SecurePrefs.isSensitive(key):
        await SecurePrefs.setString(key, v);
      case final String v:
        await prefs.setString(key, v);
      case final bool v:
        await prefs.setBool(key, v);
      case final int v:
        await prefs.setInt(key, v);
      case final double v:
        await prefs.setDouble(key, v);
      case final List<dynamic> v:
        await prefs.setStringList(key, v.cast<String>());
    }
  }

  /// Writes every saved value back (removing settings that didn't exist),
  /// then drops the journal. Keeps going past single failures so as much
  /// as possible is put back; the journal stays if anything failed, so the
  /// next start tries again.
  static Future<void> _rollBack(Map<String, Object?> before) async {
    var failed = false;
    for (final entry in before.entries) {
      try {
        final value = entry.value;
        if (value == null) {
          if (SecurePrefs.isSensitive(entry.key)) {
            await SecurePrefs.remove(entry.key);
          } else {
            await PrefsManager.instance.remove(entry.key);
          }
        } else {
          await _write(entry.key, value);
        }
      } catch (_) {
        failed = true;
      }
    }
    if (!failed) await SecurePrefs.remove(journalKey);
  }

  Map<String, Object> snapshot({required bool includeChats}) {
    final prefs = PrefsManager.instance;
    return {
      for (final key in prefs.getKeys())
        if (includeChats ||
            !key.startsWith('messages_') && !key.startsWith('channel_messages'))
          key: prefs.get(key)!,
      ...SecurePrefs.snapshot(),
    };
  }

  /// Adds the message history in [values] to [db], keeping what's already
  /// there, and returns how many messages were new. Does nothing if the
  /// backup has no history.
  static int restoreHistory(Map<String, Object> values, MessageDb db) {
    final history = values[HistoryBackup.key];
    if (history == null) return 0;
    return HistoryBackup.restore(db, history);
  }

  /// [values] with this device's message history added under
  /// [HistoryBackup.key].
  static Map<String, Object> withHistory(
    Map<String, Object> values,
    MessageDb db,
  ) => {...values, HistoryBackup.key: HistoryBackup.encode(db)};
}
