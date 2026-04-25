import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryBlue = Color(0xFF1A73E8);
  
  static const Color darkBackground = Color(0xFF1E1E2E);
  static const Color darkSurface = Color(0xFF2A2A3E);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFA0A0B0);
  
  static const Color lightBackground = Color(0xFFF5F5F5);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF1E1E2E);
  static const Color lightTextSecondary = Color(0xFF6B6B7B);
}

class AppDimens {
  static const double cardRadius = 16.0;
  static const double inputRadius = 24.0;
  static const double chipRadius = 12.0;
  static const Duration animationDuration = Duration(milliseconds: 250);
  static const Curve animationCurve = Curves.easeInOut;
}
