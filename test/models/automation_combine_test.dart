import 'package:flutter_test/flutter_test.dart';
import 'package:meshcore_open/models/automation_rule.dart';

final _t0 = DateTime(2026, 11, 13, 17, 59);

AutomationRule _rule(
  List<AutomationCondition> conditions, {
  AutomationCombine combine = AutomationCombine.any,
}) => AutomationRule(
  id: 'r',
  name: 'r',
  enabled: true,
  combine: combine,
  conditions: conditions,
  steps: const [AutomationStep(action: AutomationAction.notify, text: 'x')],
);

const _sixPm = AutomationCondition(
  trigger: AutomationTrigger.atTime,
  minuteOfDay: 18 * 60,
);
const _lowBattery = AutomationCondition(
  trigger: AutomationTrigger.batteryBelow,
  batteryPercent: 30,
);

AutomationSnapshot _snap(
  Duration after,
  int battery, {
  List<AutomationMessage> messages = const [],
}) => AutomationSnapshot(
  now: _t0.add(after),
  batteryPercent: battery,
  messages: messages,
);

void main() {
  test('AND runs when one condition happens and the others hold', () {
    final e = AutomationEngine();
    final r = [
      _rule([_sixPm, _lowBattery], combine: AutomationCombine.all),
    ];
    expect(e.evaluate(r, _snap(Duration.zero, 20)), isEmpty);
    expect(e.evaluate(r, _snap(const Duration(minutes: 1), 20)), hasLength(1));
  });

  test('AND stays quiet when another condition does not hold', () {
    final e = AutomationEngine();
    final r = [
      _rule([_sixPm, _lowBattery], combine: AutomationCombine.all),
    ];
    e.evaluate(r, _snap(Duration.zero, 80));
    expect(e.evaluate(r, _snap(const Duration(minutes: 1), 80)), isEmpty);
  });

  test('OR runs when any condition happens', () {
    final e = AutomationEngine();
    final r = [
      _rule([_sixPm, _lowBattery]),
    ];
    e.evaluate(r, _snap(Duration.zero, 80));
    expect(e.evaluate(r, _snap(const Duration(minutes: 1), 80)), hasLength(1));
  });

  test('a matching message fires and is passed along', () {
    final e = AutomationEngine();
    final r = [
      _rule(const [
        AutomationCondition(
          trigger: AutomationTrigger.messageReceived,
          contains: 'Status',
          nodeKey: 'aa',
        ),
      ]),
    ];
    expect(
      e.evaluate(
        r,
        _snap(
          Duration.zero,
          50,
          messages: const [AutomationMessage(text: 'status?', senderKey: 'bb')],
        ),
      ),
      isEmpty,
    );
    final fired = e.evaluate(
      r,
      _snap(
        Duration.zero,
        50,
        messages: const [
          AutomationMessage(text: 'hello', senderKey: 'aa'),
          AutomationMessage(
            text: 'STATUS please',
            senderKey: 'aa',
            senderName: 'Peak',
          ),
        ],
      ),
    );
    expect(fired.single.message?.senderName, 'Peak');
  });

  test('message AND battery needs both at once', () {
    final e = AutomationEngine();
    final r = [
      _rule(const [
        AutomationCondition(trigger: AutomationTrigger.messageReceived),
        _lowBattery,
      ], combine: AutomationCombine.all),
    ];
    const msg = [AutomationMessage(text: 'ping')];
    e.evaluate(r, _snap(Duration.zero, 80));
    expect(e.evaluate(r, _snap(Duration.zero, 80, messages: msg)), isEmpty);
    e.evaluate(r, _snap(const Duration(minutes: 1), 20));
    expect(
      e.evaluate(r, _snap(const Duration(minutes: 2), 20, messages: msg)),
      hasLength(1),
    );
  });

  test('rules saved by the earlier one-trigger form still load', () {
    final rule = AutomationRule.fromJson({
      'id': 'old',
      'name': 'Old',
      'trigger': 'batteryBelow',
      'enabled': true,
      'batteryPercent': 25,
      'action': 'send',
      'target': 'channel:1',
      'text': 'Low',
    });
    expect(rule.combine, AutomationCombine.any);
    expect(rule.conditions.single.batteryPercent, 25);
    expect(rule.steps.single.action, AutomationAction.send);
    expect(rule.steps.single.target, 'channel:1');
    final back = AutomationRule.fromJson(rule.toJson());
    expect(back.steps.single.text, 'Low');
  });

  test('placeholders are filled', () {
    expect(
      fillAutomationText(
        '{rule} {time} {battery} {node}: {text}',
        rule: 'R',
        time: '18:00',
        battery: 40,
        message: const AutomationMessage(text: 'hi', senderName: 'Peak'),
      ),
      'R 18:00 40% Peak: hi',
    );
  });
}
