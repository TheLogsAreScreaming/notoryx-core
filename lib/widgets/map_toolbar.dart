import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../theme/mesh_theme.dart';

const double _iconSize = 20;
const double _minLabelled = 48;

/// Still a comfortable tap target with the labels hidden.
const double _minCompact = 44;

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
/// When the labelled buttons don't fit the height it is given (a short
/// screen, large system text), it shows icons only and keeps each label as
/// the tooltip and screen-reader name; past that it scrolls.
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
    final labelHeight =
        MediaQuery.textScalerOf(context).scale(labelStyle.fontSize ?? 11) * 1.2;
    final labelledHeight =
        items.length * max(_minLabelled, 4 + _iconSize + labelHeight) +
        2 * MeshSpace.xs;
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = labelledHeight > constraints.maxHeight;
        return SingleChildScrollView(
          child: _pill(panel, fg, labelStyle, compact: compact),
        );
      },
    );
  }

  Widget _pill(
    Color panel,
    Color fg,
    TextStyle labelStyle, {
    required bool compact,
  }) {
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
                    compact: compact,
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
    required this.compact,
  });

  final MapToolbarItem item;
  final Color color;
  final TextStyle labelStyle;
  final bool compact;

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
            constraints: BoxConstraints(
              minWidth: compact ? 48 : 64,
              minHeight: compact ? _minCompact : _minLabelled,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: MeshSpace.xs,
                vertical: 2,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(item.icon, color: color, size: _iconSize),
                  if (item.showLabel && !compact)
                    Text(
                      item.label,
                      maxLines: 1,
                      style: labelStyle.copyWith(
                        height: 1.2,
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
