import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../theme/mesh_theme.dart';

/// How to wardrive: the modes, what the map colours mean, airtime manners,
/// antennas and car repeaters, running with the screen off, and sharing
/// drives. Everything is in the app; nothing links out.
class WardriveGuideScreen extends StatelessWidget {
  const WardriveGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final sections = [
      (
        Icons.play_circle_outline,
        l10n.wardriveGuide_startTitle,
        l10n.wardriveGuide_startBody,
      ),
      (
        Icons.podcasts,
        l10n.wardriveGuide_modesTitle,
        l10n.wardriveGuide_modesBody,
      ),
      (
        Icons.grid_on,
        l10n.wardriveGuide_coloursTitle,
        l10n.wardriveGuide_coloursBody,
      ),
      (
        Icons.volume_down,
        l10n.wardriveGuide_airtimeTitle,
        l10n.wardriveGuide_airtimeBody,
      ),
      (
        Icons.directions_car,
        l10n.wardriveGuide_antennaTitle,
        l10n.wardriveGuide_antennaBody,
      ),
      (
        Icons.screen_lock_portrait,
        l10n.wardriveGuide_screenOffTitle,
        l10n.wardriveGuide_screenOffBody,
      ),
      (
        Icons.ios_share,
        l10n.wardriveGuide_shareTitle,
        l10n.wardriveGuide_shareBody,
      ),
    ];
    return Scaffold(
      appBar: AppBar(title: Text(l10n.wardriveGuide_title)),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: MeshSpace.sm),
        children: [
          for (final (i, (icon, title, body)) in sections.indexed)
            ExpansionTile(
              key: ValueKey('wardrive-guide-$i'),
              leading: Icon(icon),
              title: Text(title),
              initiallyExpanded: i == 0,
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              expandedCrossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final para in body.split('\n\n'))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(para, style: const TextStyle(height: 1.4)),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
