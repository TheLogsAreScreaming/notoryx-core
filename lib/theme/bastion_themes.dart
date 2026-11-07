import 'package:flutter/material.dart';

/// Every color a Bastion theme defines. [MeshPalette] reads the current one.
class BastionPalette {
  final Brightness brightness;

  // Surfaces, darkest (or base) first.
  final Color bg, bg1, bg2, bg3, bg4;
  // Lines, faint to strong.
  final Color line, line2, line3;
  // Text, strongest to faintest.
  final Color ink, ink2, ink3, ink4;
  // Signal quality (SNR) colors.
  final Color signal, signalDim;
  final Color warn, warnDim;
  final Color alert;
  final Color accent, accentDim, onAccent;
  // A second and third hue, so a theme isn't one accent on grey. Used for
  // icons, chips, highlights and the background glow; never for status.
  final Color secondary, tertiary;
  final Color magenta;
  // Your own chat bubbles.
  final Color me, meBorder, meInk;
  // Filled containers for the color scheme.
  final Color primaryContainer, secondaryContainer, tertiaryContainer;

  const BastionPalette({
    required this.brightness,
    required this.bg,
    required this.bg1,
    required this.bg2,
    required this.bg3,
    required this.bg4,
    required this.line,
    required this.line2,
    required this.line3,
    required this.ink,
    required this.ink2,
    required this.ink3,
    required this.ink4,
    required this.signal,
    required this.signalDim,
    required this.warn,
    required this.warnDim,
    required this.alert,
    required this.accent,
    required this.accentDim,
    required this.onAccent,
    required this.secondary,
    required this.tertiary,
    required this.magenta,
    required this.me,
    required this.meBorder,
    required this.meInk,
    required this.primaryContainer,
    required this.secondaryContainer,
    required this.tertiaryContainer,
  });

  /// The theme's hues in order, for giving neighbouring icons or groups
  /// their own color. Pick by index with [hue].
  List<Color> get spectrum => [accent, secondary, tertiary, magenta, signal];

  /// The [spectrum] color for item [index], repeating.
  Color hue(int index) => spectrum[index % spectrum.length];

  Color get warnBg => warn.withAlpha(0x1F);
  Color get warnLine => warn.withAlpha(0x66);
  Color get alertBg => alert.withAlpha(0x1F);
  Color get alertLine => alert.withAlpha(0x66);
  Color get accentBg => accent.withAlpha(0x29);
  Color get accentLine => accent.withAlpha(0x80);
  Color get magentaBg => magenta.withAlpha(0x1C);
  Color get magentaLine => magenta.withAlpha(0x47);
}

