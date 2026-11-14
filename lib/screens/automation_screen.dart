import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../connector/meshcore_connector.dart';
import '../connector/meshcore_protocol.dart';
import '../l10n/app_localizations.dart';
import '../l10n/l10n.dart';
import '../models/automation_rule.dart';
import '../services/automation_service.dart';

String _triggerLabel(AppLocalizations l10n, AutomationTrigger trigger) =>
    switch (trigger) {
      AutomationTrigger.batteryBelow => l10n.auto_trigBattery,
      AutomationTrigger.atTime => l10n.auto_trigTime,
      AutomationTrigger.enterArea => l10n.auto_trigEnter,
      AutomationTrigger.leaveArea => l10n.auto_trigLeave,
      AutomationTrigger.nodeHeard => l10n.auto_trigHeard,
      AutomationTrigger.nodeQuiet => l10n.auto_trigQuiet,
      AutomationTrigger.messageReceived => l10n.auto_trigMessage,
    };

String _actionLabel(AppLocalizations l10n, AutomationAction action) =>
    switch (action) {
      AutomationAction.notify => l10n.auto_notify,
      AutomationAction.send => l10n.auto_send,
      AutomationAction.joinChannel => l10n.auto_actJoin,
      AutomationAction.playSound => l10n.auto_actSound,
      AutomationAction.webhook => l10n.auto_actWebhook,
    };

String _outcomeLabel(AppLocalizations l10n, AutomationOutcome o) => switch (o) {
  AutomationOutcome.done => l10n.auto_outDone,
  AutomationOutcome.notConnected => l10n.auto_outNotConnected,
  AutomationOutcome.noTarget => l10n.auto_outNoTarget,
  AutomationOutcome.webOff => l10n.auto_outWebOff,
  AutomationOutcome.webFailed => l10n.auto_outWebFailed,
  AutomationOutcome.noFreeSlot => l10n.auto_outNoSlot,
  AutomationOutcome.failed => l10n.auto_outFailed,
};

String _clock(BuildContext context, int minuteOfDay) => TimeOfDay(
  hour: minuteOfDay ~/ 60,
  minute: minuteOfDay % 60,
).format(context);

/// The detail line under a condition.
String _conditionDetail(
  BuildContext context,
  AutomationCondition c,
  MeshCoreConnector radio,
) {
  final l10n = context.l10n;
  String nodeName(String? key) =>
      radio.getContactByPubKeyHex(key ?? '')?.name ?? l10n.auto_anyone;
  return switch (c.trigger) {
    AutomationTrigger.batteryBelow => l10n.auto_below(c.batteryPercent),
    AutomationTrigger.atTime => _clock(context, c.minuteOfDay),
    AutomationTrigger.enterArea ||
    AutomationTrigger.leaveArea => l10n.auto_radius(c.radiusMeters),
    AutomationTrigger.nodeHeard ||
    AutomationTrigger.nodeQuiet => nodeName(c.nodeKey),
    AutomationTrigger.messageReceived =>
      c.contains.trim().isEmpty
          ? nodeName(c.nodeKey)
          : '${nodeName(c.nodeKey)} · “${c.contains.trim()}”',
  };
}

/// Lists automation rules and turns them on or off.
class AutomationScreen extends StatelessWidget {
  const AutomationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final service = context.watch<AutomationService>();
    final rules = service.rules;
    final runs = service.runs;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.auto_title)),
      floatingActionButton: FloatingActionButton(
        tooltip: l10n.auto_add,
        onPressed: () => _edit(context, null),
        child: const Icon(Icons.add),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 88),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(l10n.auto_intro),
          ),
          SwitchListTile(
            key: const ValueKey('auto-web-switch'),
            secondary: const Icon(Icons.public),
            title: Text(l10n.auto_webSwitch),
            subtitle: Text(l10n.auto_webSwitchSub),
            value: service.webhooksAllowed,
            onChanged: (on) => unawaited(service.setWebhooksAllowed(on)),
          ),
          const Divider(),
          for (final rule in rules)
            SwitchListTile(
              title: Text(rule.name),
              subtitle: Text(
                [
                  rule.conditions
                      .map((c) => _triggerLabel(l10n, c.trigger))
                      .join(
                        rule.combine == AutomationCombine.all
                            ? l10n.auto_andJoin
                            : l10n.auto_orJoin,
                      ),
                  if (rule.needsInternet) l10n.auto_needsInternet,
                ].join(' · '),
              ),
              value: rule.enabled,
              onChanged: (on) =>
                  unawaited(service.save(rule.copyWith(enabled: on))),
              secondary: IconButton(
                tooltip: l10n.auto_edit(rule.name),
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => _edit(context, rule),
              ),
            ),
          if (runs.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Text(
                l10n.auto_recent,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            for (final run in runs)
              ListTile(
                dense: true,
                leading: Icon(
                  run.ok ? Icons.check_circle_outline : Icons.error_outline,
                  semanticLabel: run.ok
                      ? l10n.auto_outDone
                      : l10n.auto_outFailed,
                ),
                title: Text(
                  '${TimeOfDay.fromDateTime(run.at).format(context)} · '
                  '${run.rule}',
                ),
                subtitle: Text(
                  '${_actionLabel(l10n, run.action)}: '
                  '${_outcomeLabel(l10n, run.outcome)}',
                ),
              ),
          ],
        ],
      ),
    );
  }

  void _edit(BuildContext context, AutomationRule? rule) {
    unawaited(
      Navigator.of(
        context,
      ).push(MaterialPageRoute<void>(builder: (_) => _RuleEditor(rule: rule))),
    );
  }
}

