import '../theme/mesh_theme.dart';
import '../widgets/ember_backdrop.dart';
import '../widgets/tactical_glass_panel.dart';
import 'package:flutter/material.dart';
import '../l10n/l10n.dart';
import 'coverage_modes_screen.dart';
import 'day_replay_screen.dart';
import 'map_screen.dart';
import 'map_cache_screen.dart';
import 'region_management_screen.dart';

/// Every coverage tool and map tool in one place.
class BastionMapHubScreen extends StatelessWidget {
  const BastionMapHubScreen({super.key});
  static Color get _cyan => MeshPalette.accent;
  static Color get _muted => MeshPalette.ink3;
  @override
  Widget build(BuildContext context) => EmberBackdrop(
    scene: EmberScene.more,
    child: Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        foregroundColor: MeshPalette.ink,
        surfaceTintColor: Colors.transparent,
        title: Text(context.l10n.bastion_mapCoverage),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
          children: [
            TacticalGlassPanel(
              blur: false,
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.map_rounded, color: _cyan, size: 30),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          context.l10n.bastion_mapCoverage,
                          style: TextStyle(
                            color: MeshPalette.ink,
                            fontSize: 21,
                            fontWeight: FontWeight.w900,
                            letterSpacing: .7,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    context.l10n.mapHub_introAll,
                    style: TextStyle(color: _muted, height: 1.45),
                  ),
                ],
              ),
            ),
            _SectionLabel(context.l10n.mapHub_coverageSection),
            // Every coverage tool is a mode of this one entry.
            _MapAction(
              key: const ValueKey('map-hub-coverage'),
              icon: Icons.radio_button_checked,
              title: context.l10n.mapHub_coverageSection,
              subtitle: context.l10n.coverageModes_entryHint,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const CoverageModesScreen(),
                ),
              ),
            ),
            _SectionLabel(context.l10n.mapHub_mapsSection),
            _MapAction(
              icon: Icons.public_rounded,
              title: context.l10n.mapHub_liveMap,
              subtitle: context.l10n.mapHub_liveMapHint,
              badge: context.l10n.mapHub_badgeLive,
              onTap: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const MapScreen())),
            ),
            const SizedBox(height: 12),
            _MapAction(
              icon: Icons.history_rounded,
              title: context.l10n.replay_title,
              subtitle: context.l10n.replay_entryHint,
              badge: context.l10n.replay_badge,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const DayReplayScreen()),
              ),
            ),
            const SizedBox(height: 12),
            _MapAction(
              icon: Icons.offline_pin_rounded,
              title: context.l10n.mapHub_offlinePacks,
              subtitle: context.l10n.mapHub_offlinePacksHint,
              badge: context.l10n.mapHub_badgeOffline,
              onTap: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const MapCacheScreen())),
            ),
            const SizedBox(height: 12),
            _MapAction(
              icon: Icons.hub_rounded,
              title: context.l10n.mapHub_regions,
              subtitle: context.l10n.mapHub_regionsHint,
              badge: context.l10n.mapHub_badgeRegions,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const RegionManagementScreen(),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// A section heading, read out as a heading.
class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 22, 4, 10),
    child: Semantics(
      header: true,
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: BastionMapHubScreen._muted,
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.1,
        ),
      ),
    ),
  );
}

class _MapAction extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final String? badge;
  final VoidCallback onTap;
  const _MapAction({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.badge,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    borderRadius: BorderRadius.circular(MeshRadii.xs),
    child: InkWell(
      borderRadius: BorderRadius.circular(MeshRadii.xs),
      onTap: onTap,
      child: TacticalGlassPanel(
        blur: false,
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: BastionMapHubScreen._cyan.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: BastionMapHubScreen._cyan),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            color: MeshPalette.ink,
                            fontWeight: FontWeight.w800,
                            letterSpacing: .4,
                          ),
                        ),
                      ),
                      if (badge case final badge?)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: BastionMapHubScreen._cyan.withValues(
                              alpha: .12,
                            ),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            badge,
                            style: TextStyle(
                              color: BastionMapHubScreen._cyan,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              letterSpacing: .7,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: BastionMapHubScreen._muted,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded, color: BastionMapHubScreen._cyan),
          ],
        ),
      ),
    ),
  );
}
