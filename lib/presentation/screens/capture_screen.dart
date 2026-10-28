import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/models/journal_entry.dart';
import '../../domain/models/mood_type.dart';
import '../../domain/models/sensor_snapshot.dart';
import '../../domain/repositories/sensor_service.dart';
import '../providers/sensor_stream_controller.dart';
import '../widgets/ambient_particle_field.dart';
import '../widgets/audio_wave_visualizer.dart';
import '../widgets/glass_container.dart';
import '../widgets/gyro_tilt_card.dart';
import '../widgets/mood_selector.dart';

class CaptureScreen extends StatefulWidget {
  final SensorService sensorService;

  const CaptureScreen({
    super.key,
    required this.sensorService,
  });

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  late final SensorStreamController _streamController;
  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _contentCtrl = TextEditingController();
  final TextEditingController _tagCtrl = TextEditingController();

  MoodType _selectedMood = MoodType.reflective;
  final List<String> _tags = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _streamController = SensorStreamController(widget.sensorService);
    _streamController.addListener(_onSensorUpdate);
    _streamController.initialize();
  }

  @override
  void dispose() {
    _streamController.removeListener(_onSensorUpdate);
    _streamController.dispose();
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    _tagCtrl.dispose();
    super.dispose();
  }

  void _onSensorUpdate() {
    if (mounted) setState(() {});
  }

  void _handleCaptureTelemetry() {
    HapticFeedback.mediumImpact();
    if (_streamController.isLocked) {
      _streamController.resetCapture();
    } else {
      _streamController.captureTelemetry();
    }
  }

  void _addTag(String tag) {
    final cleaned = tag.trim().replaceAll('#', '');
    if (cleaned.isNotEmpty && !_tags.contains(cleaned)) {
      setState(() {
        _tags.add(cleaned);
        _tagCtrl.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  Future<void> _saveEntry() async {
    final title = _titleCtrl.text.trim();
    final content = _contentCtrl.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.neonPink.withOpacity(0.9),
          content: const Text(
            'Please give this sensory memory a title.',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    HapticFeedback.heavyImpact();

    // Ensure snapshot is locked; if not yet locked, lock right now
    if (!_streamController.isLocked) {
      _streamController.captureTelemetry();
    }

    final finalSnapshot = _streamController.currentSnapshot;
    final entry = JournalEntry(
      id: const Uuid().v4(),
      title: title,
      content: content.isEmpty ? 'Sensory capture recorded without text.' : content,
      createdAt: DateTime.now(),
      mood: _selectedMood,
      sensorSnapshot: finalSnapshot,
      tags: _tags,
    );

    Navigator.of(context).pop(entry);
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = _streamController.currentSnapshot;
    final isLocked = _streamController.isLocked;
    final activeAmbiance = snapshot.dominantAmbianceColor;

    return Scaffold(
      backgroundColor: AppColors.bgObsidian,
      appBar: AppBar(
        title: const Text('Sensory Capture'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          // Simulation / Hardware Switch
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Row(
              children: [
                Icon(
                  _streamController.isMocking ? Icons.sim_card_outlined : Icons.sensors_rounded,
                  size: 16,
                  color: _streamController.isMocking ? AppColors.neonAmber : AppColors.neonGreen,
                ),
                const SizedBox(width: 4),
                Text(
                  _streamController.isMocking ? 'MOCK' : 'LIVE',
                  style: TextStyle(
                    color: _streamController.isMocking ? AppColors.neonAmber : AppColors.neonGreen,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Switch(
                  value: _streamController.isMocking,
                  activeColor: AppColors.neonAmber,
                  activeTrackColor: AppColors.neonAmber.withOpacity(0.3),
                  inactiveThumbColor: AppColors.neonCyan,
                  inactiveTrackColor: AppColors.neonCyan.withOpacity(0.3),
                  onChanged: (val) {
                    HapticFeedback.selectionClick();
                    _streamController.toggleMockMode(val);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background living particles reactive to the current decibels & motion
          Positioned.fill(
            child: AmbientParticleField(
              chaosFactor: snapshot.chaosFactor,
              primaryColor: activeAmbiance,
              secondaryColor: AppColors.neonPurple,
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Real-time Audio Wave Visualizer
                  GlassContainer(
                    padding: const EdgeInsets.all(12),
                    borderRadius: 22,
                    borderColor: isLocked
                        ? AppColors.neonCyan.withOpacity(0.8)
                        : activeAmbiance.withOpacity(0.4),
                    borderWidth: isLocked ? 1.8 : 1.2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.waves_rounded, size: 16, color: AppColors.neonCyan),
                                SizedBox(width: 6),
                                Text(
                                  'ACOUSTIC SPECTRUM STREAM',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),
                            if (isLocked)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.neonCyan.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppColors.neonCyan, width: 1),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.lock_rounded, size: 11, color: AppColors.neonCyan),
                                    SizedBox(width: 4),
                                    Text(
                                      'SNAPSHOT FROZEN',
                                      style: TextStyle(
                                        color: AppColors.neonCyan,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        AudioWaveVisualizer(
                          decibels: snapshot.decibelLevel,
                          height: 110,
                          waveColor: activeAmbiance,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Real-time 3D Gyro Tilt Reaction Card
                  GyroTiltCard(
                    snapshot: snapshot,
                    height: 165,
                    interactive: !isLocked,
                  ),

                  const SizedBox(height: 16),

                  // "Capture Telemetry" Button with lock status
                  GestureDetector(
                    onTap: _handleCaptureTelemetry,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        gradient: isLocked
                            ? LinearGradient(
                                colors: [
                                  AppColors.neonCyan.withOpacity(0.8),
                                  AppColors.neonPurple.withOpacity(0.8),
                                ],
                              )
                            : LinearGradient(
                                colors: [
                                  activeAmbiance.withOpacity(0.9),
                                  AppColors.neonPurple.withOpacity(0.9),
                                ],
                              ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: (isLocked ? AppColors.neonCyan : activeAmbiance)
                                .withOpacity(0.4),
                            blurRadius: 18,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isLocked ? Icons.lock_open_rounded : Icons.camera_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isLocked ? 'Unlock / Resample Telemetry' : 'Freeze Ambient Telemetry',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Mood Selector
                  const Text(
                    'SELECT MOOD FREQUENCY',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  MoodSelector(
                    selectedMood: _selectedMood,
                    onMoodSelected: (mood) {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedMood = mood);
                    },
                  ),

                  const SizedBox(height: 22),

                  // Title Input
                  const Text(
                    'MEMORY IDENTIFIER',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _titleCtrl,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'e.g. Midnight Train, Stargazing at Peak...',
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Journal Content Input
                  const Text(
                    'SENSORY REFLECTIONS & THOUGHTS',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _contentCtrl,
                    maxLines: 4,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      height: 1.5,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Describe what you are sensing or experiencing in this moment...',
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Tags Section
                  const Text(
                    'TELEMETRY TAGS',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _tagCtrl,
                          onSubmitted: _addTag,
                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                          decoration: const InputDecoration(
                            hintText: 'Add tag (e.g. Acoustic, HighAltitude, Commute)...',
                            contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => _addTag(_tagCtrl.text),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.glassFill,
                          side: const BorderSide(color: AppColors.glassBorder),
                        ),
                        icon: const Icon(Icons.add_rounded, color: AppColors.neonCyan),
                      ),
                    ],
                  ),

                  if (_tags.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: _tags.map((tag) {
                        return Chip(
                          backgroundColor: AppColors.glassFill,
                          side: const BorderSide(color: AppColors.glassBorder),
                          label: Text(
                            '#$tag',
                            style: const TextStyle(
                              color: AppColors.neonCyan,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          deleteIcon: const Icon(Icons.close_rounded, size: 14, color: AppColors.textMuted),
                          onDeleted: () => _removeTag(tag),
                        );
                      }).toList(),
                    ),
                  ],

                  const SizedBox(height: 30),

                  // Final Store Button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveEntry,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.neonPurple,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        elevation: 10,
                        shadowColor: AppColors.neonPurple.withOpacity(0.5),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 20),
                                SizedBox(width: 10),
                                Text(
                                  'Encode & Save Memory',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
