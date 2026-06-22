import 'package:flutter/material.dart';

/// Design tokens from [design.md](../../../../design.md).
abstract final class AppColors {
  static const primary = Color(0xFF534AB7);
  static const primaryTintLight = Color(0xFFEEEDFE);
  static const primaryTintText = Color(0xFF3C3489);

  static const primaryDark = primaryTintText;
  static const primaryLight = Color(0xFF7F77DD);
  static const fabBackground = primary;

  static const statusNewBg = Color(0xFFEEEDFE);
  static const statusNewText = Color(0xFF3C3489);
  static const statusQualifiedBg = Color(0xFFFAEEDA);
  static const statusQualifiedText = Color(0xFF633806);
  static const statusWonBg = Color(0xFFE1F5EE);
  static const statusWonText = Color(0xFF085041);
  static const statusLostBg = Color(0xFFFAECE7);
  static const statusLostText = Color(0xFF712B13);

  static const textPrimary = Color(0xFF1C1C1E);
  static const textSecondary = Color(0xFF8E8E93);
  static const textTertiary = Color(0xFF5A5A5E);
  static const border = Color(0xFFE5E1EA);
  static const surfaceTint = Color(0xFFF7F7F8);
  static const card = Color(0xFFFFFFFF);
  static const screenBackground = Color(0xFFFFFFFF);

  static const surface = surfaceTint;
  static const divider = border;
  static const accent = textSecondary;
  static const success = statusWonText;
  static const warning = statusQualifiedText;
  static const danger = statusLostText;
}
