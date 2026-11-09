import 'package:latlong2/latlong.dart';

enum AutomationTrigger {
  batteryBelow,
  atTime,
  enterArea,
  leaveArea,
  nodeHeard,
  nodeQuiet,
}

enum AutomationAction { notify, send }

/// One "when this happens, do that" rule. Off until the user turns it on.
class AutomationRule {
  const AutomationRule({
    required this.id,
    required this.name,
    required this.trigger,
    this.enabled = false,
    this.batteryPercent = 20,
    this.minuteOfDay = 480,
    this.latitude,
    this.longitude,
    this.radiusMeters = 500,
    this.nodeKey,
    this.nodeMinutes = 30,
    this.action = AutomationAction.notify,
    this.target,
    this.text = '',
  });

  factory AutomationRule.fromJson(Map<String, dynamic> j) => AutomationRule(
    id: j['id'] as String,
    name: j['name'] as String,
    trigger: AutomationTrigger.values.byName(j['trigger'] as String),
    enabled: j['enabled'] as bool? ?? false,
    batteryPercent: j['batteryPercent'] as int? ?? 20,
    minuteOfDay: j['minuteOfDay'] as int? ?? 480,
    latitude: (j['latitude'] as num?)?.toDouble(),
    longitude: (j['longitude'] as num?)?.toDouble(),
    radiusMeters: j['radiusMeters'] as int? ?? 500,
    nodeKey: j['nodeKey'] as String?,
    nodeMinutes: j['nodeMinutes'] as int? ?? 30,
    action: AutomationAction.values.byName(j['action'] as String),
    target: j['target'] as String?,
    text: j['text'] as String? ?? '',
  );

  final String id;
  final String name;
  final AutomationTrigger trigger;
  final bool enabled;
  final int batteryPercent;

  /// Local time of day, in minutes after midnight.
  final int minuteOfDay;
  final double? latitude;
  final double? longitude;
  final int radiusMeters;
  final String? nodeKey;

  /// How recent a node's last advert counts as "heard".
  final int nodeMinutes;
  final AutomationAction action;

  /// `message:<contact key>` or `channel:<index>`, for [AutomationAction.send].
  final String? target;
  final String text;

  AutomationRule copyWith({bool? enabled}) => AutomationRule(
    id: id,
    name: name,
    trigger: trigger,
    enabled: enabled ?? this.enabled,
    batteryPercent: batteryPercent,
    minuteOfDay: minuteOfDay,
    latitude: latitude,
    longitude: longitude,
    radiusMeters: radiusMeters,
    nodeKey: nodeKey,
    nodeMinutes: nodeMinutes,
    action: action,
    target: target,
    text: text,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'trigger': trigger.name,
    'enabled': enabled,
    'batteryPercent': batteryPercent,
    'minuteOfDay': minuteOfDay,
    'latitude': latitude,
    'longitude': longitude,
    'radiusMeters': radiusMeters,
    'nodeKey': nodeKey,
    'nodeMinutes': nodeMinutes,
    'action': action.name,
    'target': target,
    'text': text,
  };
}

/// What the rules can see at one moment. Null means not known right now.
class AutomationSnapshot {
  const AutomationSnapshot({
    required this.now,
    this.batteryPercent,
    this.latitude,
    this.longitude,
    this.nodeLastSeen = const {},
  });

  final DateTime now;
  final int? batteryPercent;
  final double? latitude;
  final double? longitude;
  final Map<String, DateTime> nodeLastSeen;
}

/// Decides which rules fire. No radio, storage or UI, so it can be tested.
///
/// A rule fires when its condition *becomes* true, once per crossing. The
/// first reading only records the state, so opening the app or connecting
/// can't set off a burst. Limits keep a bad rule from flooding the mesh.
class AutomationEngine {
  static const ruleCooldown = Duration(minutes: 15);
  static const sendWindow = Duration(minutes: 10);
  static const maxSendsPerWindow = 3;

  final Map<String, bool> _state = {};
  final Map<String, DateTime> _lastFired = {};
  final List<DateTime> _recentSends = [];

  /// The enabled rules that should act now, in the given order.
  List<AutomationRule> evaluate(
    List<AutomationRule> rules,
    AutomationSnapshot snapshot,
  ) {
    final now = snapshot.now;
    _recentSends.removeWhere((t) => now.difference(t) >= sendWindow);
    final fired = <AutomationRule>[];
    for (final rule in rules) {
      if (!rule.enabled) {
        _state.remove(rule.id);
        continue;
      }
      final condition = _condition(rule, snapshot);
      if (condition == null) continue; // Unknown keeps the last state.
      final previous = _state[rule.id];
      _state[rule.id] = condition;
      if (previous != false || !condition) continue;
      final last = _lastFired[rule.id];
      if (last != null && now.difference(last) < ruleCooldown) continue;
      if (rule.action == AutomationAction.send) {
        if (_recentSends.length >= maxSendsPerWindow) continue;
        _recentSends.add(now);
      }
      _lastFired[rule.id] = now;
      fired.add(rule);
    }
    return fired;
  }

  bool? _condition(AutomationRule rule, AutomationSnapshot s) {
    switch (rule.trigger) {
      case AutomationTrigger.batteryBelow:
        final battery = s.batteryPercent;
        return battery == null ? null : battery < rule.batteryPercent;
      case AutomationTrigger.atTime:
        return s.now.hour * 60 + s.now.minute == rule.minuteOfDay;
      case AutomationTrigger.enterArea:
        return _inside(rule, s);
      case AutomationTrigger.leaveArea:
        final inside = _inside(rule, s);
        return inside == null ? null : !inside;
      case AutomationTrigger.nodeHeard:
        return _heard(rule, s);
      case AutomationTrigger.nodeQuiet:
        final heard = _heard(rule, s);
        return heard == null ? null : !heard;
    }
  }

  bool? _inside(AutomationRule rule, AutomationSnapshot s) {
    final lat = s.latitude, lon = s.longitude;
    final ruleLat = rule.latitude, ruleLon = rule.longitude;
    if (lat == null || lon == null || ruleLat == null || ruleLon == null) {
      return null;
    }
    final meters = const Distance().as(
      LengthUnit.Meter,
      LatLng(lat, lon),
      LatLng(ruleLat, ruleLon),
    );
    return meters <= rule.radiusMeters;
  }

  bool? _heard(AutomationRule rule, AutomationSnapshot s) {
    final seen = s.nodeLastSeen[rule.nodeKey];
    if (seen == null) return null;
    return s.now.difference(seen) <= Duration(minutes: rule.nodeMinutes);
  }
}
