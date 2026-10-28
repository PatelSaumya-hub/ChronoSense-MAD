import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

enum SensorBadgeType { audio, motion, ambiance }

class SensorBadgePill extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color accentColor;
  final bool isAnimated;

  const SensorBadgePill({
    super.key,
    required this.label,
    required this.icon,
    required this.accentColor,
    this.isAnimated = true,
  });

  factory SensorBadgePill.audio(double decibels) {
    final color = AppColors.colorForDecibels(decibels);
    String descriptor = 'Calm';
    if (decibels > 78) descriptor = 'Chaotic';
    else if (decibels > 62) descriptor = 'Lively';
    else if (decibels > 46) descriptor = 'Moderate';

    return SensorBadgePill(
      label: '${decibels.toStringAsFixed(0)} dB • $descriptor',
      icon: Icons.graphic_eq_rounded,
      accentColor: color,
    );
  }

  factory SensorBadgePill.motion(double motionScore) {
    final color = AppColors.colorForMotion(motionScore);
    String descriptor = 'Still';
    if (motionScore > 75) descriptor = 'High Motion';
    else if (motionScore > 50) descriptor = 'Active';
    else if (motionScore > 25) descriptor = 'Gentle';

    return SensorBadgePill(
      label: '${motionScore.toStringAsFixed(0)}% • $descriptor',
      icon: Icons.vibration_rounded,
      accentColor: color,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: accentColor.withOpacity(0.45),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13,
            color: accentColor,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: accentColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
