import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryPurple = Color(0xFF8B5CF6);
  static const Color primaryBlue = primaryPurple;
  
  static const Color darkBackground = Color(0xFF1A1A2E);
  static const Color darkSurface = Color(0xFF16213E);
  static const Color darkCard = Color(0xFF0F3460);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFA0AEC0);
  
  static const Color lightBackground = Color(0xFFF7F7F8);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF1A1A2E);
  static const Color lightTextSecondary = Color(0xFF6B7280);
}

class AppDimens {
  static const double cardRadius = 12.0;
  static const double inputRadius = 24.0;
  static const double chipRadius = 20.0;
  static const Duration animationDuration = Duration(milliseconds: 250);
  static const Curve animationCurve = Curves.easeInOut;
}
