import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../theme/mesh_theme.dart';
import '../widgets/ember_backdrop.dart';
import '../widgets/tactical_glass_panel.dart';

/// What the mesh, this phone and the internet can see, in plain words.
/// Kept in step with docs/PRIVACY_POLICY.md.
class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    Widget section(String heading, IconData icon, List<Widget> children) =>
        Padding(
          padding: const EdgeInsets.only(bottom: MeshSpace.lg),
          child: TacticalGlassPanel(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  header: true,
                  child: Row(
                    children: [
                      Icon(icon, color: MeshPalette.accent, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          heading,
                          style: TextStyle(
                            color: MeshPalette.ink,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                ...children,
              ],
            ),
          ),
        );
    Widget item(String title, String body) => Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: MeshPalette.ink,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(body, style: TextStyle(color: MeshPalette.ink2, height: 1.3)),
        ],
      ),
    );
    Widget bullet(String text) => Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExcludeSemantics(
            child: Text('•  ', style: TextStyle(color: MeshPalette.ink2)),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: MeshPalette.ink2, height: 1.3),
            ),
          ),
        ],
      ),
    );
    return EmberBackdrop(
      scene: EmberScene.more,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          scrolledUnderElevation: 0,
          foregroundColor: MeshPalette.ink,
          title: Text(l10n.privacy_title),
        ),
        body: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.all(MeshSpace.lg),
            children: [
              section(l10n.privacy_meshHeading, Icons.cell_tower, [
                item(l10n.privacy_dmTitle, l10n.privacy_dmBody),
                item(l10n.privacy_channelTitle, l10n.privacy_channelBody),
                item(l10n.privacy_advertTitle, l10n.privacy_advertBody),
              ]),
              section(l10n.privacy_phoneHeading, Icons.smartphone, [
                Text(
                  l10n.privacy_phoneBody,
                  style: TextStyle(color: MeshPalette.ink2, height: 1.3),
                ),
              ]),
              section(l10n.privacy_netHeading, Icons.public, [
                Text(
                  l10n.privacy_netIntro,
                  style: TextStyle(color: MeshPalette.ink2, height: 1.3),
                ),
                bullet(l10n.privacy_netMaps),
                bullet(l10n.privacy_netTerrain),
                bullet(l10n.privacy_netModels),
                bullet(l10n.privacy_netImages),
                bullet(l10n.privacy_netLists),
                bullet(l10n.privacy_netMqtt),
                bullet(l10n.privacy_netAnalyzer),
              ]),
              section(l10n.privacy_notHeading, Icons.block, [
                Text(
                  l10n.privacy_notBody,
                  style: TextStyle(color: MeshPalette.ink2, height: 1.3),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}
