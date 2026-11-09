import 'package:flutter/material.dart';

import 'automation_screen.dart';
import 'package:provider/provider.dart';

import '../connector/meshcore_connector.dart';
import '../connector/meshcore_protocol.dart';
import '../l10n/app_localizations.dart';
import '../l10n/l10n.dart';
import '../models/bot_settings.dart';
import '../services/bot_service.dart';
import '../services/weather_service.dart';
import '../widgets/ember_backdrop.dart';

/// What the newer commands do, shown under their switches.
String? _commandHint(AppLocalizations t, String command) => switch (command) {
  '!sun' => t.botCmd_sun,
  '!moon' => t.botCmd_moon,
  '!weather' => t.botCmd_weather,
  '!dice' => t.botCmd_dice,
  '!trace' => t.botCmd_trace,
  _ => null,
};

String _weatherProblem(AppLocalizations t, WeatherService w) =>
    switch (w.problem!) {
      WeatherAlertProblem.noPosition => t.botWx_noPosition,
      WeatherAlertProblem.noChannel => t.botWx_noChannel,
      WeatherAlertProblem.channelGone => t.botWx_channelGone,
      WeatherAlertProblem.rejected => t.botWx_httpError('${w.problemCode}'),
      WeatherAlertProblem.unreachable => t.botWx_unreachable,
    };

class BotSettingsScreen extends StatelessWidget {
  const BotSettingsScreen({super.key});