/// The themes offered in Settings, in the order shown.
enum BastionTheme {
  // The signature theme and the default: charcoal, slate and hi-vis
  // orange. Background, surface (bg3), primary, secondary, text and muted
  // text are the brand colors as given.
  blaze(
    'blaze',
    'Blaze',
    'Charcoal slate with hi-vis orange',
    BastionPalette(
      brightness: Brightness.dark,
      bg: Color(0xFF111820),
      bg1: Color(0xFF18202A),
      bg2: Color(0xFF1C2631),
      bg3: Color(0xFF273443),
      bg4: Color(0xFF324152),
      line: Color(0xFF273443),
      line2: Color(0xFF3A4A5B),
      line3: Color(0xFF5C6D7F),
      ink: Color(0xFFF4F6F8),
      ink2: Color(0xFFD3DAE2),
      ink3: Color(0xFFAAB5C3),
      ink4: Color(0xFF96A2B0),
      signal: Color(0xFF5FD98A),
      signalDim: Color(0xFF6FA37B),
      warn: Color(0xFFFFC83D),
      warnDim: Color(0xFFC9A043),
      alert: Color(0xFFFF5A4E),
      accent: Color(0xFFFF8A00),
      accentDim: Color(0xFFE76F00),
      onAccent: Color(0xFF241000),
      secondary: Color(0xFFE76F00),
      tertiary: Color(0xFF5CC8E8),
      magenta: Color(0xFFFF7AB8),
      me: Color(0xFF3A2814),
      meBorder: Color(0xFFFF8A00),
      meInk: Color(0xFFF4F6F8),
      primaryContainer: Color(0xFF4A2C0C),
      secondaryContainer: Color(0xFF5A2C00),
      tertiaryContainer: Color(0xFF123A48),
    ),
  ),
  // Hacker-terminal neon: toxic green on deep black with electric purple.
  // The purples are lifted slightly from #B026FF and #7022C4 so they read
  // as text; #7022C4 itself fills the third container.
  neonAnarchy(
    'neon_anarchy',
    'Neon Anarchy',
    'Toxic green and electric purple on black',
    BastionPalette(
      brightness: Brightness.dark,
      bg: Color(0xFF08060D),
      bg1: Color(0xFF100A18),
      bg2: Color(0xFF170D22),
      bg3: Color(0xFF21112F),
      bg4: Color(0xFF2E1842),
      line: Color(0xFF2A1640),
      line2: Color(0xFF3F2160),
      line3: Color(0xFF7243B0),
      ink: Color(0xFFF1E9FF),
      ink2: Color(0xFFD9CCF2),
      ink3: Color(0xFFB6A6D6),
      ink4: Color(0xFF9E8EC0),
      signal: Color(0xFFADFF2F),
      signalDim: Color(0xFF7FBF2A),
      warn: Color(0xFFFFE14D),
      warnDim: Color(0xFFC9AE3A),
      alert: Color(0xFFFF4D6D),
      accent: Color(0xFFADFF2F),
      accentDim: Color(0xFF7FCC1F),
      onAccent: Color(0xFF0A1400),
      secondary: Color(0xFFB83AFF),
      tertiary: Color(0xFFA15BE5),
      magenta: Color(0xFFFF4DE1),
      me: Color(0xFF21112F),
      meBorder: Color(0xFFADFF2F),
      meInk: Color(0xFFE8FFD0),
      primaryContainer: Color(0xFF23400A),
      secondaryContainer: Color(0xFF4A0F70),
      tertiaryContainer: Color(0xFF7022C4),
    ),
  ),
  // Olive drab, gunmetal and forest green with a muted tan. #64785A is
  // lifted where it is text.
  tactical(
    'tactical',
    'Tactical',
    'Olive, gunmetal and earth tones',
    BastionPalette(
      brightness: Brightness.dark,
      bg: Color(0xFF171C19),
      bg1: Color(0xFF1C221E),
      bg2: Color(0xFF222A24),
      bg3: Color(0xFF303B32),
      bg4: Color(0xFF3C4A3F),
      line: Color(0xFF303B32),
      line2: Color(0xFF445246),
      line3: Color(0xFF667566),
      ink: Color(0xFFE4E9DC),
      ink2: Color(0xFFCDD4C3),
      ink3: Color(0xFFAEB6A3),
      ink4: Color(0xFF9AA290),
      signal: Color(0xFF8FD18A),
      signalDim: Color(0xFF6E9A6A),
      warn: Color(0xFFE8C15A),
      warnDim: Color(0xFFB89A4A),
      alert: Color(0xFFF2705E),
      accent: Color(0xFFA8BA79),
      accentDim: Color(0xFF7F905A),
      onAccent: Color(0xFF141A0C),
      secondary: Color(0xFF7C9772),
      tertiary: Color(0xFFC2A66B),
      magenta: Color(0xFFD99A7A),
      me: Color(0xFF303B32),
      meBorder: Color(0xFFA8BA79),
      meInk: Color(0xFFE4E9DC),
      primaryContainer: Color(0xFF3E4A2A),
      secondaryContainer: Color(0xFF2E3A28),
      tertiaryContainer: Color(0xFF4A3D22),
    ),
  ),
  // Loud, bright and girly. #FF1493 hot pink can't carry readable text on
  // a light page, so buttons use a deeper hot pink (#D70073) with white
  // text and the pure hot pink trims bubbles and glows. Lavender #C77DFF
  // fills highlights; a stronger violet is used where it is text.
  pinkOverload(
    'pink_overload',
    'Pink Overload',
    'Hot pink, bubblegum and lavender',
    BastionPalette(
      brightness: Brightness.light,
      bg: Color(0xFFFFF0FA),
      bg1: Color(0xFFFFDDF1),
      bg2: Color(0xFFFFD0EA),
      bg3: Color(0xFFFFC1E3),
      bg4: Color(0xFFE9B5FF),
      line: Color(0xFFF79BCF),
      line2: Color(0xFFEC6FB3),
      line3: Color(0xFFB8467F),
      ink: Color(0xFF542044),
      ink2: Color(0xFF5E2450),
      ink3: Color(0xFF6E2A5C),
      ink4: Color(0xFF7A2E66),
      signal: Color(0xFF1E6B45),
      signalDim: Color(0xFF2E7A55),
      warn: Color(0xFF7A4A00),
      warnDim: Color(0xFF8A5A10),
      alert: Color(0xFFB0002A),
      accent: Color(0xFFD70073),
      accentDim: Color(0xFFFF1493),
      onAccent: Color(0xFFFFFFFF),
      secondary: Color(0xFFBE005B),
      tertiary: Color(0xFF8C00F0),
      magenta: Color(0xFFAF41FF),
      me: Color(0xFFD70073),
      meBorder: Color(0xFFC77DFF),
      meInk: Color(0xFFFFFFFF),
      primaryContainer: Color(0xFFFFB0DA),
      secondaryContainer: Color(0xFFFFC2E4),
      tertiaryContainer: Color(0xFFE6C7FF),
    ),
  ),
  // Warm and natural: nude and peach pages, dusty rose and mauve, cocoa
  // and espresso, with sage and hazel. #E8B69E is the raised surface; cards
  // sit on a lighter peach so text on them stays readable.
  bareBeauty(
    'bare_beauty',
    'Bare Beauty',
    'Warm nude, dusty rose, cocoa and sage',
    BastionPalette(
      brightness: Brightness.light,
      bg: Color(0xFFFFF0E7),
      bg1: Color(0xFFFBE4D7),
      bg2: Color(0xFFF6D8C8),
      bg3: Color(0xFFE8B69E),
      bg4: Color(0xFFDDA48A),
      line: Color(0xFFE8C3AF),
      line2: Color(0xFFD19E86),
      line3: Color(0xFF8E5F4E),
      ink: Color(0xFF38232B),
      ink2: Color(0xFF4A2E33),
      ink3: Color(0xFF5A3B3C),
      ink4: Color(0xFF64433F),
      signal: Color(0xFF2F5E48),
      signalDim: Color(0xFF4A7362),
      warn: Color(0xFF7A4A10),
      warnDim: Color(0xFF8A5A20),
      alert: Color(0xFF9E1B2A),
      accent: Color(0xFF9E5A62),
      accentDim: Color(0xFFC77D87),
      onAccent: Color(0xFFFFFFFF),
      secondary: Color(0xFF754B43),
      tertiary: Color(0xFF526459),
      magenta: Color(0xFFB96172),
      me: Color(0xFF9E5A62),
      meBorder: Color(0xFF754B43),
      meInk: Color(0xFFFFFFFF),
      primaryContainer: Color(0xFFF1CBC9),
      secondaryContainer: Color(0xFFE8C9BC),
      tertiaryContainer: Color(0xFFD2E0D8),
    ),
  ),
  // Every status and accent color is from the Okabe-Ito palette, so good,
  // warning and bad stay apart with common color-vision deficiencies.
  // Blue #0072B2 fills containers and your bubbles; sky blue is the accent
  // for text and links, which #0072B2 is too dark to be on the page.
  // Vermillion and bluish green are lifted a touch to read on the slate.
  okabeIto(
    'okabe_ito',
    'Okabe-Ito',
    'Color-vision friendly, on dark slate',
    BastionPalette(
      brightness: Brightness.dark,
      bg: Color(0xFF161A20),
      bg1: Color(0xFF1C2129),
      bg2: Color(0xFF222831),
      bg3: Color(0xFF343C48),
      bg4: Color(0xFF404A57),
      line: Color(0xFF343C48),
      line2: Color(0xFF4A5462),
      line3: Color(0xFF6E7A89),
      ink: Color(0xFFFFFFFF),
      ink2: Color(0xFFDCE1E7),
      ink3: Color(0xFFB9C1CB),
      ink4: Color(0xFFA3ACB7),
      signal: Color(0xFF00A377),
      signalDim: Color(0xFF00805E),
      warn: Color(0xFFF0E442),
      warnDim: Color(0xFFE69F00),
      alert: Color(0xFFEE6800),
      accent: Color(0xFF56B4E9),
      accentDim: Color(0xFF0072B2),
      onAccent: Color(0xFF000000),
      secondary: Color(0xFFE69F00),
      tertiary: Color(0xFF00A377),
      magenta: Color(0xFFCC79A7),
      me: Color(0xFF0072B2),
      meBorder: Color(0xFF56B4E9),
      meInk: Color(0xFFFFFFFF),
      primaryContainer: Color(0xFF0072B2),
      secondaryContainer: Color(0xFF5A3E00),
      tertiaryContainer: Color(0xFF004A36),
    ),
  ),
  // Restrained reds on near-black for working at night. Dim the screen as
  // well: no color scheme alone protects dark-adapted eyes.
  nightOps(
    'night_ops',
    'Night Ops',
    'Dim reds on black for use at night',
    BastionPalette(
      brightness: Brightness.dark,
      bg: Color(0xFF080808),
      bg1: Color(0xFF0F0A0A),
      bg2: Color(0xFF160C0C),
      bg3: Color(0xFF251010),
      bg4: Color(0xFF341614),
      line: Color(0xFF2E1412),
      line2: Color(0xFF451D1A),
      line3: Color(0xFF964337),
      ink: Color(0xFFF3D6D3),
      ink2: Color(0xFFDDB5B0),
      ink3: Color(0xFFC2938D),
      ink4: Color(0xFFAE817B),
      signal: Color(0xFFE0907F),
      signalDim: Color(0xFFA8665C),
      warn: Color(0xFFF0A060),
      warnDim: Color(0xFFB87445),
      alert: Color(0xFFFF3B30),
      accent: Color(0xFFCF4B43),
      accentDim: Color(0xFF852722),
      onAccent: Color(0xFF160403),
      secondary: Color(0xFFF3A29A),
      tertiary: Color(0xFFD96A4A),
      magenta: Color(0xFFE07A8A),
      me: Color(0xFF3A1412),
      meBorder: Color(0xFF852722),
      meInk: Color(0xFFF3D6D3),
      primaryContainer: Color(0xFF4A1512),
      secondaryContainer: Color(0xFF3D1A16),
      tertiaryContainer: Color(0xFF3A1A10),
    ),
  ),
  // Follows the date (see BastionSeason). This palette is only a
  // stand-in; use BastionTheme.paletteFor to get the real one.
  seasonal(
    'seasonal',
    'Seasonal',
    'Changes with the season and holidays',
    BastionPalette(
      brightness: Brightness.dark,
      bg: Color(0xFF1C1612),
      bg1: Color(0xFF231B16),
      bg2: Color(0xFF2A211B),
      bg3: Color(0xFF352A22),
      bg4: Color(0xFF2F3B2A),
      line: Color(0xFF352A22),
      line2: Color(0xFF4A3B30),
      line3: Color(0xFF776050),
      ink: Color(0xFFF5E9DA),
      ink2: Color(0xFFE0CFBA),
      ink3: Color(0xFFC4B09A),
      ink4: Color(0xFFAE9A84),
      signal: Color(0xFF8CCB7A),
      signalDim: Color(0xFF6A9A5A),
      warn: Color(0xFFF2C14A),
      warnDim: Color(0xFFB8963F),
      alert: Color(0xFFFF6B55),
      accent: Color(0xFFE87A2E),
      accentDim: Color(0xFFB5561C),
      onAccent: Color(0xFF1F0E02),
      secondary: Color(0xFFF2B33D),
      tertiary: Color(0xFF7FB86A),
      magenta: Color(0xFFE08A6A),
      me: Color(0xFF5A3218),
      meBorder: Color(0xFFE87A2E),
      meInk: Color(0xFFFBF1E4),
      primaryContainer: Color(0xFF5A3218),
      secondaryContainer: Color(0xFF5A4210),
      tertiaryContainer: Color(0xFF2F4A24),
    ),
  );

