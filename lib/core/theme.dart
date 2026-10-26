import 'package:flutter/material.dart';

/// Zaka's visual identity: high-contrast minimalist monochrome.
/// Clean black-and-white aesthetic, razor-sharp hairlines, and zero unnecessary ornament.
abstract final class ZakaTheme {
  static const Color black = Color(0xFF09090B);
  static const Color white = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE4E4E7);
  static const Color darkBorder = Color(0xFF27272A);
  static const Color lightMuted = Color(0xFF6B6B73);
  static const Color darkMuted = Color(0xFFA1A1AA);

  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final bg = isDark ? Colors.black : Colors.white;
    final fg = isDark ? Colors.white : Colors.black;
    final cardBg = isDark ? const Color(0xFF09090B) : Colors.white;
    final border = isDark ? darkBorder : lightBorder;
    final muted = isDark ? darkMuted : lightMuted;

    final scheme = isDark
        ? const ColorScheme.dark(
            primary: Colors.white,
            onPrimary: Colors.black,
            secondary: Color(0xFFD4D4D8),
            onSecondary: Colors.black,
            surface: Colors.black,
            onSurface: Colors.white,
            surfaceContainerHighest: Color(0xFF18181B),
            onSurfaceVariant: Color(0xFFA1A1AA),
            outline: Color(0xFF27272A),
            outlineVariant: Color(0xFF27272A),
            error: Color(0xFFEF4444),
            onError: Colors.white,
          )
        : const ColorScheme.light(
            primary: Colors.black,
            onPrimary: Colors.white,
            secondary: Color(0xFF27272A),
            onSecondary: Colors.white,
            surface: Colors.white,
            onSurface: Color(0xFF09090B),
            surfaceContainerHighest: Color(0xFFF4F4F5),
            onSurfaceVariant: Color(0xFF6B6B73),
            outline: Color(0xFFE4E4E7),
            outlineVariant: Color(0xFFE4E4E7),
            error: Color(0xFFDC2626),
            onError: Colors.white,
          );

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: bg,
    );

    return base.copyWith(
      textTheme: base.textTheme.copyWith(
        displaySmall: base.textTheme.displaySmall?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -1.2,
          color: fg,
        ),
        headlineMedium: base.textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.8,
          color: fg,
        ),
        headlineSmall: base.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
          color: fg,
        ),
        titleLarge: base.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
          color: fg,
        ),
        titleMedium: base.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
          color: fg,
        ),
        titleSmall: base.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: fg,
        ),
        bodyLarge: base.textTheme.bodyLarge?.copyWith(
          color: fg,
        ),
        bodyMedium: base.textTheme.bodyMedium?.copyWith(
          color: muted,
          height: 1.45,
        ),
        bodySmall: base.textTheme.bodySmall?.copyWith(
          color: muted,
        ),
        labelLarge: base.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: fg,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        iconTheme: IconThemeData(color: fg),
      ),
      cardTheme: CardThemeData(
        color: cardBg,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: border, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF121214) : const Color(0xFFFAFAFA),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: fg, width: 1.5),
        ),
        hintStyle: TextStyle(color: muted, fontSize: 14),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: fg,
          foregroundColor: bg,
          elevation: 0,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: fg,
          elevation: 0,
          minimumSize: const Size.fromHeight(48),
          side: BorderSide(color: border, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: BorderSide(color: border, width: 1),
        ),
        backgroundColor: isDark ? const Color(0xFF141416) : const Color(0xFFF4F4F5),
        selectedColor: fg,
        labelStyle: TextStyle(
          color: fg,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 64,
        elevation: 0,
        backgroundColor: bg,
        surfaceTintColor: Colors.transparent,
        indicatorColor: Colors.transparent,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith((states) => IconThemeData(
          color: states.contains(WidgetState.selected)
              ? (isDark ? Colors.white : Colors.black)
              : (isDark ? Colors.white54 : Colors.black54),
        )),
        labelTextStyle: WidgetStateProperty.resolveWith((states) => TextStyle(
          color: states.contains(WidgetState.selected)
              ? (isDark ? Colors.white : Colors.black)
              : (isDark ? Colors.white54 : Colors.black54),
          fontWeight: states.contains(WidgetState.selected)
              ? FontWeight.w600
              : FontWeight.w500,
          fontSize: 12,
        )),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? const Color(0xFF18181B) : const Color(0xFF18181B),
        contentTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
        insetPadding: const EdgeInsets.fromLTRB(16, 0, 16, 88),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: isDark ? darkBorder : const Color(0xFF3F3F46)),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: border,
        space: 1,
        thickness: 1,
      ),
    );
  }
}
