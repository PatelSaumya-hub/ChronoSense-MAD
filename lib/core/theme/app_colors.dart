import 'package:flutter/material.dart';

/// ChronoSense curated neon cyber & dark glassmorphism color palette.
class AppColors {
  AppColors._();

  // Futuristic Neon Accents (Per Prompt Specification)
  static const Color neonPurple = Color(0xFF6C5CE7);
  static const Color neonCyan = Color(0xFF00CEC9);
  static const Color neonPink = Color(0xFFFD79A8);
  static const Color neonAmber = Color(0xFFFFA502);
  static const Color neonGreen = Color(0xFF2ED573);

  // Backgrounds & Obsidian Canvas
  static const Color bgObsidian = Color(0xFF0A0C16);
  static const Color bgSurface = Color(0xFF111528);
  static const Color bgSurfaceLight = Color(0xFF1B213B);

  // Glassmorphism Tints & Borders
  static const Color glassFill = Color(0x221B213B);
  static const Color glassFillCard = Color(0x35232B4A);
  static const Color glassBorder = Color(0x26FFFFFF);
  static const Color glassBorderGlow = Color(0x556C5CE7);

  // Typography
  static const Color textPrimary = Color(0xFFF8F9FA);
  static const Color textSecondary = Color(0xFFA0AEC0);
  static const Color textMuted = Color(0xFF6B7280);

  // Sensory State Gradients
  static const LinearGradient sereneGradient = LinearGradient(
    colors: [Color(0xFF00CEC9), Color(0xFF6C5CE7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient chaoticGradient = LinearGradient(
    colors: [Color(0xFFFD79A8), Color(0xFFFFA502), Color(0xFFFF4757)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient deepSpaceGradient = LinearGradient(
    colors: [Color(0xFF0A0C16), Color(0xFF101426), Color(0xFF080911)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Helper to get a dynamic color representing a decibel level
  static Color colorForDecibels(double db) {
    if (db < 45) return neonCyan; // Serene / Quiet
    if (db < 65) return neonPurple; // Moderate / Conversational
    if (db < 80) return neonAmber; // Loud / Energetic
    return neonPink; // Chaotic / Intense
  }

  /// Helper to get a dynamic color representing motion score (0-100)
  static Color colorForMotion(double score) {
    if (score < 25) return neonCyan; // Still
    if (score < 55) return neonGreen; // Gentle
    if (score < 80) return neonAmber; // Active
    return neonPink; // High motion
  }
}
