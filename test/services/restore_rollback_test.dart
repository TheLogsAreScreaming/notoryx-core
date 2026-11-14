import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:meshcore_open/services/encrypted_backup_service.dart';
import 'package:meshcore_open/storage/prefs_manager.dart';
import 'package:meshcore_open/storage/secure_prefs.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';
import 'package:shared_preferences_platform_interface/types.dart';

/// Plain-prefs store whose writes start failing after [failAfter] writes.
class _FlakyStore extends SharedPreferencesStorePlatform {
  _FlakyStore(this._data);
  final Map<String, Object> _data;
  int? failAfter;
  var writes = 0;

  void _tick() {
    final limit = failAfter;
    if (limit != null && writes++ >= limit) throw StateError('disk full');
  }

  @override
  Future<bool> clear() async => true;
  @override
  Future<Map<String, Object>> getAll() async => Map.of(_data);
  @override
  Future<Map<String, Object>> getAllWithParameters(
    GetAllParameters parameters,
  ) async => {
    for (final e in _data.entries)
      if (e.key.startsWith(parameters.filter.prefix)) e.key: e.value,
  };
  @override
  Future<bool> remove(String key) async {
    _tick();
    _data.remove(key);
    return true;
  }

  @override
  Future<bool> setValue(String valueType, String key, Object value) async {
    _tick();
    _data[key] = value;
    return true;
  }

  @override
  Future<bool> clearWithParameters(ClearParameters parameters) async => true;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _FlakyStore store;
  final service = EncryptedBackupService();

  Future<void> boot(Map<String, Object> initial) async {
    PrefsManager.reset();
    SecurePrefs.resetForTest();
    store = _FlakyStore({
      for (final e in initial.entries) 'flutter.${e.key}': e.value,
    });
    SharedPreferencesStorePlatform.instance = store;
    // ignore: invalid_use_of_visible_for_testing_member
    SharedPreferences.resetStatic();
    await PrefsManager.initialize();
  }

  test('a failure part way puts every setting back', () async {
    await boot({'theme': 'blaze', 'units': 'metric', 'lock_timeout': 5});
    // Journal write + 1 setting succeed, then the disk fills.
    store.failAfter = 2;
    await expectLater(
      service.restore({
        'theme': 'night',
        'units': 'imperial',
        'lock_timeout': 30,
        'new_key': true,
      }),
      throwsA(isA<RestoreRolledBackException>()),
    );
    store.failAfter = null;
    // Writes failed mid-way, so the rollback could not finish either; the
    // journal stays and the next start finishes it.
    expect(await EncryptedBackupService.recoverInterruptedRestore(), isTrue);
    final prefs = PrefsManager.instance;
    expect(prefs.getString('theme'), 'blaze');
    expect(prefs.getString('units'), 'metric');
    expect(prefs.getInt('lock_timeout'), 5);
    expect(prefs.containsKey('new_key'), isFalse);
    expect(prefs.containsKey(EncryptedBackupService.journalKey), isFalse);
  });

  test('a single failed write rolls back straight away', () async {
    await boot({'theme': 'blaze', 'units': 'metric'});
    // Journal, then 'theme' succeed; 'units' fails once.
    SharedPreferencesStorePlatform.instance = _OneShot(store, failOn: 3);
    // ignore: invalid_use_of_visible_for_testing_member
    SharedPreferences.resetStatic();
    PrefsManager.reset();
    await PrefsManager.initialize();
    await expectLater(
      service.restore({'theme': 'night', 'units': 'imperial'}),
      throwsA(isA<RestoreRolledBackException>()),
    );
    final prefs = PrefsManager.instance;
    expect(prefs.getString('theme'), 'blaze');
    expect(prefs.getString('units'), 'metric');
    expect(prefs.containsKey(EncryptedBackupService.journalKey), isFalse);
  });

  test('an app stop part way is undone at the next start', () async {
    await boot({'theme': 'blaze'});
    // What a killed restore leaves: the journal plus some new values.
    final prefs = PrefsManager.instance;
    await prefs.setString(
      EncryptedBackupService.journalKey,
      jsonEncode({'theme': 'blaze', 'added': null}),
    );
    await prefs.setString('theme', 'night');
    await prefs.setBool('added', true);
    expect(await EncryptedBackupService.recoverInterruptedRestore(), isTrue);
    expect(prefs.getString('theme'), 'blaze');
    expect(prefs.containsKey('added'), isFalse);
    expect(await EncryptedBackupService.recoverInterruptedRestore(), isFalse);
  });

  test('a successful restore leaves no journal', () async {
    await boot({'theme': 'blaze'});
    expect(await service.restore({'theme': 'night', 'n': 2}), 2);
    final prefs = PrefsManager.instance;
    expect(prefs.getString('theme'), 'night');
    expect(prefs.getInt('n'), 2);
    expect(prefs.containsKey(EncryptedBackupService.journalKey), isFalse);
    expect(await EncryptedBackupService.recoverInterruptedRestore(), isFalse);
  });

  test('security switches and the journal itself are never restored', () {
    expect(EncryptedBackupService.isRestorable('app_lock_enabled'), isFalse);
    expect(
      EncryptedBackupService.isRestorable(EncryptedBackupService.journalKey),
      isFalse,
    );
    expect(SecurePrefs.isSensitive(EncryptedBackupService.journalKey), isTrue);
  });
}

/// Fails exactly the [failOn]th write (1-based), then works again.
class _OneShot extends _FlakyStore {
  _OneShot(_FlakyStore base, {required this.failOn}) : super(base._data);
  final int failOn;
  var _n = 0;

  @override
  Future<bool> setValue(String valueType, String key, Object value) async {
    if (++_n == failOn) throw StateError('disk hiccup');
    _data[key] = value;
    return true;
  }
}
