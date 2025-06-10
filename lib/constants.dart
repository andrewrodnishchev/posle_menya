import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFF0F0F0F);
  static const Color cardBackground = Color(0xFF1E1E1E);
  static const Color primary = Colors.deepPurpleAccent;
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Colors.white70;
  static const Color errorColor = Color(0xFFE53935); // Добавляем цвет ошибки
}

class AppStyles {
  static const RoundedRectangleBorder cardShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(12)),
  );

  static const EdgeInsets defaultPadding = EdgeInsets.all(16.0);
  static const EdgeInsets horizontalPadding = EdgeInsets.symmetric(
    horizontal: 16.0,
  );
}
