import 'package:flutter_test/flutter_test.dart';
import 'package:meshcore_open/models/automation_rule.dart';

AutomationRule _rule(
  String id,
  AutomationTrigger trigger, {
  bool enabled = true,
  AutomationAction action = AutomationAction.notify,
  int minuteOfDay = 480,
}) => AutomationRule(
  id: id,
  name: id,
  enabled: enabled,
  conditions: [
    AutomationCondition(
      trigger: trigger,
      minuteOfDay: minuteOfDay,
      latitude: 40,
      longitude: -74,
      nodeKey: 'n',
    ),
  ],
  steps: [AutomationStep(action: action, text: 'hi')],
);

final _t0 = DateTime(2026, 11, 8, 12);
AutomationSnapshot _battery(int? b, Duration after) =>
    AutomationSnapshot(now: _t0.add(after), batteryPercent: b);

void main() {
  test('fires once when the battery crosses, not on the first reading', () {
    final e = AutomationEngine();
    final r = [_rule('b', AutomationTrigger.batteryBelow)];
    expect(e.evaluate(r, _battery(50, Duration.zero)), isEmpty);
    expect(
      e.evaluate(r, _battery(15, const Duration(minutes: 1))),
      hasLength(1),
    );
    expect(e.evaluate(r, _battery(14, const Duration(minutes: 2))), isEmpty);
  });

  test('already low at startup stays quiet', () {
    final e = AutomationEngine();
    final r = [_rule('b', AutomationTrigger.batteryBelow)];
    expect(e.evaluate(r, _battery(5, Duration.zero)), isEmpty);
  });

  test('a flapping condition is held to the cooldown', () {
    final e = AutomationEngine();
    final r = [_rule('b', AutomationTrigger.batteryBelow)];
    e.evaluate(r, _battery(50, Duration.zero));
    expect(
      e.evaluate(r, _battery(10, const Duration(minutes: 1))),
      hasLength(1),
    );
    e.evaluate(r, _battery(50, const Duration(minutes: 2)));
    expect(e.evaluate(r, _battery(10, const Duration(minutes: 3))), isEmpty);
    e.evaluate(r, _battery(50, const Duration(minutes: 20)));
    expect(
      e.evaluate(r, _battery(10, const Duration(minutes: 21))),
      hasLength(1),
    );
  });

  test('a lost reading does not count as a change', () {
    final e = AutomationEngine();
    final r = [_rule('b', AutomationTrigger.batteryBelow)];
    e.evaluate(r, _battery(50, Duration.zero));
    expect(e.evaluate(r, _battery(null, const Duration(minutes: 1))), isEmpty);
    expect(e.evaluate(r, _battery(50, const Duration(minutes: 2))), isEmpty);
  });

  test('disabled rules never fire', () {
    final e = AutomationEngine();
    final r = [_rule('b', AutomationTrigger.batteryBelow, enabled: false)];
    e.evaluate(r, _battery(50, Duration.zero));
    expect(e.evaluate(r, _battery(10, const Duration(minutes: 1))), isEmpty);
  });

  test('sends are capped across all rules', () {
    final e = AutomationEngine();
    final r = [
      for (var i = 0; i < 5; i++)
        _rule(
          's$i',
          AutomationTrigger.batteryBelow,
          action: AutomationAction.send,
        ),
    ];
    e.evaluate(r, _battery(50, Duration.zero));
    expect(
      e.evaluate(r, _battery(10, const Duration(minutes: 1))),
      hasLength(3),
    );
  });

  test('a daily time fires once on that minute', () {
    final e = AutomationEngine();
    final r = [_rule('t', AutomationTrigger.atTime, minuteOfDay: 721)];
    expect(
      e.evaluate(r, AutomationSnapshot(now: DateTime(2026, 11, 8, 12))),
      isEmpty,
    );
    expect(
      e.evaluate(r, AutomationSnapshot(now: DateTime(2026, 11, 8, 12, 1))),
      hasLength(1),
    );
    expect(
      e.evaluate(r, AutomationSnapshot(now: DateTime(2026, 11, 8, 12, 1, 30))),
      isEmpty,
    );
  });

  AutomationSnapshot at(double lat, Duration after) =>
      AutomationSnapshot(now: _t0.add(after), latitude: lat, longitude: -74);

  test('entering and leaving an area', () {
    final e = AutomationEngine();
    final enter = [_rule('in', AutomationTrigger.enterArea)];
    final leave = [_rule('out', AutomationTrigger.leaveArea)];
    expect(e.evaluate(enter, at(41, Duration.zero)), isEmpty);
    expect(e.evaluate(enter, at(40, const Duration(minutes: 1))), hasLength(1));
    expect(e.evaluate(leave, at(40, const Duration(minutes: 1))), isEmpty);
    expect(e.evaluate(leave, at(41, const Duration(minutes: 2))), hasLength(1));
  });

  AutomationSnapshot node(DateTime seen, Duration after) =>
      AutomationSnapshot(now: _t0.add(after), nodeLastSeen: {'n': seen});

  test('a node going quiet and being heard again', () {
    final e = AutomationEngine();
    final quiet = [_rule('q', AutomationTrigger.nodeQuiet)];
    final heard = [_rule('h', AutomationTrigger.nodeHeard)];
    expect(e.evaluate(quiet, node(_t0, Duration.zero)), isEmpty);
    expect(
      e.evaluate(quiet, node(_t0, const Duration(minutes: 31))),
      hasLength(1),
    );
    expect(e.evaluate(heard, node(_t0, const Duration(minutes: 31))), isEmpty);
    final back = _t0.add(const Duration(minutes: 40));
    expect(
      e.evaluate(heard, node(back, const Duration(minutes: 41))),
      hasLength(1),
    );
  });

  test('rules survive a save and load', () {
    final rule = _rule('j', AutomationTrigger.leaveArea);
    final back = AutomationRule.fromJson(rule.toJson());
    expect(back.conditions.single.trigger, AutomationTrigger.leaveArea);
    expect(back.conditions.single.latitude, 40);
    expect(back.enabled, isTrue);
  });
}
