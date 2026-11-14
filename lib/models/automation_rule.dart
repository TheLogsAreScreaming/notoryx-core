import 'package:latlong2/latlong.dart';

enum AutomationTrigger {
  batteryBelow,
  atTime,
  enterArea,
  leaveArea,
  nodeHeard,
  nodeQuiet,
  messageReceived,
}

/// How a rule with several conditions decides: [any] runs when one of them
/// happens, [all] when one happens and every other one holds right then.
enum AutomationCombine { any, all }

enum AutomationAction { notify, send, joinChannel, playSound, webhook }

/// One "when" part of a rule.
class AutomationCondition {
  const AutomationCondition({
    required this.trigger,
    this.batteryPercent = 20,
    this.minuteOfDay = 480,
    this.latitude,
    this.longitude,
    this.radiusMeters = 500,
    this.nodeKey,
    this.nodeMinutes = 30,
    this.contains = '',
  });

  factory AutomationCondition.fromJson(Map<String, dynamic> j) =>
      AutomationCondition(
        trigger: AutomationTrigger.values.byName(j['trigger'] as String),
        batteryPercent: j['batteryPercent'] as int? ?? 20,
        minuteOfDay: j['minuteOfDay'] as int? ?? 480,
        latitude: (j['latitude'] as num?)?.toDouble(),
        longitude: (j['longitude'] as num?)?.toDouble(),
        radiusMeters: j['radiusMeters'] as int? ?? 500,
        nodeKey: j['nodeKey'] as String?,
        nodeMinutes: j['nodeMinutes'] as int? ?? 30,
        contains: j['contains'] as String? ?? '',
      );

  final AutomationTrigger trigger;
  final int batteryPercent;

  /// Local time of day, in minutes after midnight.
  final int minuteOfDay;
  final double? latitude;
  final double? longitude;
  final int radiusMeters;

  /// The node for heard/quiet, or the only sender a message may come from
  /// (null: anyone).
  final String? nodeKey;

  /// How recent a node's last advert counts as "heard".
  final int nodeMinutes;

  /// Text a received message must contain, ignoring case (empty: any).
  final String contains;

  bool get isArea =>
      trigger == AutomationTrigger.enterArea ||
      trigger == AutomationTrigger.leaveArea;
  bool get isNode =>
      trigger == AutomationTrigger.nodeHeard ||
      trigger == AutomationTrigger.nodeQuiet;

  Map<String, dynamic> toJson() => {
    'trigger': trigger.name,
    'batteryPercent': batteryPercent,
    'minuteOfDay': minuteOfDay,
    'latitude': latitude,
    'longitude': longitude,
    'radiusMeters': radiusMeters,
    'nodeKey': nodeKey,
    'nodeMinutes': nodeMinutes,
    'contains': contains,
  };
}

/// One "do this" part of a rule.
class AutomationStep {
  const AutomationStep({required this.action, this.target, this.text = ''});

  factory AutomationStep.fromJson(Map<String, dynamic> j) => AutomationStep(
    action: AutomationAction.values.byName(j['action'] as String),
    target: j['target'] as String?,
    text: j['text'] as String? ?? '',
  );

  final AutomationAction action;

  /// For [AutomationAction.send]: `message:<contact key>` or
  /// `channel:<index>`. For [AutomationAction.webhook]: the URL.
  final String? target;

  /// Message or alert text (placeholders allowed), or the hashtag channel
  /// to join.
  final String text;

  /// Whether this step goes out over the mesh and counts against the
  /// shared send limit.
  bool get sends => action == AutomationAction.send;

  /// Whether this step needs the internet.
  bool get needsInternet => action == AutomationAction.webhook;

  Map<String, dynamic> toJson() => {
    'action': action.name,
    'target': target,
    'text': text,
  };
}

