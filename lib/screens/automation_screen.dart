import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../connector/meshcore_connector.dart';
import '../connector/meshcore_protocol.dart';
import '../models/automation_rule.dart';
import '../services/automation_service.dart';

const _triggerLabels = {
  AutomationTrigger.batteryBelow: 'Radio battery drops below',
  AutomationTrigger.atTime: 'Every day at',
  AutomationTrigger.enterArea: 'I enter an area',
  AutomationTrigger.leaveArea: 'I leave an area',
  AutomationTrigger.nodeHeard: 'A node is heard again',
  AutomationTrigger.nodeQuiet: 'A node goes quiet',
};

/// Lists automation rules and turns them on or off.
class AutomationScreen extends StatelessWidget {
  const AutomationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.watch<AutomationService>();
    final rules = service.rules;
    return Scaffold(
      appBar: AppBar(title: const Text('Automation')),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add rule',
        onPressed: () => _edit(context, null),
        child: const Icon(Icons.add),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 88),
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Rules run only while the app is open. Each fires when its '
              'condition starts being true, at most once every 15 minutes. '
              'Rules that send messages are limited to 3 sends every 10 '
              'minutes in total, and are labelled as automated.',
            ),
          ),
          for (final rule in rules)
            SwitchListTile(
              title: Text(rule.name),
              subtitle: Text(_triggerLabels[rule.trigger]!),
              value: rule.enabled,
              onChanged: (on) =>
                  unawaited(service.save(rule.copyWith(enabled: on))),
              secondary: IconButton(
                tooltip: 'Edit ${rule.name}',
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
    if (_name.text.trim().isEmpty) return 'Give the rule a name.';
    if (_isArea &&
        (double.tryParse(_lat.text) == null ||
            double.tryParse(_lon.text) == null)) {
      return 'Enter the area\'s latitude and longitude.';
    }
    if (_isNode && _node == null) return 'Choose a node.';
    if (_text.text.trim().isEmpty) return 'Write the message.';
    if (_action == AutomationAction.send && _target == null) {
      return 'Choose who gets the message.';
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
        title: Text(widget.rule == null ? 'New rule' : 'Edit rule'),
        actions: [
          if (widget.rule != null)
            IconButton(
              tooltip: 'Delete rule',
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
            decoration: const InputDecoration(labelText: 'Rule name'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<AutomationTrigger>(
            initialValue: _trigger,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'When'),
            items: [
              for (final e in _triggerLabels.entries)
                DropdownMenuItem(value: e.key, child: Text(e.value)),
            ],
            onChanged: (v) => setState(() => _trigger = v!),
          ),
          if (_trigger == AutomationTrigger.batteryBelow) ...[
            Text('Below $_battery%'),
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
              title: const Text('Time'),
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
              decoration: const InputDecoration(labelText: 'Latitude'),
            ),
            TextField(
              controller: _lon,
              onChanged: (_) => setState(() {}),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
              decoration: const InputDecoration(labelText: 'Longitude'),
            ),
            if (radio.selfLatitude != null && radio.selfLongitude != null)
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton(
                  onPressed: () => setState(() {
                    _lat.text = radio.selfLatitude!.toStringAsFixed(5);
                    _lon.text = radio.selfLongitude!.toStringAsFixed(5);
                  }),
                  child: const Text('Use the radio\'s position'),
                ),
              ),
            Text('Radius: $_radius m'),
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
              decoration: const InputDecoration(labelText: 'Node'),
              items: [
                for (final c in allNodes)
                  DropdownMenuItem(
                    value: c.publicKeyHex,
                    child: Text(c.name, overflow: TextOverflow.ellipsis),
                  ),
              ],
              onChanged: (v) => setState(() => _node = v),
            ),
            Text('Counts as heard within $_nodeMinutes minutes'),
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
            segments: const [
              ButtonSegment(
                value: AutomationAction.notify,
                label: Text('Notify me'),
              ),
              ButtonSegment(
                value: AutomationAction.send,
                label: Text('Send a message'),
              ),
            ],
            selected: {_action},
            onSelectionChanged: (s) => setState(() => _action = s.first),
          ),
          if (_action == AutomationAction.send)
            DropdownButtonFormField<String>(
              initialValue: targets.containsKey(_target) ? _target : null,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Send to'),
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
            decoration: const InputDecoration(labelText: 'Message'),
          ),
          if (problem != null) Text(problem),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: problem == null ? _save : null,
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
