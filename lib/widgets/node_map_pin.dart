import 'package:flutter/material.dart';

import '../theme/mesh_theme.dart';

/// A node's pin on the map. Repeaters are a rounded square with a tower and
/// get a green ring while recently heard; other nodes are circles. The small
/// dot shows freshness (or a low battery).
class NodeMapPin extends StatelessWidget {
  const NodeMapPin({
    super.key,
    required this.color,
    required this.icon,
    required this.dotBorderColor,
    this.repeater = false,
    this.selected = false,
    this.stale = false,
    this.online = false,
    this.batteryLow = false,
  });

  final Color color;
  final IconData icon;

  /// Matches the map panel so the status dot reads as cut out.
  final Color dotBorderColor;
  final bool repeater;
  final bool selected;
  final bool stale;
  final bool online;
  final bool batteryLow;

  @override
  Widget build(BuildContext context) {
    final statusColor = batteryLow
        ? MapPalette.batteryLow
        : online
        ? MapPalette.online
        : stale
        ? MapPalette.offline
        : MapPalette.stale;
    final size = selected ? 44.0 : 36.0;
    final ring = repeater && online && !selected;
    final shape = repeater
        ? BoxDecoration(
            borderRadius: BorderRadius.circular(MeshRadii.sm),
            color: selected ? MapPalette.selected : color,
            border: Border.all(
              color: ring ? MapPalette.online : MapPalette.markerOutline,
              width: selected || ring ? 3 : 2.5,
            ),
            boxShadow: _shadows(ring),
          )
        : BoxDecoration(
            shape: BoxShape.circle,
            color: selected ? MapPalette.selected : color,
            border: Border.all(
              color: MapPalette.markerOutline,
              width: selected ? 3 : 2.5,
            ),
            boxShadow: _shadows(false),
          );
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Container(
          width: size,
          height: size,
          decoration: shape,
          alignment: Alignment.center,
          child: Icon(icon, color: Colors.white, size: selected ? 22 : 19),
        ),
        Positioned(
          right: selected ? -1 : -2,
          bottom: selected ? 0 : -2,
          child: Container(
            width: batteryLow ? 16 : (selected ? 13 : 12),
            height: batteryLow ? 16 : (selected ? 13 : 12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: statusColor,
              border: Border.all(color: dotBorderColor, width: 2),
            ),
            alignment: Alignment.center,
            child: batteryLow
                ? const Icon(Icons.battery_alert, size: 10, color: Colors.white)
                : null,
          ),
        ),
      ],
    );
  }

  List<BoxShadow> _shadows(bool ring) => [
    const BoxShadow(
      color: MapPalette.markerShadow,
      blurRadius: 8,
      offset: Offset(0, 3),
    ),
    if (selected)
      BoxShadow(
        color: MapPalette.selected.withValues(alpha: 0.75),
        blurRadius: 14,
        spreadRadius: 3,
      ),
    if (ring)
      BoxShadow(
        color: MapPalette.online.withValues(alpha: 0.45),
        blurRadius: 10,
        spreadRadius: 1,
      ),
  ];
}