/// One "when this happens, do that" rule. Off until the user turns it on.
class AutomationRule {
  const AutomationRule({
    required this.id,
    required this.name,
    required this.conditions,
    required this.steps,
    this.combine = AutomationCombine.any,
    this.enabled = false,
  });

  /// Reads both the current form and the one-trigger, one-action form
  /// saved by earlier versions.
  factory AutomationRule.fromJson(Map<String, dynamic> j) {
    final conditions = j['conditions'] as List<dynamic>?;
    final steps = j['steps'] as List<dynamic>?;
    return AutomationRule(
      id: j['id'] as String,
      name: j['name'] as String,
      enabled: j['enabled'] as bool? ?? false,
      combine: AutomationCombine.values.byName(
        j['combine'] as String? ?? AutomationCombine.any.name,
      ),
      conditions: conditions == null
          ? [AutomationCondition.fromJson(j)]
          : [
              for (final c in conditions)
                AutomationCondition.fromJson(c as Map<String, dynamic>),
            ],
      steps: steps == null
          ? [AutomationStep.fromJson(j)]
          : [
              for (final s in steps)
                AutomationStep.fromJson(s as Map<String, dynamic>),
            ],
    );
  }

  final String id;
  final String name;
  final bool enabled;
  final AutomationCombine combine;
  final List<AutomationCondition> conditions;
  final List<AutomationStep> steps;

  bool get sends => steps.any((s) => s.sends);
  bool get needsInternet => steps.any((s) => s.needsInternet);

  AutomationRule copyWith({bool? enabled}) => AutomationRule(
    id: id,
    name: name,
    enabled: enabled ?? this.enabled,
    combine: combine,
    conditions: conditions,
    steps: steps,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'enabled': enabled,
    'combine': combine.name,
    'conditions': [for (final c in conditions) c.toJson()],
    'steps': [for (final s in steps) s.toJson()],
  };
}

/// A message that arrived since the last pass.
class AutomationMessage {
  const AutomationMessage({
    required this.text,
    this.senderKey,
    this.senderName = '',
    this.channelIndex,
  });

  final String text;

  /// The sender's public key, for direct messages and channel posts whose
  /// sender name matches a contact.
  final String? senderKey;
  final String senderName;

  /// Null for direct messages.
  final int? channelIndex;
}

/// What the rules can see at one moment. Null means not known right now.
class AutomationSnapshot {
  const AutomationSnapshot({
    required this.now,
    this.batteryPercent,
    this.latitude,
    this.longitude,
    this.nodeLastSeen = const {},
    this.messages = const [],
  });

  final DateTime now;
  final int? batteryPercent;
  final double? latitude;
  final double? longitude;
  final Map<String, DateTime> nodeLastSeen;

  /// Messages received since the last pass, oldest first.
  final List<AutomationMessage> messages;
}

/// A rule that should act now, with the message that set it off, if any.
class AutomationFiring {
  const AutomationFiring(this.rule, {this.message});

  final AutomationRule rule;
  final AutomationMessage? message;
}

/// Decides which rules fire. No radio, storage or UI, so it can be tested.
///
/// A state condition (battery, time, area, node) happens when it *becomes*
/// true, once per crossing; the first reading only records the state, so
/// opening the app or connecting can't set off a burst. A message
/// condition happens when a matching message arrives. Limits keep a bad
/// rule from flooding the mesh.
class AutomationEngine {
  static const ruleCooldown = Duration(minutes: 15);
  static const sendWindow = Duration(minutes: 10);
  static const maxSendsPerWindow = 3;

  final Map<String, bool> _state = {};
  final Map<String, DateTime> _lastFired = {};
  final List<DateTime> _recentSends = [];