class _RuleEditor extends StatefulWidget {
  const _RuleEditor({this.rule});
  final AutomationRule? rule;

  @override
  State<_RuleEditor> createState() => _RuleEditorState();
}

class _RuleEditorState extends State<_RuleEditor> {
  late final _name = TextEditingController(text: widget.rule?.name ?? '');
  late var _combine = widget.rule?.combine ?? AutomationCombine.any;
  late final _conditions = [...?widget.rule?.conditions];
  late final _steps = [...?widget.rule?.steps];

  String? get _problem {
    final l10n = context.l10n;
    if (_name.text.trim().isEmpty) return l10n.auto_needName;
    if (_conditions.isEmpty) return l10n.auto_needCondition;
    if (_steps.isEmpty) return l10n.auto_needAction;
    return null;
  }

  Future<void> _save() async {
    final old = widget.rule;
    final service = context.read<AutomationService>();
    final navigator = Navigator.of(context);
    await service.save(
      AutomationRule(
        id: old?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
        name: _name.text.trim(),
        enabled: old?.enabled ?? false,
        combine: _combine,
        conditions: List.of(_conditions),
        steps: List.of(_steps),
      ),
    );
    navigator.pop();
  }

  Future<void> _delete() async {
    final service = context.read<AutomationService>();
    final navigator = Navigator.of(context);
    await service.delete(widget.rule!.id);
    navigator.pop();
  }

  Future<void> _editCondition(int? index) async {
    final result = await Navigator.of(context).push<AutomationCondition>(
      MaterialPageRoute(
        builder: (_) => _ConditionEditor(
          condition: index == null ? null : _conditions[index],
        ),
      ),
    );
    if (result == null || !mounted) return;
    setState(() {
      if (index == null) {
        _conditions.add(result);
      } else {
        _conditions[index] = result;
      }
    });
  }

