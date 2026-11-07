import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/app_settings_service.dart';
import '../theme/mesh_theme.dart';

/// The eight Bastion themes as cards with a small preview of each. A tap
/// applies the theme at once and saves it. When Seasonal is chosen, its
/// season and holiday options appear below the cards.
class ThemePicker extends StatelessWidget {
  const ThemePicker({super.key, this.now});

  /// Today, for the Seasonal preview; tests pass a fixed date.
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    final service = context.watch<AppSettingsService>();
    final settings = service.settings;
    final selected = BastionTheme.fromId(settings.appTheme);
    final season = BastionSeason.resolve(
      settings.seasonalSeason,
      holidays: settings.seasonalHolidays,
      now: now,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 720
                ? 4
                : constraints.maxWidth >= 300
                ? 2
                : 1;
            const gap = MeshSpace.md;
            final width =
                (constraints.maxWidth - gap * (columns - 1)) / columns;
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                for (final t in BastionTheme.values)
                  SizedBox(
                    width: width,
                    child: _ThemeCard(
                      theme: t,
                      palette: t == BastionTheme.seasonal
                          ? season.palette
                          : t.palette,
                      detail: t == BastionTheme.seasonal
                          ? 'Now: ${season.label}'
                          : null,
                      selected: t == selected,
                      onTap: () => service.setAppTheme(t.id),
                    ),
                  ),
              ],
            );
          },
        ),
        if (selected == BastionTheme.seasonal)
          _SeasonalOptions(
            choice: settings.seasonalSeason,
            holidays: settings.seasonalHolidays,
            current: season,
            onChoice: service.setSeasonalSeason,
            onHolidays: service.setSeasonalHolidays,
          ),
      ],
    );
  }
}

class _ThemeCard extends StatelessWidget {
  final BastionTheme theme;
  final BastionPalette palette;
  final String? detail;
  final bool selected;
  final VoidCallback onTap;
  const _ThemeCard({
    required this.theme,
    required this.palette,
    required this.detail,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final ring = Theme.of(context).colorScheme.primary;
    final radius = BorderRadius.circular(MeshRadii.md);
    return Semantics(
      button: true,
      selected: selected,
      label: [
        '${theme.label} theme',
        theme.description,
        ?detail,
        if (selected) 'Selected',
      ].join('. '),
      // The card's own semantics are replaced, so the tap is offered here.
      onTap: onTap,
      excludeSemantics: true,
      child: Material(
        color: p.bg,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          key: ValueKey('theme-${theme.id}'),
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(
                color: selected ? ring : p.line2,
                width: selected ? 3 : 1,
              ),
            ),
            padding: const EdgeInsets.all(MeshSpace.sm + 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Preview(p: p),
                const SizedBox(height: MeshSpace.sm + 2),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        theme.label,
                        style: TextStyle(
                          color: p.ink,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    if (selected)
                      Icon(Icons.check_circle, size: 20, color: p.accent),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  theme.description,
                  style: TextStyle(color: p.ink3, fontSize: 12, height: 1.3),
                ),
                if (detail != null || selected) ...[
                  const SizedBox(height: MeshSpace.xs + 2),
                  Wrap(
                    spacing: MeshSpace.xs,
                    runSpacing: MeshSpace.xs,
                    children: [
                      if (selected) _Tag('Selected', p.accent, p.onAccent),
                      if (detail != null) _Tag(detail!, p.bg3, p.ink2),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;
  final Color fill;
  final Color ink;
  const _Tag(this.text, this.fill, this.ink);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: fill,
      borderRadius: BorderRadius.circular(MeshRadii.pill),
    ),
    child: Text(
      text,
      style: TextStyle(color: ink, fontSize: 11, fontWeight: FontWeight.w700),
    ),
  );
}

/// A miniature chat screen in the theme's colors: a header, a received
/// and a sent message, a button, and the status colors including SOS.
/// Decorative only; the card's label describes the theme.
class _Preview extends StatelessWidget {
  final BastionPalette p;
  const _Preview({required this.p});

  @override
  Widget build(BuildContext context) {
    Widget bar(double width, Color color, [double height = 5]) => Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(height),
      ),
    );
    Widget dot(Color color) => Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
    return ExcludeSemantics(
      child: Container(
        height: 112,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(MeshRadii.sm),
          border: Border.all(color: p.line),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.alphaBlend(p.accent.withAlpha(0x22), p.bg1),
              p.bg1,
              Color.alphaBlend(p.secondary.withAlpha(0x1C), p.bg1),
            ],
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header with a connection dot.
            Container(
              height: 20,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              color: p.bg3,
              child: Row(
                children: [
                  dot(p.signal),
                  const SizedBox(width: 6),
                  bar(34, p.ink2),
                  const Spacer(),
                  bar(14, p.tertiary),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Received message.
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: p.bg2,
                          border: Border.all(color: p.line),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            bar(40, p.ink),
                            const SizedBox(height: 3),
                            bar(22, p.ink4, 3),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    // Sent message.
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: p.me,
                          border: Border.all(color: p.meBorder),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: bar(34, p.meInk),
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Container(
                          width: 38,
                          height: 14,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: p.accent,
                            borderRadius: BorderRadius.circular(MeshRadii.pill),
                          ),
                          child: bar(18, p.onAccent, 3),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          width: 24,
                          height: 14,
                          decoration: BoxDecoration(
                            border: Border.all(color: p.secondary, width: 1.5),
                            borderRadius: BorderRadius.circular(MeshRadii.pill),
                          ),
                        ),
                        const Spacer(),
                        dot(p.signal),
                        const SizedBox(width: 3),
                        dot(p.warn),
                        const SizedBox(width: 3),
                        // SOS keeps its alert color in every theme.
                        Container(
                          width: 16,
                          height: 12,
                          decoration: BoxDecoration(
                            color: p.alert,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Season and holiday choices for the Seasonal theme.
class _SeasonalOptions extends StatelessWidget {
  final String choice;
  final bool holidays;
  final BastionSeason current;
  final ValueChanged<String> onChoice;
  final ValueChanged<bool> onHolidays;
  const _SeasonalOptions({
    required this.choice,
    required this.holidays,
    required this.current,
    required this.onChoice,
    required this.onHolidays,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final automatic = !BastionSeason.values.any((s) => s.id == choice);
    return Padding(
      padding: const EdgeInsets.only(top: MeshSpace.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(
              'Seasonal palette',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            automatic
                ? 'Following the date: ${current.label}.'
                : 'Always ${current.label}.',
            style: TextStyle(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: MeshSpace.sm),
          Wrap(
            spacing: MeshSpace.sm,
            runSpacing: MeshSpace.sm,
            children: [
              ChoiceChip(
                key: const ValueKey('season-auto'),
                label: const Text('Automatic'),
                selected: automatic,
                onSelected: (_) => onChoice('auto'),
              ),
              for (final s in BastionSeason.values)
                ChoiceChip(
                  key: ValueKey('season-${s.id}'),
                  label: Text(s.label),
                  selected: !automatic && s.id == choice,
                  onSelected: (_) => onChoice(s.id),
                ),
            ],
          ),
          SwitchListTile(
            key: const ValueKey('season-holidays'),
            contentPadding: EdgeInsets.zero,
            title: const Text('Holiday palettes'),
            subtitle: const Text(
              'When following the date, use Halloween, Christmas and '
              'Valentine\'s Day colors in the days before each.',
            ),
            value: holidays,
            onChanged: automatic ? onHolidays : null,
          ),
        ],
      ),
    );
  }
}
