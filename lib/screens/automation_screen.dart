import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../connector/meshcore_connector.dart';
import '../connector/meshcore_protocol.dart';
import '../l10n/l10n.dart';
import '../models/automation_rule.dart';
import '../services/automation_service.dart';

String _triggerLabel(BuildContext context, AutomationTrigger trigger) {
  final l10n = context.l10n;
  return switch (trigger) {
    AutomationTrigger.batteryBelow => l10n.auto_trigBattery,
    AutomationTrigger.atTime => l10n.auto_trigTime,
    AutomationTrigger.enterArea => l10n.auto_trigEnter,
    AutomationTrigger.leaveArea => l10n.auto_trigLeave,
    AutomationTrigger.nodeHeard => l10n.auto_trigHeard,
    AutomationTrigger.nodeQuiet => l10n.auto_trigQuiet,
  };
}

/// Lists automation rules and turns them on or off.
class AutomationScreen extends StatelessWidget {
  const AutomationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.watch<AutomationService>();
    final rules = service.rules;
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.auto_title)),
      floatingActionButton: FloatingActionButton(
        tooltip: context.l10n.auto_add,
        onPressed: () => _edit(context, null),
        child: const Icon(Icons.add),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 88),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(context.l10n.auto_intro),
          ),
          for (final rule in rules)
            SwitchListTile(
              title: Text(rule.name),
              subtitle: Text(_triggerLabel(context, rule.trigger)),
              value: rule.enabled,
              onChanged: (on) =>
                  unawaited(service.save(rule.copyWith(enabled: on))),
              secondary: IconButton(
                tooltip: context.l10n.auto_edit(rule.name),
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => _edit(context, rule),
              ),
            ),
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
  late final _text = TextEditingController(text: widget.rule?.text ?? '');
  late final _lat = TextEditingController(
    text: widget.rule?.latitude?.toString() ?? '',
  );
  late final _lon = TextEditingController(
    text: widget.rule?.longitude?.toString() ?? '',
  );
  late var _trigger = widget.rule?.trigger ?? AutomationTrigger.batteryBelow;
  late var _action = widget.rule?.action ?? AutomationAction.notify;
  late var _battery = widget.rule?.batteryPercent ?? 20;
  late var _minute = widget.rule?.minuteOfDay ?? 480;
  late var _radius = widget.rule?.radiusMeters ?? 500;
  late var _nodeMinutes = widget.rule?.nodeMinutes ?? 30;
  late String? _node = widget.rule?.nodeKey;
  late String? _target = widget.rule?.target;

  bool get _isArea =>
      _trigger == AutomationTrigger.enterArea ||
      _trigger == AutomationTrigger.leaveArea;
  bool get _isNode =>
      _trigger == AutomationTrigger.nodeHeard ||
      _trigger == AutomationTrigger.nodeQuiet;

  String? get _problem {
    if (_name.text.trim().isEmpty) return context.l10n.auto_needName;
    if (_isArea &&
        (double.tryParse(_lat.text) == null ||
            double.tryParse(_lon.text) == null)) {
      return context.l10n.auto_needArea;
    }
    if (_isNode && _node == null) return context.l10n.auto_needNode;
    if (_text.text.trim().isEmpty) return context.l10n.auto_needMessage;
    if (_action == AutomationAction.send && _target == null) {
      return context.l10n.auto_needTarget;
    }
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
        trigger: _trigger,
        enabled: old?.enabled ?? false,
        batteryPercent: _battery,
        minuteOfDay: _minute,
        latitude: double.tryParse(_lat.text),
        longitude: double.tryParse(_lon.text),
        radiusMeters: _radius,
        nodeKey: _node,
        nodeMinutes: _nodeMinutes,
        action: _action,
        target: _action == AutomationAction.send ? _target : null,
        text: _text.text.trim(),
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
    _name.dispose();
    _text.dispose();
    _lat.dispose();
    _lon.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final radio = context.watch<MeshCoreConnector>();
    final contacts = radio.contacts.where((c) => c.type == advTypeChat).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    final allNodes = [...radio.contacts]
      ..sort((a, b) => a.name.compareTo(b.name));
    final targets = <String, String>{
      for (final ch in radio.channels)
        if (ch.name.isNotEmpty) 'channel:${ch.index}': ch.name,
      for (final c in contacts) 'message:${c.publicKeyHex}': c.name,
    };
    final problem = _problem;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.rule == null
              ? context.l10n.auto_new
              : context.l10n.auto_editTitle,
        ),
        actions: [
          if (widget.rule != null)
            IconButton(
              tooltip: context.l10n.auto_delete,
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
            decoration: InputDecoration(labelText: context.l10n.auto_name),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<AutomationTrigger>(
            initialValue: _trigger,
            isExpanded: true,
            decoration: InputDecoration(labelText: context.l10n.auto_when),
            items: [
              for (final t in AutomationTrigger.values)
                DropdownMenuItem(
                  value: t,
                  child: Text(_triggerLabel(context, t)),
                ),
            ],
            onChanged: (v) => setState(() => _trigger = v!),
          ),
          if (_trigger == AutomationTrigger.batteryBelow) ...[
            Text(context.l10n.auto_below(_battery)),
            Slider(
              value: _battery.toDouble(),
              min: 5,
              max: 80,
              divisions: 15,
              label: '$_battery%',
              onChanged: (v) => setState(() => _battery = v.round()),
            ),
          ],
          if (_trigger == AutomationTrigger.atTime)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(context.l10n.auto_time),
              trailing: Text(
                TimeOfDay(
                  hour: _minute ~/ 60,
                  minute: _minute % 60,
                ).format(context),
              ),
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
              decoration: InputDecoration(
                labelText: context.l10n.auto_latitude,
              ),
            ),
            TextField(
              controller: _lon,
              onChanged: (_) => setState(() {}),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
              decoration: InputDecoration(
                labelText: context.l10n.auto_longitude,
              ),
            ),
            if (radio.selfLatitude != null && radio.selfLongitude != null)
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton(
                  onPressed: () => setState(() {
                    _lat.text = radio.selfLatitude!.toStringAsFixed(5);
                    _lon.text = radio.selfLongitude!.toStringAsFixed(5);
                  }),
                  child: Text(context.l10n.auto_usePosition),
                ),
              ),
            Text(context.l10n.auto_radius(_radius)),
            Slider(
              value: _radius.toDouble(),
              min: 100,
              max: 5000,
              divisions: 49,
              label: '$_radius m',
              onChanged: (v) => setState(() => _radius = v.round()),
            ),
          ],
          if (_isNode) ...[
            DropdownButtonFormField<String>(
              initialValue: allNodes.any((c) => c.publicKeyHex == _node)
                  ? _node
                  : null,
              isExpanded: true,
              decoration: InputDecoration(labelText: context.l10n.auto_node),
              items: [
                for (final c in allNodes)
                  DropdownMenuItem(
                    value: c.publicKeyHex,
                    child: Text(c.name, overflow: TextOverflow.ellipsis),
                  ),
              ],
              onChanged: (v) => setState(() => _node = v),
            ),
            Text(context.l10n.auto_heardWithin(_nodeMinutes)),
            Slider(
              value: _nodeMinutes.toDouble(),
              min: 10,
              max: 240,
              divisions: 23,
              label: '$_nodeMinutes min',
              onChanged: (v) => setState(() => _nodeMinutes = v.round()),
            ),
          ],
          const SizedBox(height: 12),
          SegmentedButton<AutomationAction>(
            segments: [
              ButtonSegment(
                value: AutomationAction.notify,
                label: Text(context.l10n.auto_notify),
              ),
              ButtonSegment(
                value: AutomationAction.send,
                label: Text(context.l10n.auto_send),
              ),
            ],
            selected: {_action},
            onSelectionChanged: (s) => setState(() => _action = s.first),
          ),
          if (_action == AutomationAction.send)
            DropdownButtonFormField<String>(
              initialValue: targets.containsKey(_target) ? _target : null,
              isExpanded: true,
              decoration: InputDecoration(labelText: context.l10n.auto_sendTo),
              items: [
                for (final e in targets.entries)
                  DropdownMenuItem(
                    value: e.key,
                    child: Text(e.value, overflow: TextOverflow.ellipsis),
                  ),
              ],
              onChanged: (v) => setState(() => _target = v),
            ),
          const SizedBox(height: 12),
          TextField(
            controller: _text,
            onChanged: (_) => setState(() {}),
            maxLength: 120,
            decoration: InputDecoration(labelText: context.l10n.auto_message),
          ),
          if (problem != null) Text(problem),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: problem == null ? _save : null,
            child: Text(context.l10n.auto_save),
          ),
        ],
      ),
    );
  }
}
