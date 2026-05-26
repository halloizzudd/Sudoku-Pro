import 'package:flutter/material.dart';

// Task 2: palet semantik terpusat agar UI bereaksi terhadap Light/Dark.
// Warna mode-dependent (background/surface/teks/grid) berbeda antar mode;
// warna brand (primary/accent/danger/success) tetap sama di kedua mode.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  final Color background; // scaffold
  final Color surface; // card
  final Color surface2; // alt surface (number pad, inset, game bg)
  final Color textPrimary; // teks di atas background/surface
  final Color textSecondary; // teks sekunder/abu
  final Color gridLine; // garis grid sudoku
  final Color divider; // pemisah list
  final Color inputFill; // isi field input
  final Color cellSelected; // highlight sel terpilih
  final Color cellRelated; // highlight baris/kolom/box
  final Color cellNote; // teks pencil mark

  // Brand / semantik (sama di kedua mode)
  final Color primary; // indigo
  final Color accent; // amber
  final Color danger; // merah
  final Color success; // hijau

  const AppColors({
    required this.background,
    required this.surface,
    required this.surface2,
    required this.textPrimary,
    required this.textSecondary,
    required this.gridLine,
    required this.divider,
    required this.inputFill,
    required this.cellSelected,
    required this.cellRelated,
    required this.cellNote,
    required this.primary,
    required this.accent,
    required this.danger,
    required this.success,
  });

  static const Color _primary = Color(0xFF5C4EE5);
  static const Color _accent = Color(0xFFF59E0B);
  static const Color _danger = Color(0xFFEF4444);

  static const AppColors dark = AppColors(
    background: Color(0xFF0F0F1A),
    surface: Color(0xFF1A1A2E),
    surface2: Color(0xFF161622),
    textPrimary: Colors.white,
    textSecondary: Color(0xFF9A9AAE),
    gridLine: Color(0xFF3A3A5A),
    divider: Color(0xFF26263C),
    inputFill: Color(0xFF1E1E2E),
    cellSelected: Color(0x805C4EE5), // indigo 50%
    cellRelated: Color(0xFF2A2A4A),
    cellNote: Color(0xFFB0B0C0),
    primary: _primary,
    accent: _accent,
    danger: _danger,
    success: Color(0xFF22C55E),
  );

  static const AppColors light = AppColors(
    background: Color(0xFFF3F4FA),
    surface: Colors.white,
    surface2: Color(0xFFE9EBF3),
    textPrimary: Color(0xFF15151F),
    textSecondary: Color(0xFF6A6A7C),
    gridLine: Color(0xFFB9BFD4),
    divider: Color(0xFFE2E5EF),
    inputFill: Color(0xFFEDEFF6),
    cellSelected: Color(0x335C4EE5), // indigo 20% (kontras teks gelap)
    cellRelated: Color(0xFFDFE0F2),
    cellNote: Color(0xFF7A7A8C),
    primary: _primary,
    accent: _accent,
    danger: _danger,
    success: Color(0xFF16A34A),
  );

  @override
  AppColors copyWith({
    Color? background,
    Color? surface,
    Color? surface2,
    Color? textPrimary,
    Color? textSecondary,
    Color? gridLine,
    Color? divider,
    Color? inputFill,
    Color? cellSelected,
    Color? cellRelated,
    Color? cellNote,
    Color? primary,
    Color? accent,
    Color? danger,
    Color? success,
  }) {
    return AppColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surface2: surface2 ?? this.surface2,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      gridLine: gridLine ?? this.gridLine,
      divider: divider ?? this.divider,
      inputFill: inputFill ?? this.inputFill,
      cellSelected: cellSelected ?? this.cellSelected,
      cellRelated: cellRelated ?? this.cellRelated,
      cellNote: cellNote ?? this.cellNote,
      primary: primary ?? this.primary,
      accent: accent ?? this.accent,
      danger: danger ?? this.danger,
      success: success ?? this.success,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surface2: Color.lerp(surface2, other.surface2, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      gridLine: Color.lerp(gridLine, other.gridLine, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      inputFill: Color.lerp(inputFill, other.inputFill, t)!,
      cellSelected: Color.lerp(cellSelected, other.cellSelected, t)!,
      cellRelated: Color.lerp(cellRelated, other.cellRelated, t)!,
      cellNote: Color.lerp(cellNote, other.cellNote, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      success: Color.lerp(success, other.success, t)!,
    );
  }
}

// Akses ringkas: context.colors
extension AppColorsX on BuildContext {
  AppColors get colors =>
      Theme.of(this).extension<AppColors>() ?? AppColors.dark;
}
