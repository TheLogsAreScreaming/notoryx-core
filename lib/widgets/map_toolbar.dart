import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../theme/mesh_theme.dart';

/// One button in the [MapToolbar].
class MapToolbarItem {
  const MapToolbarItem({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.selected = false,
    this.showLabel = true,
    this.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  /// Highlighted, for a mode that is on.
  final bool selected;

  /// Icon-only buttons still use [label] as their tooltip and semantics.
  final bool showLabel;
  final Key? key;
}

/// The frosted vertical pill of map tools on the right edge of the map.
class MapToolbar extends StatelessWidget {
  const MapToolbar({super.key, required this.items, required this.dark});

  final List<MapToolbarItem> items;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fg = dark ? MapPalette.textPrimary : scheme.onSurface;
    final panel = dark
        ? MapPalette.panelDark.withValues(alpha: 0.7)
        : scheme.surfaceContainerLow.withValues(alpha: 0.8);
    final labelStyle = Theme.of(context).textTheme.labelSmall!;
    return ClipRRect(
      borderRadius: BorderRadius.circular(MeshRadii.xl),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: panel,
            borderRadius: BorderRadius.circular(MeshRadii.xl),
            border: Border.all(color: MapPalette.border),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: MeshSpace.xs),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final item in items)
                  _ToolButton(
                    item: item,
                    color: item.selected ? MapPalette.selected : fg,
                    labelStyle: labelStyle,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  const _ToolButton({
    required this.item,
    required this.color,
    required this.labelStyle,
  });

  final MapToolbarItem item;
  final Color color;
  final TextStyle labelStyle;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: item.label,
      child: Semantics(
        button: true,
        toggled: item.selected ? true : null,
        label: item.label,
        enabled: item.onPressed != null,
        onTap: item.onPressed,
        excludeSemantics: true,
        child: InkWell(
          key: item.key,
          onTap: item.onPressed,
          borderRadius: BorderRadius.circular(MeshRadii.md),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 64, minHeight: 48),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: MeshSpace.xs,
                vertical: MeshSpace.xs,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(item.icon, color: color, size: 22),
                  if (item.showLabel)
                    Text(
                      item.label,
                      maxLines: 1,
                      style: labelStyle.copyWith(
                        color: color,
                        fontWeight: item.selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
