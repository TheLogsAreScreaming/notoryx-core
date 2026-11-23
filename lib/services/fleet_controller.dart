import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/contact.dart';
import '../models/fleet.dart';
import 'fleet_radio.dart';
import 'fleet_station_client.dart';
import 'fleet_store.dart';

/// Runs Fleet's polls, bulk settings and station sync.
///
/// Airtime first: one repeater at a time, [stagger] apart, firmware asked
/// once a day and neighbours every six hours.
class FleetController extends ChangeNotifier {
  FleetController({
    required this.store,
    required this.passwords,
    required this.radio,
    required this.contactFor,
    this.onStatus,
    Duration stagger = minStagger,
    Future<void> Function(Duration)? wait,
    DateTime Function()? clock,
  }) : stagger = stagger < minStagger ? minStagger : stagger,
       _wait = wait ?? Future.delayed,
       _now = clock ?? DateTime.now;

  final FleetStore store;
  final FleetPasswordStore passwords;
  final FleetRadio radio;

  /// The radio's contact for a repeater key, or null when the radio
  /// doesn't hold it (then it can't be reached).
  final Contact? Function(String key) contactFor;

  /// Called with each answered status, so other screens' history sees it.
  final void Function(String key, FleetSample sample)? onStatus;

  final Duration stagger;
  final Future<void> Function(Duration) _wait;
  final DateTime Function() _now;

  static const minStagger = Duration(seconds: 20);
  static const firmwareEvery = Duration(hours: 24);
  static const neighboursEvery = Duration(hours: 6);

  bool _disposed = false;
  bool _busy = false;
  bool _stop = false;
  String? _current;
  int _done = 0;
  int _total = 0;

  /// Whether a poll, preview or apply is running.
  bool get busy => _busy;

