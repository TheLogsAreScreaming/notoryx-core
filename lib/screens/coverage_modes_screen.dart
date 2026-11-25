import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../l10n/l10n.dart';
import '../storage/prefs_manager.dart';
import '../utils/platform_info.dart';
import 'antenna_coverage_screen.dart';
import 'antenna_hunt_screen.dart';
import 'bastion_coverage_capture_screen.dart';
import 'coverage_gap_screen.dart';
import 'coverage_hex_screen.dart';
import 'wardrive_screen.dart';

/// The coverage tools, one entry with a mode bar at the bottom.
enum CoverageMode { capture, wardrive, hexagons, gaps, antenna, hunt }

/// One place for every coverage tool. Each mode is the tool's own screen,
/// built the first time it's opened (so GPS and listeners only start for
/// tools that are used), and the last mode is remembered. The tools can
/// still be opened directly from anywhere else that links to them.
class CoverageModesScreen extends StatefulWidget {
  const CoverageModesScreen({super.key, this.initial, this.screenFor});

  /// Opens this mode instead of the last one used.
  final CoverageMode? initial;

  /// Replaces the real tool screens in tests.
  @visibleForTesting
  final Widget Function(CoverageMode)? screenFor;

  static const lastModeKey = 'coverage_modes_last';

  /// Modes on this platform: hexagons and the gap finder use the H3
  /// library, which the web build doesn't have.
  static List<CoverageMode> get available => [
    for (final m in CoverageMode.values)
      if (!PlatformInfo.isWeb ||
          (m != CoverageMode.hexagons && m != CoverageMode.gaps))
        m,
  ];

  @override
  State<CoverageModesScreen> createState() => _CoverageModesScreenState();
}

class _CoverageModesScreenState extends State<CoverageModesScreen> {
  late final List<CoverageMode> _modes = CoverageModesScreen.available;
  late int _index;
  final Set<int> _opened = {};

  @override
  void initState() {
    super.initState();
    final saved = PrefsManager.isInitialized
        ? PrefsManager.instance.getString(CoverageModesScreen.lastModeKey)
        : null;
    final start =
        widget.initial ??
        CoverageMode.values.where((m) => m.name == saved).firstOrNull ??
        CoverageMode.capture;
    _index = _modes.indexOf(start).clamp(0, _modes.length - 1);
    _opened.add(_index);
  }

  void _select(int i) {
    setState(() {
      _index = i;
      _opened.add(i);
    });
    if (PrefsManager.isInitialized) {
      PrefsManager.instance.setString(
        CoverageModesScreen.lastModeKey,
        _modes[i].name,
      );
    }
  }

  static Widget _screen(CoverageMode m) => switch (m) {
    CoverageMode.capture => const BastionCoverageCaptureScreen(),
    CoverageMode.wardrive => const WardriveScreen(),
    CoverageMode.hexagons => const CoverageHexScreen(),
    CoverageMode.gaps => const CoverageGapScreen(),
    CoverageMode.antenna => const AntennaCoverageScreen(),
    CoverageMode.hunt => const AntennaHuntScreen(),
  };

  static (IconData, String) _label(AppLocalizations l10n, CoverageMode m) =>
      switch (m) {
        CoverageMode.capture => (
          Icons.radio_button_checked,
          l10n.coverageModes_capture,
        ),
        CoverageMode.wardrive => (
          Icons.route_outlined,
          l10n.coverageModes_wardrive,
        ),
        CoverageMode.hexagons => (
          Icons.hexagon_outlined,
          l10n.coverageModes_hexagons,
        ),
        CoverageMode.gaps => (
          Icons.signal_cellular_off_rounded,
          l10n.coverageModes_gaps,
        ),
        CoverageMode.antenna => (Icons.cell_tower, l10n.coverageModes_antenna),
        CoverageMode.hunt => (Icons.track_changes, l10n.coverageModes_hunt),
      };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final build = widget.screenFor ?? _screen;
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          for (var i = 0; i < _modes.length; i++)
            _opened.contains(i) ? build(_modes[i]) : const SizedBox.shrink(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        key: const ValueKey('coverage-modes-bar'),
        selectedIndex: _index,
        onDestinationSelected: _select,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          for (final m in _modes)
            NavigationDestination(
              icon: Icon(_label(l10n, m).$1),
              label: _label(l10n, m).$2,
            ),
        ],
      ),
    );
  }
}
