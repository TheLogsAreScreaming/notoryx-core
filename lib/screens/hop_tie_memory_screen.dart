import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../services/hop_tie_memory.dart';
import '../theme/mesh_theme.dart';
import '../widgets/ember_backdrop.dart';
import '../widgets/instrument.dart';

/// Settings for remembering which repeater won when several share a short
/// path ID.
class HopTieMemoryScreen extends StatelessWidget {
  const HopTieMemoryScreen({super.key, this.memory});

  /// For tests; [HopTieMemory.shared] otherwise.
  final HopTieMemory? memory;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final memory = this.memory ?? HopTieMemory.shared;
    final small = TextStyle(color: MeshPalette.ink3, fontSize: 12.5);
    return EmberBackdrop(
      scene: EmberScene.more,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          scrolledUnderElevation: 0,
          title: Text(l10n.hopTie_title),
        ),
        body: ListenableBuilder(
          listenable: memory,
          builder: (context, _) {
            final count = memory.count;
            return ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(MeshSpace.lg),
                  child: Text(l10n.hopTie_explainer, style: small),
                ),
                _Stepper(
                  key: const ValueKey('hop-tie-ttl'),
                  icon: Icons.history_rounded,
                  title: l10n.hopTie_ttl,
                  value: l10n.hopTie_days(memory.ttlDays),
                  onMinus: memory.ttlDays > 1
                      ? () => memory.ttlDays = memory.ttlDays - 1
                      : null,
                  onPlus: memory.ttlDays < HopTieMemory.maxTtlDays
                      ? () => memory.ttlDays = memory.ttlDays + 1
                      : null,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: MeshSpace.lg),
                  child: Text(l10n.hopTie_ttlHelp, style: small),
                ),
                const SizedBox(height: MeshSpace.lg),
                _Stepper(
                  key: const ValueKey('hop-tie-margin'),
                  icon: Icons.balance_rounded,
                  title: l10n.hopTie_margin,
                  value: '${memory.marginPercent} %',
                  onMinus: memory.marginPercent > 0
                      ? () => memory.marginPercent = memory.marginPercent - 1
                      : null,
                  onPlus: memory.marginPercent < HopTieMemory.maxMarginPercent
                      ? () => memory.marginPercent = memory.marginPercent + 1
                      : null,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: MeshSpace.lg),
                  child: Text(l10n.hopTie_marginHelp, style: small),
                ),
                Padding(
                  padding: const EdgeInsets.all(MeshSpace.lg),
                  child: InstrumentButton(
                    key: const ValueKey('hop-tie-forget'),
                    label: l10n.hopTie_forget(count),
                    icon: Icons.delete_sweep_rounded,
                    danger: true,
                    onPressed: count == 0 ? null : memory.forgetAll,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.onMinus,
    required this.onPlus,
  });

  final IconData icon;
  final String title;
  final String value;
  final VoidCallback? onMinus;
  final VoidCallback? onPlus;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(value),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: l10n.hopTie_less,
            icon: const Icon(Icons.remove_rounded),
            onPressed: onMinus,
          ),
          IconButton(
            tooltip: l10n.hopTie_more,
            icon: const Icon(Icons.add_rounded),
            onPressed: onPlus,
          ),
        ],
      ),
    );
  }
}
