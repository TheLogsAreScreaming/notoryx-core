import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../connector/meshcore_connector.dart';
import '../helpers/direct_heard_name.dart';
import '../l10n/l10n.dart';
import '../models/contact.dart';
import '../models/direct_repeaters.dart';
import '../services/corescope.dart';
import '../services/direct_repeater_service.dart';
import '../theme/mesh_theme.dart';
import '../widgets/ember_backdrop.dart';
import '../widgets/instrument.dart';
import '../widgets/mesh_ui.dart';
import '../widgets/node_sheet.dart';

/// Shows every RF neighbour this radio has heard since boot, strongest and
/// most recently active first.  Useful for understanding which nodes are
/// within direct RF range.
class WhoRepeatsMeScreen extends StatelessWidget {
  const WhoRepeatsMeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.whoRepeat_title), centerTitle: true),
      body: const EmberBackdrop(scene: EmberScene.nodes, child: _Body()),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final service = context.watch<DirectRepeaterService?>();
    final connector = context.watch<MeshCoreConnector>();
    final analyzer = context.watch<AnalyzerService?>();

    if (service == null) {
      return _EmptyState(
        title: l10n.whoRepeat_emptyTitle,
        body: l10n.whoRepeat_empty,
      );
    }

    final now = DateTime.now();
    final all = List<DirectHeard>.from(service.heard)
      ..sort((a, b) => b.score(now).compareTo(a.score(now)));

    if (all.isEmpty) {
      return _EmptyState(
        title: l10n.whoRepeat_emptyTitle,
        body: l10n.whoRepeat_empty,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      itemCount: all.length,
      separatorBuilder: (_, _) =>
          const Divider(height: 1, indent: 56, endIndent: 16),
      itemBuilder: (context, i) {
        final heard = all[i];
        final name = heardNameWithOnline(connector, analyzer, heard.id);
        final shortId = directHeardShortId(heard.id);
        final minutesAgo = now.difference(heard.lastHeard).inMinutes;
        final contact = connector.contacts
            .where(
              (c) => c.publicKeyHex.toUpperCase().startsWith(
                heard.id.toUpperCase(),
              ),
            )
            .firstOrNull;
        return _HeardRow(
          name: name,
          shortId: shortId,
          heard: heard,
          minutesAgo: minutesAgo,
          contact: contact,
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cell_tower_rounded, size: 48, color: MeshPalette.ink3),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                color: MeshPalette.ink,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              body,
              style: TextStyle(color: MeshPalette.ink3, height: 1.4),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _HeardRow extends StatelessWidget {
  const _HeardRow({
    required this.name,
    required this.shortId,
    required this.heard,
    required this.minutesAgo,
    required this.contact,
  });

  final String? name;
  final String shortId;
  final DirectHeard heard;
  final int minutesAgo;
  final Contact? contact;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final displayName = name ?? shortId;
    final subtitle = l10n.routes_nearbyDetail(
      heard.count,
      l10n.routes_minutesAgo(minutesAgo),
    );

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: AvatarCircle(
        name: displayName,
        size: 40,
        color: _snrColor(heard.snrAverage),
        icon: Icons.cell_tower_rounded,
      ),
      title: Text(
        displayName,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: MeshPalette.ink3, fontSize: 13),
      ),
      trailing: SignalReadout(heard.lastSnr),
      onTap: contact == null ? null : () => showNodeSheet(context, contact!),
    );
  }

  static Color _snrColor(double snr) {
    if (snr >= 5) return MeshPalette.signal;
    if (snr >= -5) return MeshPalette.warn;
    return MeshPalette.alert;
  }
}
