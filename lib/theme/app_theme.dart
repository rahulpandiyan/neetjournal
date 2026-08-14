import 'package:flutter/material.dart';

/// Studyn design language (modern refresh).
///
/// Direction: "Serene Focus" — calm, focused, encouraging, natural.
/// - Primary: Forest green (#2E7D32) — growth and progress.
/// - Secondary: Sage green (#66BB6A) — softer, supporting touch.
/// - Accent: Goldenrod (#FFC107) — countdown, alerts, energy moments.
/// - Typography: Space Grotesk (display/headings) + DM Sans (body).
/// - Surfaces: borderless tonal cards, 24px radius, 8pt spacing grid.
/// - Signature: big Space Grotesk numerals, tinted hero headers, pill
///   nav indicator, hairline-free cards.
class AppTheme {
  static ThemeData light() => _base(_scheme(Brightness.light));

  static ThemeData dark() => _base(_scheme(Brightness.dark));

  static ColorScheme _scheme(Brightness b) {
    if (b == Brightness.light) {
      return const ColorScheme.light(
        primary: Color(0xFF2E7D32),
        onPrimary: Color(0xFFFFFFFF),
        primaryContainer: Color(0xFFA5D6A7),
        onPrimaryContainer: Color(0xFF00320B),
        secondary: Color(0xFF3A6B3C),
        onSecondary: Color(0xFFFFFFFF),
        secondaryContainer: Color(0xFF66BB6A),
        onSecondaryContainer: Color(0xFF07310E),
        tertiary: Color(0xFF7C5E00),
        onTertiary: Color(0xFFFFFFFF),
        tertiaryContainer: Color(0xFFFFC107),
        onTertiaryContainer: Color(0xFF241800),
        onSurface: Color(0xFF212121),
        onSurfaceVariant: Color(0xFF414941),
        outline: Color(0xFF737B72),
        outlineVariant: Color(0xFFC2CBC1),
        shadow: Color(0xFF000000),
        scrim: Color(0xFF000000),
        inverseSurface: Color(0xFF32352F),
        onInverseSurface: Color(0xFFF2F1EC),
        inversePrimary: Color(0xFF86D58C),
        error: Color(0xFFBA1A1A),
        onError: Color(0xFFFFFFFF),
        errorContainer: Color(0xFFFFDAD6),
        onErrorContainer: Color(0xFF410002),
      ).copyWith(
        surface: const Color(0xFFF0F3ED),
        surfaceContainerLowest: const Color(0xFFF9FBF7),
        surfaceContainerLow: const Color(0xFFF2F5F0),
        surfaceContainer: const Color(0xFFEBF0E9),
        surfaceContainerHigh: const Color(0xFFE4EAE2),
        surfaceContainerHighest: const Color(0xFFDDE4DB),
      );
    }
    return const ColorScheme.dark(
      primary: Color(0xFF83CE86),
      onPrimary: Color(0xFF06310B),
      primaryContainer: Color(0xFF205E25),
      onPrimaryContainer: Color(0xFFB5F0B0),
      secondary: Color(0xFF88C98A),
      onSecondary: Color(0xFF0A3510),
      secondaryContainer: Color(0xFF2E6232),
      onSecondaryContainer: Color(0xFFC9F0C0),
      tertiary: Color(0xFFFFD04B),
      onTertiary: Color(0xFF251A00),
      tertiaryContainer: Color(0xFF5C4A00),
      onTertiaryContainer: Color(0xFFFFE3A2),
      onSurface: Color(0xFFE0E0E0),
      onSurfaceVariant: Color(0xFFC0C7BF),
      outline: Color(0xFF89918A),
      outlineVariant: Color(0xFF424A42),
      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),
      inverseSurface: Color(0xFFE2E2DD),
      onInverseSurface: Color(0xFF32352F),
      inversePrimary: Color(0xFF2E7D32),
      error: Color(0xFFFFB4AB),
      onError: Color(0xFF690005),
      errorContainer: Color(0xFF93000A),
      onErrorContainer: Color(0xFFFFDAD6),
    ).copyWith(
      surface: const Color(0xFF151812),
      surfaceContainerLowest: const Color(0xFF1B1E17),
      surfaceContainerLow: const Color(0xFF22261E),
      surfaceContainer: const Color(0xFF292D24),
      surfaceContainerHigh: const Color(0xFF32372D),
      surfaceContainerHighest: const Color(0xFF3D4237),
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
      splashColor: scheme.onSurface.withValues(alpha: 0.10),
      highlightColor: scheme.onSurface.withValues(alpha: 0.06),
      // Cards: borderless, softly toned, generous radius.
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surfaceContainerLow,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        clipBehavior: Clip.antiAlias,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(
            fontFamily: 'DMSans',
            fontSize: 15.5,
            fontWeight: FontWeight.w700,
          ),
          elevation: 0,
          overlayColor: scheme.onPrimary.withValues(alpha: 0.12),
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
            fontFamily: 'DMSans',
            fontSize: 14.5,
            fontWeight: FontWeight.w600,
          ),
          overlayColor: scheme.onSurface.withValues(alpha: 0.08),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontFamily: 'DMSans',
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          overlayColor: scheme.onSurface.withValues(alpha: 0.08),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surfaceContainerHigh,
        selectedColor: scheme.primaryContainer,
        secondarySelectedColor: scheme.primaryContainer,
        showCheckmark: false,
        labelStyle: TextStyle(
          fontFamily: 'DMSans',
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
          color: scheme.onSurfaceVariant,
        ),
        secondaryLabelStyle: TextStyle(
          fontFamily: 'DMSans',
          fontSize: 13.5,
          fontWeight: FontWeight.w700,
          color: scheme.onPrimaryContainer,
        ),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: const StadiumBorder(),
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
          fontFamily: 'SpaceGrotesk',
          fontSize: 13.5,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'SpaceGrotesk',
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF2E7D32),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        elevation: 8,
        shadowColor: const Color(0xFF2E7D32).withValues(alpha: 0.3),
        contentTextStyle: const TextStyle(
          fontFamily: 'DMSans',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          letterSpacing: 0.2,
        ),
      ),
      appBarTheme: AppBarThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          fontFamily: 'SpaceGrotesk',
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: scheme.onSurface,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        indicatorColor: scheme.primaryContainer,
        height: 68,
        elevation: 0,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? scheme.onPrimaryContainer
                : scheme.onSurfaceVariant,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontFamily: 'DMSans',
            fontSize: 11.5,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
            color: states.contains(WidgetState.selected)
                ? scheme.onPrimaryContainer
                : scheme.onSurfaceVariant,
          ),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? scheme.primary
              : scheme.outlineVariant,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? scheme.primaryContainer
              : scheme.surfaceContainerHighest,
        ),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: scheme.onSurfaceVariant,
        textColor: scheme.onSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          foregroundColor: scheme.onSurfaceVariant,
        ),
      ),
      textTheme: base.textTheme.copyWith(
        displayLarge: const TextStyle(
          fontFamily: 'SpaceGrotesk',
          fontSize: 40,
          fontWeight: FontWeight.w700,
          letterSpacing: -1,
          height: 1.05,
        ),
        displayMedium: const TextStyle(
          fontFamily: 'SpaceGrotesk',
          fontSize: 34,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.8,
          height: 1.1,
        ),
        headlineLarge: const TextStyle(
          fontFamily: 'SpaceGrotesk',
          fontSize: 30,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.6,
          height: 1.15,
        ),
        headlineMedium: const TextStyle(
          fontFamily: 'SpaceGrotesk',
          fontSize: 26,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
          height: 1.2,
        ),
        headlineSmall: const TextStyle(
          fontFamily: 'SpaceGrotesk',
          fontSize: 23,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
          height: 1.2,
        ),
        titleLarge: const TextStyle(
          fontFamily: 'SpaceGrotesk',
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
        titleMedium: const TextStyle(
          fontFamily: 'SpaceGrotesk',
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        titleSmall: const TextStyle(
          fontFamily: 'SpaceGrotesk',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
        labelLarge: const TextStyle(
          fontFamily: 'DMSans',
          fontSize: 14.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.1,
        ),
        labelMedium: const TextStyle(
          fontFamily: 'DMSans',
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
        labelSmall: const TextStyle(
          fontFamily: 'DMSans',
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.4,
        ),
        bodyLarge: const TextStyle(
          fontFamily: 'DMSans',
          fontSize: 16,
          height: 1.5,
        ),
        bodyMedium: const TextStyle(
          fontFamily: 'DMSans',
          fontSize: 14.5,
          height: 1.45,
        ),
        bodySmall: const TextStyle(
          fontFamily: 'DMSans',
          fontSize: 12.5,
          height: 1.4,
        ),
      ),
    );
  }
}
