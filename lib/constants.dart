import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFF0F0F0F);
  static const cardBackground = Color(0xFF1E1E1E);
  static const primary = Colors.deepPurpleAccent;
  static const textPrimary = Colors.white;
  static const textSecondary = Colors.white70;
  static const darkBackground = Color(0xFF0A0A0A);
  static const errorColor = Color(0xFFE57373);
}

class AppStyles {
  static const cardShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(12)),
  );

  static const defaultPadding = EdgeInsets.all(16.0);
  static const horizontalPadding = EdgeInsets.symmetric(horizontal: 16.0);
}