  const BastionTheme(this.id, this.label, this.description, this.palette);
  final String id;
  final String label;
  final String description;

  /// The theme's colors. For [seasonal] this is only a stand-in; call
  /// [paletteFor] to get the palette for today.
  final BastionPalette palette;

  static const fallback = BastionTheme.blaze;

  /// Saved ids from earlier versions, and the theme each now opens as.
  static const migrations = <String, BastionTheme>{
    'autumn_frost': seasonal,
    'christmas': seasonal,
    'bubble_gum': pinkOverload,
    'topo_night': pinkOverload,
    'bronzed_blush': bareBeauty,
    'red_light': nightOps,
    'okabe_ito_slate': okabeIto,
    'alpine_day': blaze,
    'halloween': blaze,
  };

  /// The theme for a saved [id]. Old ids follow [migrations]; unknown ones
  /// get [fallback], so a saved preference never breaks the app.
  static BastionTheme fromId(String? id) {
    for (final t in values) {
      if (t.id == id) return t;
    }
    return migrations[id] ?? fallback;
  }

  /// The palette to show for the saved theme [id]. Only Seasonal looks at
  /// [season] ('auto' or a [BastionSeason] id), [holidays] and [now].
  static BastionPalette paletteFor(
    String? id, {
    String season = 'auto',
    bool holidays = true,
    DateTime? now,
  }) {
    final theme = fromId(id);
    if (theme != seasonal) return theme.palette;
    return BastionSeason.resolve(season, holidays: holidays, now: now).palette;
  }
}

