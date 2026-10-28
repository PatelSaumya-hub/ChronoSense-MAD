import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/models/sensor_snapshot.dart';
import 'glass_container.dart';

class GyroTiltCard extends StatelessWidget {
  final SensorSnapshot snapshot;
  final Widget? customContent;
  final double height;
  final bool interactive;

  const GyroTiltCard({
    super.key,
    required this.snapshot,
    this.customContent,
    this.height = 170.0,
    this.interactive = true,
  });

  @override
  Widget build(BuildContext context) {
    final pitch = snapshot.pitch; // X rotation
    final roll = snapshot.roll;   // Y rotation
    final motionColor = AppColors.colorForMotion(snapshot.movementScore);

    return Transform(
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.0018) // Perspective factor
        ..rotateX(interactive ? pitch : 0.0)
        ..rotateY(interactive ? roll : 0.0),
      alignment: Alignment.center,
      child: GlassContainer(
        height: height,
        borderRadius: 22,
        borderColor: motionColor.withOpacity(0.4),
        borderWidth: 1.2,
        fillColor: AppColors.glassFillCard,
        shadows: [
          BoxShadow(
            color: motionColor.withOpacity(0.18),
            blurRadius: 28,
            offset: Offset(-roll * 25, pitch * 25),
          ),
        ],
        child: Stack(
          children: [
            // Dynamic specular light reflection gradient based on tilt
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  gradient: RadialGradient(
                    center: Alignment(
                      (roll * 3.0).clamp(-1.0, 1.0),
                      (-pitch * 3.0).clamp(-1.0, 1.0),
                    ),
                    radius: 0.9,
                    colors: [
                      motionColor.withOpacity(0.22),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Card Content
            customContent ??
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: motionColor.withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.screen_rotation_alt_rounded,
                                size: 16,
                                color: motionColor,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              '3D KINEMATICS',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: motionColor.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: motionColor.withOpacity(0.6),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            snapshot.motionCategoryLabel,
                            style: TextStyle(
                              color: motionColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildAxisPill('X (Pitch)', '${(pitch * 180 / math.pi).toStringAsFixed(1)}°', AppColors.neonCyan),
                        _buildAxisPill('Y (Roll)', '${(roll * 180 / math.pi).toStringAsFixed(1)}°', AppColors.neonPurple),
                        _buildAxisPill('Accel Mag', '${snapshot.movementScore.toStringAsFixed(0)}%', motionColor),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(
                          snapshot.isSimulated ? Icons.sim_card_outlined : Icons.sensors_rounded,
                          size: 13,
                          color: snapshot.isSimulated ? AppColors.neonAmber : AppColors.neonGreen,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          snapshot.isSimulated
                              ? 'Synthetic Telemetry Stream (Active Fallback)'
                              : 'Hardware Gyroscope & Accelerometer Connected',
                          style: TextStyle(
                            color: snapshot.isSimulated ? AppColors.neonAmber : AppColors.neonGreen,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildAxisPill(String title, String value, Color color) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}
