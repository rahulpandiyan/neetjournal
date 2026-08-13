import 'package:flutter/material.dart';

/// NEET Journal design language (locked).
///
/// Direction: technical / utilitarian — a disciplined study cockpit.
/// - Seed: deep "lab" teal (biology / medicine DNA).
/// - Accent: warm amber = energy, streaks, "now" moments.
/// - Neutrals: green-tinted paper (light) / green-ink (dark), never pure grey.
/// - Signature: rounded-20 cards, pill tab indicator, hairline dividers,
///   tabular numerals wherever numbers matter.
class AppTheme {
  static const seed = Color(0xFF00696E);

  static ThemeData light() => _base(_scheme(Brightness.light));

  static ThemeData dark() => _base(_scheme(Brightness.dark));

  static ColorScheme _scheme(Brightness b) {
    final base = ColorScheme.fromSeed(seedColor: seed, brightness: b);
    if (b == Brightness.light) {
      return base.copyWith(
        surface: const Color(0xFFF5F7F4),
        surfaceContainerLowest: const Color(0xFFFFFFFF),
        surfaceContainerLow: const Color(0xFFEEF1ED),
        surfaceContainer: const Color(0xFFE8ECE7),
        surfaceContainerHigh: const Color(0xFFE2E7E1),
        surfaceContainerHighest: const Color(0xFFDDE2DC),
        onSurface: const Color(0xFF171D1A),
        onSurfaceVariant: const Color(0xFF414A45),
        outline: const Color(0xFF727B76),
        outlineVariant: const Color(0xFFC1C9C2),
        tertiary: const Color(0xFF7A5900),
        tertiaryContainer: const Color(0xFFFFDFA0),
        onTertiaryContainer: const Color(0xFF2B1A00),
      );
    }
    return base.copyWith(
      surface: const Color(0xFF0E1513),
      surfaceContainerLowest: const Color(0xFF090F0D),
      surfaceContainerLow: const Color(0xFF16201D),
      surfaceContainer: const Color(0xFF1A2522),
      surfaceContainerHigh: const Color(0xFF252F2C),
      surfaceContainerHighest: const Color(0xFF303A36),
      onSurface: const Color(0xFFDFE4DF),
      onSurfaceVariant: const Color(0xFFBFC9C3),
      outline: const Color(0xFF89938D),
      outlineVariant: const Color(0xFF414B46),
      tertiary: const Color(0xFFFFD08B),
      tertiaryContainer: const Color(0xFF5A4400),
      onTertiaryContainer: const Color(0xFFFFE2B2),
    );
  }

  static ThemeData _base(ColorScheme scheme) {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: scheme.brightness,
    );
    return base.copyWith(
      scaffoldBackgroundColor: scheme.surface,
      splashFactory: InkSparkle.splashFactory,
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surfaceContainerLow,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.4)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 15.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          side: BorderSide(color: scheme.outlineVariant),
          textStyle: const TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surfaceContainerHigh,
        selectedColor: scheme.primaryContainer,
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHigh,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        linearTrackColor: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: scheme.onPrimaryContainer,
        unselectedLabelColor: scheme.onSurfaceVariant,
        labelStyle: const TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w500,
        ),
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.transparent,
        indicator: BoxDecoration(
          color: scheme.primaryContainer,
          borderRadius: BorderRadius.circular(999),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        insetPadding: const EdgeInsets.all(16),
        contentTextStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      appBarTheme: AppBarThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      textTheme: base.textTheme.copyWith(
        headlineSmall: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
          height: 1.2,
        ),
        titleLarge: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        titleMedium: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        titleSmall: const TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
        labelLarge: const TextStyle(
          fontSize: 14.5,
          fontWeight: FontWeight.w600,
        ),
        bodyMedium: const TextStyle(fontSize: 14.5, height: 1.45),
        bodySmall: const TextStyle(fontSize: 12.5, height: 1.4),
      ),
    );
  }
}