/// The palettes inside the Seasonal theme. One is picked from the device's
/// local date unless the user chooses one.
enum BastionSeason {
  spring(
    'spring',
    'Spring',
    'Sage, lavender, pale yellow and floral pink',
    isHoliday: false,
    palette: BastionPalette(
      brightness: Brightness.light,
      bg: Color(0xFFFFFBEA),
      bg1: Color(0xFFF7F4E0),
      bg2: Color(0xFFEEF2E2),
      bg3: Color(0xFFE2EAD6),
      bg4: Color(0xFFE6DDF5),
      line: Color(0xFFD9E0C8),
      line2: Color(0xFFB9C6A8),
      line3: Color(0xFF6E7F5E),
      ink: Color(0xFF26301F),
      ink2: Color(0xFF343F2C),
      ink3: Color(0xFF465338),
      ink4: Color(0xFF4E5B40),
      signal: Color(0xFF2E6B3A),
      signalDim: Color(0xFF4A7A50),
      warn: Color(0xFF7A5200),
      warnDim: Color(0xFF8A6210),
      alert: Color(0xFFA3123A),
      accent: Color(0xFF5C7C53),
      accentDim: Color(0xFF9DB58F),
      onAccent: Color(0xFFFFFFFF),
      secondary: Color(0xFF7A5BB0),
      tertiary: Color(0xFFB04878),
      magenta: Color(0xFFB04878),
      me: Color(0xFF5E7F55),
      meBorder: Color(0xFFB79EE0),
      meInk: Color(0xFFFFFFFF),
      primaryContainer: Color(0xFFD5E6CC),
      secondaryContainer: Color(0xFFE6DDF5),
      tertiaryContainer: Color(0xFFF8D6E4),
    ),
  ),
  summer(
    'summer',
    'Summer',
    'Ocean teal, turquoise, coral and sand',
    isHoliday: false,
    palette: BastionPalette(
      brightness: Brightness.light,
      bg: Color(0xFFFFF6E6),
      bg1: Color(0xFFFBEFD9),
      bg2: Color(0xFFF3E4C8),
      bg3: Color(0xFFE8D6B4),
      bg4: Color(0xFFC9EDEA),
      line: Color(0xFFE6D3AE),
      line2: Color(0xFFCDB487),
      line3: Color(0xFF7A6440),
      ink: Color(0xFF1F2A2E),
      ink2: Color(0xFF2C3A3F),
      ink3: Color(0xFF3E4D52),
      ink4: Color(0xFF465559),
      signal: Color(0xFF1E6B45),
      signalDim: Color(0xFF3A7A5A),
      warn: Color(0xFF7A4A00),
      warnDim: Color(0xFF8A5A10),
      alert: Color(0xFFA8201A),
      accent: Color(0xFF007C89),
      accentDim: Color(0xFF40E0D0),
      onAccent: Color(0xFFFFFFFF),
      secondary: Color(0xFFB24029),
      tertiary: Color(0xFF007063),
      magenta: Color(0xFFB03A6E),
      me: Color(0xFF007C89),
      meBorder: Color(0xFFFF7F50),
      meInk: Color(0xFFFFFFFF),
      primaryContainer: Color(0xFFC9EDEA),
      secondaryContainer: Color(0xFFFFD9CC),
      tertiaryContainer: Color(0xFFCFF3EC),
    ),
  ),
  autumn(
    'autumn',
    'Autumn',
    'Burnt orange, amber, forest green and brown',
    isHoliday: false,
    palette: BastionPalette(
      brightness: Brightness.dark,
      bg: Color(0xFF1C1612),
      bg1: Color(0xFF231B16),
      bg2: Color(0xFF2A211B),
      bg3: Color(0xFF352A22),
      bg4: Color(0xFF2F3B2A),
      line: Color(0xFF352A22),
      line2: Color(0xFF4A3B30),
      line3: Color(0xFF776050),
      ink: Color(0xFFF5E9DA),
      ink2: Color(0xFFE0CFBA),
      ink3: Color(0xFFC4B09A),
      ink4: Color(0xFFAE9A84),
      signal: Color(0xFF8CCB7A),
      signalDim: Color(0xFF6A9A5A),
      warn: Color(0xFFF2C14A),
      warnDim: Color(0xFFB8963F),
      alert: Color(0xFFFF6B55),
      accent: Color(0xFFE87A2E),
      accentDim: Color(0xFFB5561C),
      onAccent: Color(0xFF1F0E02),
      secondary: Color(0xFFF2B33D),
      tertiary: Color(0xFF7FB86A),
      magenta: Color(0xFFE08A6A),
      me: Color(0xFF5A3218),
      meBorder: Color(0xFFE87A2E),
      meInk: Color(0xFFFBF1E4),
      primaryContainer: Color(0xFF5A3218),
      secondaryContainer: Color(0xFF5A4210),
      tertiaryContainer: Color(0xFF2F4A24),
    ),
  ),
  winter(
    'winter',
    'Winter',
    'Ice blue, navy, silver and frost',
    isHoliday: false,
    palette: BastionPalette(
      brightness: Brightness.dark,
      bg: Color(0xFF0E1A2B),
      bg1: Color(0xFF132136),
      bg2: Color(0xFF18283F),
      bg3: Color(0xFF20334E),
      bg4: Color(0xFF2A405E),
      line: Color(0xFF20334E),
      line2: Color(0xFF34496A),
      line3: Color(0xFF5A7193),
      ink: Color(0xFFF4F8FC),
      ink2: Color(0xFFD6E0EB),
      ink3: Color(0xFFB4C2D2),
      ink4: Color(0xFF9FAEC0),
      signal: Color(0xFF7FD8B0),
      signalDim: Color(0xFF5FA88A),
      warn: Color(0xFFF2D06A),
      warnDim: Color(0xFFB8A050),
      alert: Color(0xFFFF7A7A),
      accent: Color(0xFF9AD3F5),
      accentDim: Color(0xFF5E9FC8),
      onAccent: Color(0xFF0A1726),
      secondary: Color(0xFFC9D2DC),
      tertiary: Color(0xFFB4B8FF),
      magenta: Color(0xFFE0A8D8),
      me: Color(0xFF20446A),
      meBorder: Color(0xFF9AD3F5),
      meInk: Color(0xFFF4F8FC),
      primaryContainer: Color(0xFF1F4A6E),
      secondaryContainer: Color(0xFF3A4554),
      tertiaryContainer: Color(0xFF33356A),
    ),
  ),
  halloween(
    'halloween',
    'Halloween',
    'Black, purple and pumpkin orange',
    isHoliday: true,
    palette: BastionPalette(
      brightness: Brightness.dark,
      bg: Color(0xFF0B0910),
      bg1: Color(0xFF120E18),
      bg2: Color(0xFF181220),
      bg3: Color(0xFF22192E),
      bg4: Color(0xFF30223F),
      line: Color(0xFF261C33),
      line2: Color(0xFF3A2A4E),
      line3: Color(0xFF685490),
      ink: Color(0xFFF4ECE0),
      ink2: Color(0xFFDCD0C0),
      ink3: Color(0xFFBFB0A0),
      ink4: Color(0xFFA89A8A),
      signal: Color(0xFF8FD86A),
      signalDim: Color(0xFF6AA050),
      warn: Color(0xFFFFD24D),
      warnDim: Color(0xFFC9A53A),
      alert: Color(0xFFFF5A4E),
      accent: Color(0xFFFF8A2B),
      accentDim: Color(0xFFC8641A),
      onAccent: Color(0xFF1A0A00),
      secondary: Color(0xFFB98CFF),
      tertiary: Color(0xFF9BD86A),
      magenta: Color(0xFFE07AD0),
      me: Color(0xFF3A2410),
      meBorder: Color(0xFFFF8A2B),
      meInk: Color(0xFFF4ECE0),
      primaryContainer: Color(0xFF4A2A0C),
      secondaryContainer: Color(0xFF3E2266),
      tertiaryContainer: Color(0xFF2A3E1A),
    ),
  ),
  christmas(
    'christmas',
    'Christmas',
    'Evergreen, cranberry and gold',
    isHoliday: true,
    palette: BastionPalette(
      brightness: Brightness.dark,
      bg: Color(0xFF0F1F17),
      bg1: Color(0xFF13261C),
      bg2: Color(0xFF172D22),
      bg3: Color(0xFF1E3A2C),
      bg4: Color(0xFF284A38),
      line: Color(0xFF1E3A2C),
      line2: Color(0xFF30523F),
      line3: Color(0xFF55786A),
      ink: Color(0xFFF6F1E4),
      ink2: Color(0xFFDDD6C2),
      ink3: Color(0xFFBFB9A6),
      ink4: Color(0xFFA9A390),
      signal: Color(0xFF8FDCA0),
      signalDim: Color(0xFF6AA87A),
      warn: Color(0xFFF2D06A),
      warnDim: Color(0xFFB89E4A),
      alert: Color(0xFFFF6B6B),
      accent: Color(0xFFE8566E),
      accentDim: Color(0xFFA3203A),
      onAccent: Color(0xFF2A0610),
      secondary: Color(0xFFE8C25A),
      tertiary: Color(0xFF7FD8A0),
      magenta: Color(0xFFF08AA0),
      me: Color(0xFF5A1A28),
      meBorder: Color(0xFFE8C25A),
      meInk: Color(0xFFF6F1E4),
      primaryContainer: Color(0xFF5A1A28),
      secondaryContainer: Color(0xFF4A3E14),
      tertiaryContainer: Color(0xFF1F4A30),
    ),
  ),
  valentine(
    'valentine',
    'Valentine\'s Day',
    'Rose, blush and burgundy',
    isHoliday: true,
    palette: BastionPalette(
      brightness: Brightness.light,
      bg: Color(0xFFFFF1F3),
      bg1: Color(0xFFFCE4E8),
      bg2: Color(0xFFF8D7DD),
      bg3: Color(0xFFF2C2CB),
      bg4: Color(0xFFE8AEB9),
      line: Color(0xFFF0BFC8),
      line2: Color(0xFFD98E9C),
      line3: Color(0xFF8E3A4E),
      ink: Color(0xFF3A0E1C),
      ink2: Color(0xFF4A1426),
      ink3: Color(0xFF5A1A30),
      ink4: Color(0xFF641E36),
      signal: Color(0xFF1E6B45),
      signalDim: Color(0xFF3A7A5A),
      warn: Color(0xFF7A4A00),
      warnDim: Color(0xFF8A5A10),
      alert: Color(0xFFA3001E),
      accent: Color(0xFFB0234A),
      accentDim: Color(0xFFE8798F),
      onAccent: Color(0xFFFFFFFF),
      secondary: Color(0xFF7A1F3D),
      tertiary: Color(0xFFA0306E),
      magenta: Color(0xFFC2406A),
      me: Color(0xFFB0234A),
      meBorder: Color(0xFF7A1F3D),
      meInk: Color(0xFFFFFFFF),
      primaryContainer: Color(0xFFF8D0D8),
      secondaryContainer: Color(0xFFEBC4CF),
      tertiaryContainer: Color(0xFFF2CCE0),
    ),
  );