  Future<void> _save(BuildContext context, BotSettings settings) async {
    try {
      await context.read<BotService>().save(settings);
    } on ArgumentError catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message.toString())));
      }
    }
  }

  Future<void> _editText(
    BuildContext context,
    String title,
    String value,
    BotSettings Function(String) update,
  ) async {
    final controller = TextEditingController(text: value);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: InputDecoration(
            helperText: context.l10n.botUi_replyHint,
            helperMaxLines: 3,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.common_cancel),
          ),
          FilledButton(
            onPressed: () {
              if (isValidBotResponse(controller.text)) {
                Navigator.pop(context, controller.text.trim());
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(context.l10n.botUi_shorterReply)),
                );
              }
            },
            child: Text(context.l10n.common_save),
          ),
        ],
      ),
    );
    // The route's closing animation may still reference the controller.
    await Future<void>.delayed(const Duration(milliseconds: 300));
    controller.dispose();
    if (result != null && context.mounted) {
      await _save(context, update(result));
    }
  }

  Future<void> _editRule(BuildContext context, {int? index}) async {
    final service = context.read<BotService>();
    final rule = index == null ? null : service.settings.rules[index];
    final trigger = TextEditingController(text: rule?.trigger);
    final response = TextEditingController(text: rule?.response);
    var contains = rule?.contains ?? false;
    var senderKey = rule?.senderKey;
    final contacts = context
        .read<MeshCoreConnector>()
        .contacts
        .where((c) => c.type == advTypeChat)
        .toList();
    if (senderKey != null &&
        !contacts.any((c) => c.publicKeyHex == senderKey)) {
      contacts.addAll(
        context.read<MeshCoreConnector>().allContacts.where(
          (c) => c.publicKeyHex == senderKey,
        ),
      );
    }
    final result = await showDialog<BotRule>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            index == null
                ? context.l10n.botUi_addRule
                : context.l10n.botUi_editRule,
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: trigger,
                  decoration: InputDecoration(
                    labelText: context.l10n.botUi_trigger,
                    hintText: '!club',
                  ),
                ),
                TextField(
                  controller: response,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: context.l10n.botUi_reply,
                  ),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(context.l10n.botUi_matchAnywhere),
                  subtitle: Text(context.l10n.botUi_matchHint),
                  value: contains,
                  onChanged: (value) => setState(() => contains = value),
                ),
                DropdownButtonFormField<String>(
                  initialValue: senderKey,
                  decoration: InputDecoration(
                    labelText: context.l10n.botUi_from,
                  ),
                  items: [
                    DropdownMenuItem<String>(
                      value: null,
                      child: Text(context.l10n.botUi_anyContact),
                    ),
                    if (senderKey != null &&
                        !contacts.any((c) => c.publicKeyHex == senderKey))
                      DropdownMenuItem(
                        value: senderKey,
                        child: Text(context.l10n.botUi_prevContact),
                      ),
                    for (final contact in contacts)
                      DropdownMenuItem(
                        value: contact.publicKeyHex,
                        child: Text(contact.name),
                      ),
                  ],
                  onChanged: (value) => setState(() => senderKey = value),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Text(context.l10n.botUi_priority),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.l10n.common_cancel),
            ),
            FilledButton(
              onPressed: () {
                if (trigger.text.trim().isEmpty ||
                    !isValidBotResponse(response.text)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(context.l10n.botUi_needTrigger)),
                  );
                  return;
                }
                Navigator.pop(
                  context,
                  BotRule(
                    trigger: trigger.text.trim(),
                    response: response.text.trim(),
                    contains: contains,
                    senderKey: senderKey,
                    enabled: rule?.enabled ?? true,
                  ),
                );
              },
              child: Text(context.l10n.common_save),
            ),
          ],
        ),
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 300));
    trigger.dispose();
    response.dispose();
    if (result != null && context.mounted) {
      final rules = [...service.settings.rules];
      if (index == null) {
        rules.add(result);
      } else {
        rules[index] = result;
      }
      await _save(context, service.settings.copyWith(rules: rules));
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) => Consumer2<BotService, MeshCoreConnector>(
    builder: (context, service, connector, _) {
      final settings = service.settings;
      return EmberBackdrop(
        scene: EmberScene.more,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            scrolledUnderElevation: 0,
            title: Text(context.l10n.botUi_title),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SwitchListTile(
                title: Text(context.l10n.botUi_mode),
                subtitle: Text(
                  !service.ready
                      ? context.l10n.botUi_loading
                      : !settings.enabled
                      ? context.l10n.botUi_off
                      : connector.isConnected
                      ? settings.channels.isEmpty
                            ? context.l10n.botUi_onDm
                            : context.l10n.botUi_onDmChannels(
                                settings.channels.length,
                              )
                      : context.l10n.botUi_onWaiting,
                ),
                value: settings.enabled,
                onChanged: service.ready
                    ? (value) =>
                          _save(context, settings.copyWith(enabled: value))
                    : null,
              ),
              Text(context.l10n.botUi_intro),
              if (service.error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    service.error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: Text(context.l10n.botUi_away),
                value: settings.awayEnabled,
                onChanged: (value) =>
                    _save(context, settings.copyWith(awayEnabled: value)),
              ),
              ListTile(
                title: Text(context.l10n.botUi_awayReply),
                subtitle: Text(settings.awayMessage),
                onTap: () => _editText(
                  context,
                  context.l10n.botUi_awayReply,
                  settings.awayMessage,
                  (v) => service.settings.copyWith(awayMessage: v),
                ),
              ),
              ListTile(
                title: Text(context.l10n.botUi_info),
                subtitle: Text(settings.info),
                onTap: () => _editText(
                  context,
                  context.l10n.botUi_infoReply,
                  settings.info,
                  (v) => service.settings.copyWith(info: v),
                ),
              ),
              ListTile(
                title: Text(context.l10n.botUi_checkIn),
                subtitle: Text(settings.checkIn),
                onTap: () => _editText(
                  context,
                  context.l10n.botUi_checkIn,
                  settings.checkIn,
                  (v) => service.settings.copyWith(checkIn: v),
                ),
              ),
              const Divider(),
              Text(
                context.l10n.botChannels_title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 4),
                child: Text(context.l10n.botChannels_hint),
              ),
              if (connector.channels.where((c) => !c.isEmpty).isEmpty)
                ListTile(title: Text(context.l10n.botChannels_none)),
              for (final channel in connector.channels.where((c) => !c.isEmpty))
                SwitchListTile(
                  key: ValueKey('bot-channel-${channel.index}'),
                  title: Text(channel.name),
                  value: settings.channels.contains(botChannelId(channel.psk)),
                  onChanged: (value) {
                    final id = botChannelId(channel.psk);
                    final channels = {...settings.channels};
                    if (value) {
                      channels.add(id);
                    } else {
                      channels.remove(id);
                    }
                    _save(context, settings.copyWith(channels: channels));
                  },
                ),
              const Divider(),
              Text(
                context.l10n.botUi_commands,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              for (final command in botCommands)
                SwitchListTile(
                  title: Text(command),
                  subtitle: _commandHint(context.l10n, command) == null
                      ? null
                      : Text(_commandHint(context.l10n, command)!),
                  value: settings.commands.contains(command),
                  onChanged: (value) {
                    final commands = {...settings.commands};
                    if (value) {
                      commands.add(command);
                    } else {
                      commands.remove(command);
                    }
                    _save(context, settings.copyWith(commands: commands));
                  },
                ),
              SwitchListTile(
                title: Text(context.l10n.botUi_allowWhere),
                subtitle: Text(context.l10n.botUi_whereHint),
                value: settings.shareLocation,
                onChanged: (value) =>
                    _save(context, settings.copyWith(shareLocation: value)),
              ),
              const Divider(),
              const _WeatherAlertsSection(),
              const Divider(),
              ListTile(
                title: Text(context.l10n.botUi_custom),
                trailing: const Icon(Icons.add),
                onTap: () => _editRule(context),
              ),
              for (var i = 0; i < settings.rules.length; i++)
                ListTile(
                  title: Text(settings.rules[i].trigger),
                  subtitle: Text(settings.rules[i].response),
                  onTap: () => _editRule(context, index: i),
                  leading: Switch(
                    value: settings.rules[i].enabled,
                    onChanged: (value) {
                      final rules = [...settings.rules];
                      final rule = rules[i];
                      rules[i] = BotRule(
                        trigger: rule.trigger,
                        response: rule.response,
                        enabled: value,
                        contains: rule.contains,
                        senderKey: rule.senderKey,
                      );
                      _save(context, settings.copyWith(rules: rules));
                    },
                  ),
                  trailing: IconButton(
                    tooltip: context.l10n.auto_delete,
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () {
                      final rules = [...settings.rules]..removeAt(i);
                      _save(context, settings.copyWith(rules: rules));
                    },
                  ),
                ),
              const Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.bolt_outlined),
                title: Text(context.l10n.auto_entry),
                subtitle: Text(context.l10n.auto_entrySub),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const AutomationScreen(),
                  ),
                ),
              ),
              const Divider(),
              Text(
                context.l10n.botUi_airtime,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              DropdownButtonFormField<int>(
                initialValue: settings.cooldownSeconds,
                decoration: InputDecoration(
                  labelText: context.l10n.botUi_cooldown,
                ),
                items: {60, 300, 600, 1800, 3600, settings.cooldownSeconds}
                    .map(
                      (seconds) => DropdownMenuItem(
                        value: seconds,
                        child: Text(context.l10n.botUi_minutes(seconds ~/ 60)),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    _save(context, settings.copyWith(cooldownSeconds: value));
                  }
                },
              ),
              DropdownButtonFormField<int>(
                initialValue: settings.repliesPerMinute,
                decoration: InputDecoration(
                  labelText: context.l10n.botUi_maxReplies,
                ),
                items: List.generate(
                  6,
                  (i) =>
                      DropdownMenuItem(value: i + 1, child: Text('${i + 1}')),
                ),
                onChanged: (value) {
                  if (value != null) {
                    _save(context, settings.copyWith(repliesPerMinute: value));
                  }
                },
              ),
              ExpansionTile(
                title: Text(context.l10n.botUi_allowed),
                subtitle: Text(context.l10n.botUi_allowedHint),
                children: [
                  for (final contact in connector.contacts.where(
                    (c) => c.type == advTypeChat,
                  ))
                    CheckboxListTile(
                      title: Text(contact.name),
                      value: settings.allowedSenders.contains(
                        contact.publicKeyHex,
                      ),
                      onChanged: (value) {
                        final allowed = {...settings.allowedSenders};
                        if (value == true) {
                          allowed.add(contact.publicKeyHex);
                        } else {
                          allowed.remove(contact.publicKeyHex);
                        }
                        _save(
                          context,
                          settings.copyWith(allowedSenders: allowed),
                        );
                      },
                    ),
                ],
              ),
              const Divider(),
              Text(
                context.l10n.botUi_recent,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              if (service.activity.isEmpty)
                ListTile(title: Text(context.l10n.botUi_noReplies)),
              for (final activity in service.activity)
                ListTile(title: Text(activity)),
            ],
          ),
        ),
      );
    },
  );
}