  Future<void> _editStep(int? index) async {
    final result = await Navigator.of(context).push<AutomationStep>(
      MaterialPageRoute(
        builder: (_) => _StepEditor(step: index == null ? null : _steps[index]),
      ),
    );
    if (result == null || !mounted) return;
    setState(() {
      if (index == null) {
        _steps.add(result);
      } else {
        _steps[index] = result;
      }
    });
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Widget _heading(String text) => Padding(
    padding: const EdgeInsets.only(top: 16, bottom: 4),
    child: Text(text, style: Theme.of(context).textTheme.titleSmall),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final radio = context.watch<MeshCoreConnector>();
    final problem = _problem;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.rule == null ? l10n.auto_new : l10n.auto_editTitle),
        actions: [
          if (widget.rule != null)
            IconButton(
              tooltip: l10n.auto_delete,
              icon: const Icon(Icons.delete_outline),
              onPressed: _delete,
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _name,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(labelText: l10n.auto_name),
          ),
          _heading(l10n.auto_conditions),
          for (var i = 0; i < _conditions.length; i++)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(_triggerLabel(l10n, _conditions[i].trigger)),
              subtitle: Text(_conditionDetail(context, _conditions[i], radio)),
              onTap: () => _editCondition(i),
              trailing: IconButton(
                tooltip: l10n.auto_remove(
                  _triggerLabel(l10n, _conditions[i].trigger),
                ),
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: () => setState(() => _conditions.removeAt(i)),
              ),
            ),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton.icon(
              icon: const Icon(Icons.add),
              label: Text(l10n.auto_addCondition),
              onPressed: () => _editCondition(null),
            ),
          ),
          if (_conditions.length > 1) ...[
            _heading(l10n.auto_combine),
            SegmentedButton<AutomationCombine>(
              segments: [
                ButtonSegment(
                  value: AutomationCombine.any,
                  label: Text(l10n.auto_combineAny),
                ),
                ButtonSegment(
                  value: AutomationCombine.all,
                  label: Text(l10n.auto_combineAll),
                ),
              ],
              selected: {_combine},
              onSelectionChanged: (s) => setState(() => _combine = s.first),
            ),
            const SizedBox(height: 4),
            Text(
              _combine == AutomationCombine.any
                  ? l10n.auto_combineAnyHint
                  : l10n.auto_combineAllHint,
            ),
          ],
          _heading(l10n.auto_actions),
          for (var i = 0; i < _steps.length; i++)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(_actionLabel(l10n, _steps[i].action)),
              subtitle: Text(
                [
                  if (_steps[i].action == AutomationAction.webhook)
                    _steps[i].target ?? ''
                  else
                    _steps[i].text,
                  if (_steps[i].needsInternet) l10n.auto_needsInternet,
                ].where((s) => s.isNotEmpty).join(' · '),
              ),
              onTap: () => _editStep(i),
              trailing: IconButton(
                tooltip: l10n.auto_remove(_actionLabel(l10n, _steps[i].action)),
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: () => setState(() => _steps.removeAt(i)),
              ),
            ),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton.icon(
              icon: const Icon(Icons.add),
              label: Text(l10n.auto_addAction),
              onPressed: () => _editStep(null),
            ),
          ),
          if (problem != null) ...[const SizedBox(height: 8), Text(problem)],
          const SizedBox(height: 8),
          FilledButton(
            onPressed: problem == null ? _save : null,
            child: Text(l10n.auto_save),
          ),
        ],
      ),
    );
  }
}

class _ConditionEditor extends StatefulWidget {
  const _ConditionEditor({this.condition});
  final AutomationCondition? condition;

  @override
  State<_ConditionEditor> createState() => _ConditionEditorState();
}

class _ConditionEditorState extends State<_ConditionEditor> {
  late final _lat = TextEditingController(
    text: widget.condition?.latitude?.toString() ?? '',
  );
  late final _lon = TextEditingController(
    text: widget.condition?.longitude?.toString() ?? '',
  );
  late final _contains = TextEditingController(
    text: widget.condition?.contains ?? '',
  );
  late var _trigger =
      widget.condition?.trigger ?? AutomationTrigger.batteryBelow;
  late var _battery = widget.condition?.batteryPercent ?? 20;
  late var _minute = widget.condition?.minuteOfDay ?? 480;
  late var _radius = widget.condition?.radiusMeters ?? 500;
  late var _nodeMinutes = widget.condition?.nodeMinutes ?? 30;
  late String? _node = widget.condition?.nodeKey;

  bool get _isArea =>
      _trigger == AutomationTrigger.enterArea ||
      _trigger == AutomationTrigger.leaveArea;
  bool get _isNode =>
      _trigger == AutomationTrigger.nodeHeard ||
      _trigger == AutomationTrigger.nodeQuiet;

  String? get _problem {
    if (_isArea &&
        (double.tryParse(_lat.text) == null ||
            double.tryParse(_lon.text) == null)) {
      return context.l10n.auto_needArea;
    }
    if (_isNode && _node == null) return context.l10n.auto_needNode;
    return null;
  }