  const BastionSeason(
    this.id,
    this.label,
    this.description, {
    required this.isHoliday,
    required this.palette,
  });
  final String id;
  final String label;
  final String description;
  final bool isHoliday;
  final BastionPalette palette;

  /// The season for [date], by the northern-hemisphere calendar: spring is
  /// March to May, summer June to August, autumn September to November and
  /// winter December to February. With [holidays], the days before
  /// Halloween (Oct 17–31), Christmas (Dec 10–26) and Valentine's Day
  /// (Feb 7–14) get their own palettes.
  static BastionSeason forDate(DateTime date, {bool holidays = true}) {
    final m = date.month, d = date.day;
    if (holidays) {
      if (m == 10 && d >= 17) return halloween;
      if (m == 12 && d >= 10 && d <= 26) return christmas;
      if (m == 2 && d >= 7 && d <= 14) return valentine;
    }
    return switch (m) {
      3 || 4 || 5 => spring,
      6 || 7 || 8 => summer,
      9 || 10 || 11 => autumn,
      _ => winter,
    };
  }

  /// The season for a saved choice: a season id picks it; anything else
  /// ('auto') follows [now], which defaults to today.
  static BastionSeason resolve(
    String choice, {
    bool holidays = true,
    DateTime? now,
  }) {
    for (final s in values) {
      if (s.id == choice) return s;
    }
    return forDate(now ?? DateTime.now(), holidays: holidays);
  }
}
