/// Spacing scale derived from Stitch layout measurements.
///
/// Base unit: 4px. Screen horizontal padding is 16px on a 390pt frame
/// (measured as ~9px on 344px-wide exports, normalized to design width).
abstract final class AppSpacing {
  static const double unit = 4;

  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  /// Default horizontal screen padding.
  static const double screenHorizontal = md;

  /// Vertical gap between stacked cards.
  static const double cardGap = sm;

  /// Internal card padding.
  static const double cardPadding = md;

  /// Bottom navigation bar height.
  static const double bottomNavHeight = 64;

  /// Primary button height (measured from Upload Failed screen).
  static const double buttonHeight = 52;

  /// Icon container size inside cards.
  static const double iconContainerSize = 40;

  /// Standard icon size.
  static const double iconSize = 24;

  /// Small icon size (badges, trailing actions).
  static const double iconSizeSm = 20;
}