  /// The key being asked right now.
  String? get current => _current;
  int get done => _done;
  int get total => _total;

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _stop = true;
    super.dispose();
  }

  /// Stops after the repeater being asked now.
  void stop() {
    _stop = true;
    notifyListeners();
  }

  Future<T> _run<T>(int total, Future<T> Function() body) async {
    _busy = true;
    _stop = false;
    _done = 0;
    _total = total;
    notifyListeners();
    try {
      return await body();
    } finally {
      _busy = false;
      _current = null;
      notifyListeners();
    }
  }

  Future<void> _step(int index, String key) async {
    if (index > 0) await _wait(stagger);
    _current = key;
    notifyListeners();
  }

  void _advance() {
    _done++;
    notifyListeners();
  }

  /// Logs in to and asks status of every repeater in the list, in turn.
  Future<void> pollAll() async {
    if (_busy) return;
    final list = store.repeaters;
    await _run(list.length, () async {
      for (var i = 0; i < list.length && !_stop; i++) {
        await _step(i, list[i].publicKeyHex);
        if (_stop) break;
        await pollOne(list[i].publicKeyHex);
        _advance();
      }
    });
  }

  DateTime? _lastWith(String key, bool Function(FleetSample) has) {
    final h = store.historyFor(key);
    for (var i = h.length - 1; i >= 0; i--) {
      if (has(h[i])) return h[i].at;
    }
    return null;
  }

  bool _due(String key, bool Function(FleetSample) has, Duration every) {
    final last = _lastWith(key, has);
    return last == null || _now().difference(last) >= every;
  }

  /// One poll of [key]: login, status, and firmware or neighbours when due.
  Future<FleetSample> pollOne(String key) async {
    FleetSample fail(String error) {
      final s = FleetSample(at: _now(), ok: false, error: error);
      store.record(key, s);
      return s;
    }

    final contact = contactFor(key);
    if (contact == null) return fail('no_contact');
    final password = await passwords.read(key) ?? '';
    final login = await radio.login(contact, password);
    if (login == null) return fail('timeout');
    if (!login) return fail('login');
    final st = await radio.status(contact);
    if (st == null) return fail('timeout');

    String? firmware;
    if (_due(key, (s) => s.firmware != null, firmwareEvery)) {
      final reply = await radio.command(contact, 'ver');
      if (reply != null && reply.trim().isNotEmpty) {
        final t = reply.trim();
        firmware = t.length > 80 ? t.substring(0, 80) : t;
      }
    }
    int? neighbours;
    if (_due(key, (s) => s.neighbours != null, neighboursEvery)) {
      neighbours = await radio.neighbourCount(contact);
    }
    final sample = FleetSample(
      at: _now(),
      ok: true,
      batteryMv: st.batteryMv,
      noiseFloor: st.noiseFloor,
      lastRssi: st.lastRssi,
      lastSnr: st.lastSnr,
      uptimeSecs: st.uptimeSecs,
      firmware: firmware,
      neighbours: neighbours,
    );
    store.record(key, sample);
    onStatus?.call(key, sample);
    return sample;
  }

  /// Reads `get <setting>` from each of [keys] so the user can see what a
  /// bulk change would do. Sends nothing that changes a repeater.
  Future<List<FleetSettingDiff>> preview(
    List<String> keys,
    String setting,
    String value,
  ) async {
    if (_busy || !isAllowedBulkSetting(setting, value)) return const [];
    return _run(keys.length, () async {
      final out = <FleetSettingDiff>[];
      for (var i = 0; i < keys.length && !_stop; i++) {
        final rep = store.byKey(keys[i]);
        if (rep == null) continue;
        await _step(i, rep.publicKeyHex);
        if (_stop) break;
        final (current, error) = await _get(rep.publicKeyHex, setting);
        out.add(
          FleetSettingDiff(
            repeater: rep,
            current: current,
            target: value.trim(),
            error: error,
          ),
        );
        _advance();
      }
      return out;
    });
  }

  Future<(String?, String?)> _get(String key, String setting) async {
    final contact = contactFor(key);
    if (contact == null) return (null, 'no_contact');
    final ok = await radio.login(contact, await passwords.read(key) ?? '');
    if (ok == null) return (null, 'timeout');
    if (!ok) return (null, 'login');
    final reply = await radio.command(contact, 'get $setting');
    if (reply == null) return (null, 'timeout');
    return (parseGetReply(reply), null);
  }

  /// Sends `set` to each row of a confirmed preview that would change.
  /// Returns each repeater's reply (or error code) by key.
  Future<Map<String, String>> apply(
    List<FleetSettingDiff> confirmed,
    String setting,
  ) async {
    final rows = confirmed
        .where((d) => d.changes && isAllowedBulkSetting(setting, d.target))
        .toList();
    if (_busy || rows.isEmpty) return const {};
    return _run(rows.length, () async {
      final out = <String, String>{};
      for (var i = 0; i < rows.length && !_stop; i++) {
        final key = rows[i].repeater.publicKeyHex;
        await _step(i, key);
        if (_stop) break;
        final contact = contactFor(key);
        if (contact == null) {
          out[key] = 'no_contact';
        } else {
          final ok = await radio.login(
            contact,
            await passwords.read(key) ?? '',
          );
          if (ok != true) {
            out[key] = ok == null ? 'timeout' : 'login';
          } else {
            out[key] =
                await radio.command(
                  contact,
                  'set $setting ${rows[i].target}',
                ) ??
                'timeout';
          }
        }
        _advance();
      }
      return out;
    });
  }

  /// Copies history from a station on the LAN. Only GET requests are made
  /// and no password leaves the phone. Repeaters the station watches that
  /// aren't in the list yet are added when [addMissing] is set.
  /// Returns how many new samples were kept.
  Future<int> syncFromStation(
    FleetStationClient client, {
    int days = 7,
    bool addMissing = true,
  }) async {
    final remote = await client.fleet();
    var added = 0;
    for (final r in remote) {
      if (!store.contains(r.publicKeyHex)) {
        if (!addMissing) continue;
        store.add(r.publicKeyHex, r.name, stationId: r.id);
      } else {
        store.setStationId(r.publicKeyHex, r.id);
      }
      final history = await client.history(r.id, days: days);
      added += store.mergeStation(r.publicKeyHex, history);
    }
    return added;
  }
}
