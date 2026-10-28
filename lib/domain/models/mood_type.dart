import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

enum MoodType {
  serene('Serene', '🌿', AppColors.neonCyan),
  energetic('Energetic', '⚡', AppColors.neonAmber),
  reflective('Reflective', '🌙', AppColors.neonPurple),
  anxious('Anxious', '🌪️', AppColors.neonPink),
  ecstatic('Ecstatic', '🔥', Color(0xFFFF5252)),
  melancholic('Melancholic', '🌧️', Color(0xFF5352ED)),
  focused('Focused', '🎯', AppColors.neonGreen);

  final String label;
  final String emoji;
  final Color accentColor;

  const MoodType(this.label, this.emoji, this.accentColor);

  static MoodType fromString(String value) {
    for (final mood in MoodType.values) {
      if (mood.name.toLowerCase() == value.toLowerCase() ||
          mood.label.toLowerCase() == value.toLowerCase()) {
        return mood;
      }
    }
    return MoodType.reflective;
  }
}
