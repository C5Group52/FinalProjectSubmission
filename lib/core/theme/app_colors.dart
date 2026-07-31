import 'package:flutter/material.dart';

/// Palette drawn from the Somaliland flag (green / white / red) used
/// throughout the Figma prototype's buttons, accents, and iconography.
abstract final class AppColors {
  /// Primary green used for buttons, links, and any text/icon pairing with
  /// white. Deliberately darker than a "typical" Tailwind green-600
  /// (0xFF16A34A only measures ~3.3:1 against white) so white-on-green and
  /// green-on-white text both clear WCAG AA's 4.5:1 threshold (~5.4:1 here).
  static const Color primaryGreen = Color(0xFF0F7A38);

  /// Lighter decorative tint — flag graphics, progress-bar fill, subtle
  /// tinted surfaces. Never paired with overlaid text/icons that need to
  /// meet the 4.5:1 text-contrast bar (surfaces like this only need 3:1).
  static const Color primaryGreenLight = Color(0xFF16A34A);

  /// ~4.8:1 against white — safe for white-on-red text (error banners, etc).
  static const Color accentRed = Color(0xFFDC2626);

  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFF7F8F7);
  static const Color lightOutline = Color(0xFFE2E5E3);
  static const Color lightOnSurface = Color(0xFF1A1C1A);
  static const Color lightOnSurfaceMuted = Color(0xFF6B7280);

  static const Color darkBackground = Color(0xFF121412);
  static const Color darkSurface = Color(0xFF1C1F1C);
  static const Color darkOutline = Color(0xFF33362F);
  static const Color darkOnSurface = Color(0xFFF2F3F1);
  static const Color darkOnSurfaceMuted = Color(0xFFA3A8A1);

  static const Color error = Color(0xFFB3261E);
  static const Color success = primaryGreen;
  static const Color warning = Color(0xFFB45309);
}