  void _done() => Navigator.of(context).pop(
    AutomationCondition(
      trigger: _trigger,
      batteryPercent: _battery,
      minuteOfDay: _minute,
      latitude: double.tryParse(_lat.text),
      longitude: double.tryParse(_lon.text),
      radiusMeters: _radius,
      nodeKey: _isNode || _trigger == AutomationTrigger.messageReceived
          ? _node
          : null,
      nodeMinutes: _nodeMinutes,
      contains: _trigger == AutomationTrigger.messageReceived
          ? _contains.text.trim()
          : '',
    ),
  );

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _minute ~/ 60, minute: _minute % 60),
    );
    if (picked != null) {
      setState(() => _minute = picked.hour * 60 + picked.minute);
    }
  }

  @override
  void dispose() {
    _lat.dispose();
    _lon.dispose();
    _contains.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final radio = context.watch<MeshCoreConnector>();
    final allNodes = [...radio.contacts]
      ..sort((a, b) => a.name.compareTo(b.name));
    final chatNodes = allNodes.where((c) => c.type == advTypeChat).toList();
    final problem = _problem;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.auto_editCondition)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<AutomationTrigger>(
            key: const ValueKey('auto-trigger'),
            initialValue: _trigger,
            isExpanded: true,
            decoration: InputDecoration(labelText: l10n.auto_when),
            items: [
              for (final t in AutomationTrigger.values)
                DropdownMenuItem(value: t, child: Text(_triggerLabel(l10n, t))),
            ],
            onChanged: (v) => setState(() => _trigger = v!),
          ),
          if (_trigger == AutomationTrigger.batteryBelow) ...[
            Text(l10n.auto_below(_battery)),
            Slider(
              value: _battery.toDouble(),
              min: 5,
              max: 80,
              divisions: 15,
              label: '$_battery%',
              semanticFormatterCallback: (_) => l10n.auto_below(_battery),
              onChanged: (v) => setState(() => _battery = v.round()),
            ),
          ],
          if (_trigger == AutomationTrigger.atTime)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.auto_time),
              trailing: Text(_clock(context, _minute)),
              onTap: _pickTime,
            ),
          if (_isArea) ...[
            TextField(
              controller: _lat,
              onChanged: (_) => setState(() {}),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
              decoration: InputDecoration(labelText: l10n.auto_latitude),
            ),
            TextField(
              controller: _lon,
              onChanged: (_) => setState(() {}),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
              decoration: InputDecoration(labelText: l10n.auto_longitude),
            ),
            if (radio.selfLatitude != null && radio.selfLongitude != null)
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton(
                  onPressed: () => setState(() {
                    _lat.text = radio.selfLatitude!.toStringAsFixed(5);
                    _lon.text = radio.selfLongitude!.toStringAsFixed(5);
                  }),
                  child: Text(l10n.auto_usePosition),
                ),
              ),
            Text(l10n.auto_radius(_radius)),
            Slider(
              value: _radius.toDouble(),
              min: 100,
              max: 5000,
              divisions: 49,
              label: '$_radius m',
              semanticFormatterCallback: (_) => l10n.auto_radius(_radius),
              onChanged: (v) => setState(() => _radius = v.round()),
            ),
          ],
          if (_isNode) ...[
            DropdownButtonFormField<String>(
              initialValue: allNodes.any((c) => c.publicKeyHex == _node)
                  ? _node
                  : null,
              isExpanded: true,
              decoration: InputDecoration(labelText: l10n.auto_node),
              items: [
                for (final c in allNodes)
                  DropdownMenuItem(
                    value: c.publicKeyHex,
                    child: Text(c.name, overflow: TextOverflow.ellipsis),
                  ),
              ],
              onChanged: (v) => setState(() => _node = v),
            ),
            Text(l10n.auto_heardWithin(_nodeMinutes)),
            Slider(
              value: _nodeMinutes.toDouble(),
              min: 10,
              max: 240,
              divisions: 23,
              label: '$_nodeMinutes min',
              semanticFormatterCallback: (_) =>
                  l10n.auto_heardWithin(_nodeMinutes),
              onChanged: (v) => setState(() => _nodeMinutes = v.round()),
            ),
          ],
          if (_trigger == AutomationTrigger.messageReceived) ...[
            TextField(
              key: const ValueKey('auto-contains'),
              controller: _contains,
              decoration: InputDecoration(labelText: l10n.auto_contains),
            ),
            DropdownButtonFormField<String?>(
              initialValue: chatNodes.any((c) => c.publicKeyHex == _node)
                  ? _node
                  : null,
              isExpanded: true,
              decoration: InputDecoration(labelText: l10n.auto_from),
              items: [
                DropdownMenuItem<String?>(child: Text(l10n.auto_anyone)),
                for (final c in chatNodes)
                  DropdownMenuItem<String?>(
                    value: c.publicKeyHex,
                    child: Text(c.name, overflow: TextOverflow.ellipsis),
                  ),
              ],
              onChanged: (v) => setState(() => _node = v),
            ),
          ],
          if (problem != null) ...[const SizedBox(height: 8), Text(problem)],
          const SizedBox(height: 12),
          FilledButton(
            onPressed: problem == null ? _done : null,
            child: Text(l10n.auto_done),
          ),
        ],
      ),
    );
  }
}

class _StepEditor extends StatefulWidget {
  const _StepEditor({this.step});
  final AutomationStep? step;