/// Posts National Weather Service warnings for the radio's area to a
/// channel. US only, since it uses the NWS feed.
class _WeatherAlertsSection extends StatelessWidget {
  const _WeatherAlertsSection();

  @override
  Widget build(BuildContext context) {
    final weather = context.watch<WeatherService?>();
    if (weather == null) return const SizedBox.shrink();
    final connector = context.watch<MeshCoreConnector>();
    final settings = weather.settings;
    final channels = connector.channels.where((c) => !c.isEmpty).toList();
    final selected = channels.any((c) => c.index == settings.channelIndex)
        ? settings.channelIndex
        : null;
    final checked = weather.lastCheck;
    final t = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          key: const ValueKey('weather-alerts'),
          title: Text(t.botWx_title),
          subtitle: Text(t.botWx_body),
          value: settings.enabled,
          onChanged: (value) =>
              weather.saveSettings(settings.copyWith(enabled: value)),
        ),
        if (settings.enabled) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButtonFormField<int>(
              key: const ValueKey('weather-alerts-channel'),
              isExpanded: true,
              initialValue: selected,
              decoration: InputDecoration(labelText: t.botWx_channel),
              items: [
                for (final c in channels)
                  DropdownMenuItem(
                    value: c.index,
                    child: Text(
                      c.name.isEmpty
                          ? t.channels_channelIndex(c.index)
                          : c.name,
                    ),
                  ),
              ],
              onChanged: (index) =>
                  weather.saveSettings(settings.copyWith(channelIndex: index)),
            ),
          ),
          SwitchListTile(
            title: Text(t.botWx_moderate),
            subtitle: Text(t.botWx_moderateHint),
            value: settings.includeModerate,
            onChanged: (value) =>
                weather.saveSettings(settings.copyWith(includeModerate: value)),
          ),
          if (weather.problem != null || checked != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                weather.problem != null
                    ? _weatherProblem(t, weather)
                    : t.botWx_lastChecked(
                        TimeOfDay.fromDateTime(
                          checked!.toLocal(),
                        ).format(context),
                      ),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
        ],
      ],
    );
  }
}