  /// The enabled rules that should act now, in the given order.
  List<AutomationFiring> evaluate(
    List<AutomationRule> rules,
    AutomationSnapshot snapshot,
  ) {
    final now = snapshot.now;
    _recentSends.removeWhere((t) => now.difference(t) >= sendWindow);
    final fired = <AutomationFiring>[];
    for (final rule in rules) {
      if (!rule.enabled || rule.conditions.isEmpty) {
        _state.removeWhere((k, _) => k.startsWith('${rule.id}#'));
        continue;
      }
      var happened = false;
      var allHold = true;
      AutomationMessage? message;
      for (var i = 0; i < rule.conditions.length; i++) {
        final condition = rule.conditions[i];
        if (condition.trigger == AutomationTrigger.messageReceived) {
          final match = _firstMatch(condition, snapshot.messages);
          if (match != null) {
            happened = true;
            message ??= match;
          } else {
            allHold = false;
          }
          continue;
        }
        final key = '${rule.id}#$i';
        final now = _condition(condition, snapshot);
        final previous = _state[key];
        if (now != null) _state[key] = now; // Unknown keeps the last state.
        final holds = now ?? previous ?? false;
        if (!holds) allHold = false;
        if (now == true && previous == false) happened = true;
      }
      final runs = rule.combine == AutomationCombine.any
          ? happened
          : happened && allHold;
      if (!runs) continue;
      final last = _lastFired[rule.id];
      if (last != null && now.difference(last) < ruleCooldown) continue;
      if (rule.sends) {
        if (_recentSends.length >= maxSendsPerWindow) continue;
        _recentSends.add(now);
      }
      _lastFired[rule.id] = now;
      fired.add(AutomationFiring(rule, message: message));
    }
    return fired;
  }

  AutomationMessage? _firstMatch(
    AutomationCondition c,
    List<AutomationMessage> messages,
  ) {
    final needle = c.contains.trim().toLowerCase();
    for (final m in messages) {
      if (c.nodeKey != null && m.senderKey != c.nodeKey) continue;
      if (needle.isNotEmpty && !m.text.toLowerCase().contains(needle)) {
        continue;
      }
      return m;
    }
    return null;
  }

  bool? _condition(AutomationCondition c, AutomationSnapshot s) {
    switch (c.trigger) {
      case AutomationTrigger.batteryBelow:
        final battery = s.batteryPercent;
        return battery == null ? null : battery < c.batteryPercent;
      case AutomationTrigger.atTime:
        return s.now.hour * 60 + s.now.minute == c.minuteOfDay;
      case AutomationTrigger.enterArea:
        return _inside(c, s);
      case AutomationTrigger.leaveArea:
        final inside = _inside(c, s);
        return inside == null ? null : !inside;
      case AutomationTrigger.nodeHeard:
        return _heard(c, s);
      case AutomationTrigger.nodeQuiet:
        final heard = _heard(c, s);
        return heard == null ? null : !heard;
      case AutomationTrigger.messageReceived:
        return null;
    }
  }

  bool? _inside(AutomationCondition c, AutomationSnapshot s) {
    final lat = s.latitude, lon = s.longitude;
    final ruleLat = c.latitude, ruleLon = c.longitude;
    if (lat == null || lon == null || ruleLat == null || ruleLon == null) {
      return null;
    }
    final meters = const Distance().as(
      LengthUnit.Meter,
      LatLng(lat, lon),
      LatLng(ruleLat, ruleLon),
    );
    return meters <= c.radiusMeters;
  }

  bool? _heard(AutomationCondition c, AutomationSnapshot s) {
    final seen = s.nodeLastSeen[c.nodeKey];
    if (seen == null) return null;
    return s.now.difference(seen) <= Duration(minutes: c.nodeMinutes);
  }
}

/// Fills `{rule} {time} {battery} {node} {text}` in [template].
String fillAutomationText(
  String template, {
  required String rule,
  required String time,
  int? battery,
  AutomationMessage? message,
}) => template
    .replaceAll('{rule}', rule)
    .replaceAll('{time}', time)
    .replaceAll('{battery}', battery == null ? '?' : '$battery%')
    .replaceAll('{node}', message?.senderName ?? '')
    .replaceAll('{text}', message?.text ?? '');