  @override
  State<_StepEditor> createState() => _StepEditorState();
}

class _StepEditorState extends State<_StepEditor> {
  late var _action = widget.step?.action ?? AutomationAction.notify;
  late final _text = TextEditingController(text: widget.step?.text ?? '');
  late final _url = TextEditingController(
    text: widget.step?.action == AutomationAction.webhook
        ? widget.step?.target ?? ''
        : '',
  );
  late String? _target = widget.step?.action == AutomationAction.send
      ? widget.step?.target
      : null;

  String? get _problem {
    final l10n = context.l10n;
    switch (_action) {
      case AutomationAction.notify:
        return _text.text.trim().isEmpty ? l10n.auto_needMessage : null;
      case AutomationAction.send:
        if (_target == null) return l10n.auto_needTarget;
        return _text.text.trim().isEmpty ? l10n.auto_needMessage : null;
      case AutomationAction.joinChannel:
        return _text.text.trim().replaceFirst('#', '').isEmpty
            ? l10n.auto_needChannel
            : null;
      case AutomationAction.playSound:
        return null;
      case AutomationAction.webhook:
        final url = Uri.tryParse(_url.text.trim());
        return url != null &&
                (url.isScheme('https') || url.isScheme('http')) &&
                url.host.isNotEmpty
            ? null
            : l10n.auto_needUrl;
    }
  }

  void _done() => Navigator.of(context).pop(
    AutomationStep(
      action: _action,
      target: switch (_action) {
        AutomationAction.send => _target,
        AutomationAction.webhook => _url.text.trim(),
        _ => null,
      },
      text: _action == AutomationAction.playSound ? '' : _text.text.trim(),
    ),
  );

  @override
  void dispose() {
    _text.dispose();
    _url.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final radio = context.watch<MeshCoreConnector>();
    final contacts = radio.contacts.where((c) => c.type == advTypeChat).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    final targets = <String, String>{
      for (final ch in radio.channels)
        if (ch.name.isNotEmpty) 'channel:${ch.index}': ch.name,
      for (final c in contacts) 'message:${c.publicKeyHex}': c.name,
    };
    final problem = _problem;
    final usesText =
        _action == AutomationAction.notify ||
        _action == AutomationAction.send ||
        _action == AutomationAction.webhook;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.auto_editAction)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<AutomationAction>(
            key: const ValueKey('auto-action'),
            initialValue: _action,
            isExpanded: true,
            decoration: InputDecoration(labelText: l10n.auto_do),
            items: [
              for (final a in AutomationAction.values)
                DropdownMenuItem(value: a, child: Text(_actionLabel(l10n, a))),
            ],
            onChanged: (v) => setState(() => _action = v!),
          ),
          if (_action == AutomationAction.send)
            DropdownButtonFormField<String>(
              initialValue: targets.containsKey(_target) ? _target : null,
              isExpanded: true,
              decoration: InputDecoration(labelText: l10n.auto_sendTo),
              items: [
                for (final e in targets.entries)
                  DropdownMenuItem(
                    value: e.key,
                    child: Text(e.value, overflow: TextOverflow.ellipsis),
                  ),
              ],
              onChanged: (v) => setState(() => _target = v),
            ),
          if (_action == AutomationAction.webhook) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.public, size: 18),
                const SizedBox(width: 6),
                Expanded(child: Text(l10n.auto_webhookHint)),
              ],
            ),
            TextField(
              key: const ValueKey('auto-url'),
              controller: _url,
              onChanged: (_) => setState(() {}),
              keyboardType: TextInputType.url,
              decoration: InputDecoration(labelText: l10n.auto_webhookUrl),
            ),
          ],
          if (_action == AutomationAction.joinChannel)
            TextField(
              key: const ValueKey('auto-channel'),
              controller: _text,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(labelText: l10n.auto_channelName),
            ),
          if (usesText) ...[
            TextField(
              key: const ValueKey('auto-text'),
              controller: _text,
              onChanged: (_) => setState(() {}),
              maxLength: 120,
              decoration: InputDecoration(labelText: l10n.auto_message),
            ),
            Text(
              l10n.auto_placeholders('{rule} {time} {battery} {node} {text}'),
            ),
          ],
          if (problem != null) ...[const SizedBox(height: 8), Text(problem)],
          const SizedBox(height: 12),
          FilledButton(
            onPressed: problem == null ? _done : null,
            child: Text(l10n.auto_done),
          ),
        ],
      ),
    );
  }
}
