import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

abstract final class AppTheme {
  static const double _radius = 12;

  // Material's minimum recommended touch target is 48x48dp.
  static const Size _minTapTarget = Size(64, 48);

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primaryGreen,
      brightness: Brightness.light,
      primary: AppColors.primaryGreen,
      error: AppColors.error,
      surface: AppColors.lightBackground,
    );
    return _base(scheme).copyWith(
      scaffoldBackgroundColor: AppColors.lightBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.lightBackground,
        foregroundColor: AppColors.lightOnSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStyles.titleMedium.copyWith(
          color: AppColors.lightOnSurface,
        ),
      ),
      cardColor: AppColors.lightSurface,
      dividerColor: AppColors.lightOutline,
      inputDecorationTheme: _inputTheme(
        fill: AppColors.lightSurface,
        outline: AppColors.lightOutline,
        hint: AppColors.lightOnSurfaceMuted,
      ),
      textTheme: _textTheme(
        AppColors.lightOnSurface,
        AppColors.lightOnSurfaceMuted,
      ),
    );
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primaryGreenLight,
      brightness: Brightness.dark,
      primary: AppColors.primaryGreenLight,
      error: AppColors.error,
      surface: AppColors.darkBackground,
    );
    return _base(scheme).copyWith(
      scaffoldBackgroundColor: AppColors.darkBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        foregroundColor: AppColors.darkOnSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStyles.titleMedium.copyWith(
          color: AppColors.darkOnSurface,
        ),
      ),
      cardColor: AppColors.darkSurface,
      dividerColor: AppColors.darkOutline,
      inputDecorationTheme: _inputTheme(
        fill: AppColors.darkSurface,
        outline: AppColors.darkOutline,
        hint: AppColors.darkOnSurfaceMuted,
      ),
      textTheme: _textTheme(
        AppColors.darkOnSurface,
        AppColors.darkOnSurfaceMuted,
      ),
    );
  }

  static ThemeData _base(ColorScheme scheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: Colors.white,
          disabledBackgroundColor: scheme.onSurface.withValues(alpha: 0.12),
          disabledForegroundColor: scheme.onSurface.withValues(alpha: 0.38),
          minimumSize: _minTapTarget,
          textStyle: AppTextStyles.button,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_radius),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: _minTapTarget,
          textStyle: AppTextStyles.button,
          side: BorderSide(color: scheme.outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_radius),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: _minTapTarget,
          foregroundColor: AppColors.primaryGreen,
          textStyle: AppTextStyles.button,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(minimumSize: _minTapTarget),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius),
          side: BorderSide(color: scheme.outline),
        ),
        // AppTextStyles.bodySmall carries no colour, and setting labelStyle
        // here replaces the colour Material would otherwise supply, so the
        // label has to be tied to the scheme explicitly or it renders
        // invisible against the chip.
        labelStyle: AppTextStyles.bodySmall.copyWith(color: scheme.onSurface),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius),
        ),
      ),
    );
  }

  static InputDecorationTheme _inputTheme({
    required Color fill,
    required Color outline,
    required Color hint,
  }) {
    OutlineInputBorder border(Color color, {double width = 1}) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius),
          borderSide: BorderSide(color: color, width: width),
        );
    return InputDecorationTheme(
      filled: true,
      fillColor: fill,
      hintStyle: AppTextStyles.bodyMedium.copyWith(color: hint),
      labelStyle: AppTextStyles.bodyMedium.copyWith(color: hint),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: border(outline),
      enabledBorder: border(outline),
      focusedBorder: border(AppColors.primaryGreen, width: 1.5),
      errorBorder: border(AppColors.error),
      focusedErrorBorder: border(AppColors.error, width: 1.5),
    );
  }

  static TextTheme _textTheme(Color onSurface, Color muted) {
    return TextTheme(
      headlineLarge: AppTextStyles.headlineLarge.copyWith(color: onSurface),
      headlineMedium: AppTextStyles.headlineMedium.copyWith(color: onSurface),
      headlineSmall: AppTextStyles.headlineMedium.copyWith(color: onSurface),
      titleLarge: AppTextStyles.titleMedium.copyWith(color: onSurface),
      titleMedium: AppTextStyles.titleMedium.copyWith(color: onSurface),
      titleSmall: AppTextStyles.label.copyWith(color: onSurface),
      // TextField/TextFormField default to bodyLarge for the text the user
      // actually types — leaving this unset made typed input fall back to a
      // near-invisible default color, which is why field input read as blank.
      bodyLarge: AppTextStyles.bodyMedium.copyWith(color: onSurface),
      bodyMedium: AppTextStyles.bodyMedium.copyWith(color: onSurface),
      bodySmall: AppTextStyles.bodySmall.copyWith(color: muted),
      labelLarge: AppTextStyles.label.copyWith(color: onSurface),
      labelMedium: AppTextStyles.bodySmall.copyWith(color: muted),
      labelSmall: AppTextStyles.bodySmall.copyWith(color: muted),
    );
  }
}