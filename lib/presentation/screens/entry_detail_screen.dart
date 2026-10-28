import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../domain/models/journal_entry.dart';
import '../widgets/ambient_particle_field.dart';
import '../widgets/audio_wave_visualizer.dart';
import '../widgets/glass_container.dart';
import '../widgets/gyro_tilt_card.dart';
import '../widgets/sensor_badge_pill.dart';

class EntryDetailScreen extends StatefulWidget {
  final JournalEntry entry;
  final VoidCallback onDelete;

  const EntryDetailScreen({
    super.key,
    required this.entry,
    required this.onDelete,
  });

  @override
  State<EntryDetailScreen> createState() => _EntryDetailScreenState();
}

class _EntryDetailScreenState extends State<EntryDetailScreen> {
  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgSurfaceLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.glassBorder),
        ),
        title: const Text(
          'Delete Sensory Memory?',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'This sensory snapshot and all associated device telemetry will be permanently wiped.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.neonPink,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              widget.onDelete();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _shareMemory() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.bgSurfaceLight,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.neonCyan, width: 1),
        ),
        content: Text(
          'Telemetry export: "${widget.entry.title}" (${widget.entry.sensorSnapshot.soundCategoryLabel}) copied to clipboard.',
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    final snapshot = entry.sensorSnapshot;
    final ambianceColor = snapshot.dominantAmbianceColor;
    final chaos = snapshot.chaosFactor;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Solid backdrop with dynamic sensory lighting glow
          Positioned.fill(
            child: Container(
              color: AppColors.bgObsidian.withOpacity(0.96),
            ),
          ),

          // Dynamic radial glow representing the captured memory's chaos/calm
          Positioned(
            top: -100,
            left: -50,
            right: -50,
            height: 450,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  center: Alignment.topCenter,
                  radius: 0.85,
                  colors: [
                    ambianceColor.withOpacity(0.35 + (chaos * 0.25)),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Morphing Ambient Living Particles reflecting the original moment
          Positioned.fill(
            child: AmbientParticleField(
              chaosFactor: chaos,
              primaryColor: ambianceColor,
              secondaryColor: entry.mood.accentColor,
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top Custom Navigation Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: AppColors.textPrimary, size: 26),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: ambianceColor.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: ambianceColor.withOpacity(0.6), width: 1),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: ambianceColor,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: ambianceColor,
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'IMMERSIVE SENSORY REPLAY',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.share_rounded, color: AppColors.textSecondary, size: 20),
                            onPressed: _shareMemory,
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.neonPink, size: 22),
                            onPressed: _confirmDelete,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Scrollable Content
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Mood & Timestamp Pill Header
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                color: entry.mood.accentColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: entry.mood.accentColor, width: 1.2),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(entry.mood.emoji, style: const TextStyle(fontSize: 14)),
                                  const SizedBox(width: 6),
                                  Text(
                                    entry.mood.label,
                                    style: TextStyle(
                                      color: entry.mood.accentColor,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              DateFormatter.formatFullDate(entry.createdAt),
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Title
                        Text(
                          entry.title,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.6,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Journal Entry Content
                        GlassContainer(
                          padding: const EdgeInsets.all(18),
                          borderRadius: 20,
                          borderColor: AppColors.glassBorder,
                          fillColor: AppColors.glassFill,
                          child: Text(
                            entry.content,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 15,
                              height: 1.6,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),

                        if (entry.tags.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: entry.tags.map((tag) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.glassFill,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppColors.glassBorder),
                                ),
                                child: Text(
                                  '#$tag',
                                  style: const TextStyle(
                                    color: AppColors.neonCyan,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],

                        const SizedBox(height: 26),

                        // SECTION 1: Auditory Telemetry Replay
                        const Row(
                          children: [
                            Icon(Icons.graphic_eq_rounded, size: 16, color: AppColors.neonCyan),
                            SizedBox(width: 6),
                            Text(
                              'ORIGINAL ACOUSTIC REPLAY',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        GlassContainer(
                          padding: const EdgeInsets.all(14),
                          borderRadius: 22,
                          borderColor: ambianceColor.withOpacity(0.4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    snapshot.soundCategoryLabel,
                                    style: TextStyle(
                                      color: ambianceColor,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  SensorBadgePill.audio(snapshot.decibelLevel),
                                ],
                              ),
                              const SizedBox(height: 8),
                              AudioWaveVisualizer(
                                decibels: snapshot.decibelLevel,
                                height: 95,
                                waveColor: ambianceColor,
                                showDecibelBadge: false,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // SECTION 2: Kinematic & Gyro Replay
                        const Row(
                          children: [
                            Icon(Icons.vibration_rounded, size: 16, color: AppColors.neonPink),
                            SizedBox(width: 6),
                            Text(
                              'ORIGINAL KINEMATICS & ORIENTATION',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        GyroTiltCard(
                          snapshot: snapshot,
                          height: 165,
                          interactive: true,
                        ),

                        const SizedBox(height: 24),

                        // SECTION 3: Detailed Telemetry Audit Table
                        const Row(
                          children: [
                            Icon(Icons.terminal_rounded, size: 16, color: AppColors.neonPurple),
                            SizedBox(width: 6),
                            Text(
                              'SENSOR TELEMETRY MATRIX',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        GlassContainer(
                          padding: const EdgeInsets.all(16),
                          borderRadius: 20,
                          borderColor: AppColors.glassBorder,
                          child: Column(
                            children: [
                              _buildMatrixRow('Decibel Pressure', '${snapshot.decibelLevel.toStringAsFixed(1)} dB'),
                              const Divider(color: AppColors.glassBorder, height: 16),
                              _buildMatrixRow('Movement Score', '${snapshot.movementScore.toStringAsFixed(1)} / 100'),
                              const Divider(color: AppColors.glassBorder, height: 16),
                              _buildMatrixRow('Sensory Chaos Index', '${(chaos * 100).toStringAsFixed(1)}%'),
                              const Divider(color: AppColors.glassBorder, height: 16),
                              _buildMatrixRow(
                                'Accelerometer (X, Y, Z)',
                                '${snapshot.accelX.toStringAsFixed(2)}, ${snapshot.accelY.toStringAsFixed(2)}, ${snapshot.accelZ.toStringAsFixed(2)}',
                              ),
                              const Divider(color: AppColors.glassBorder, height: 16),
                              _buildMatrixRow(
                                'Gyroscope (X, Y, Z)',
                                '${snapshot.gyroX.toStringAsFixed(2)}, ${snapshot.gyroY.toStringAsFixed(2)}, ${snapshot.gyroZ.toStringAsFixed(2)}',
                              ),
                              const Divider(color: AppColors.glassBorder, height: 16),
                              _buildMatrixRow(
                                'Telemetry Source',
                                snapshot.isSimulated ? 'Simulated Fallback Engine' : 'Live Hardware Sensors',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatrixRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}
