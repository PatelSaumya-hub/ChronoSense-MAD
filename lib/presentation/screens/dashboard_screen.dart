import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../domain/models/journal_entry.dart';
import '../../domain/models/mood_type.dart';
import '../../domain/repositories/sensor_service.dart';
import '../providers/journal_controller.dart';
import '../widgets/ambient_particle_field.dart';
import '../widgets/glass_container.dart';
import '../widgets/sensor_badge_pill.dart';
import 'capture_screen.dart';
import 'entry_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  final JournalController journalController;
  final SensorService sensorService;

  const DashboardScreen({
    super.key,
    required this.journalController,
    required this.sensorService,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.journalController.addListener(_onStateChange);
  }

  @override
  void dispose() {
    widget.journalController.removeListener(_onStateChange);
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onStateChange() {
    if (mounted) setState(() {});
  }

  void _openCaptureScreen() async {
    final newEntry = await Navigator.of(context).push<JournalEntry>(
      MaterialPageRoute(
        builder: (context) => CaptureScreen(
          sensorService: widget.sensorService,
        ),
      ),
    );

    if (newEntry != null) {
      await widget.journalController.addEntry(newEntry);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.bgSurfaceLight,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: const BorderSide(color: AppColors.neonCyan, width: 1),
            ),
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: AppColors.neonCyan, size: 20),
                const SizedBox(width: 10),
                Text(
                  'Sensory memory encoded into timeline.',
                  style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        );
      }
    }
  }

  void _openEntryDetail(JournalEntry entry) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, anim, secondaryAnim) => EntryDetailScreen(
          entry: entry,
          onDelete: () async {
            await widget.journalController.deleteEntry(entry.id);
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          },
        ),
        transitionsBuilder: (context, anim, secondaryAnim, child) {
          return FadeTransition(opacity: anim, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.journalController;
    final entries = controller.filteredEntries;

    return Scaffold(
      backgroundColor: AppColors.bgObsidian,
      body: Stack(
        children: [
          // Ambient living particles reflecting the overall state
          Positioned.fill(
            child: AmbientParticleField(
              chaosFactor: 0.18,
              primaryColor: AppColors.neonPurple,
              secondaryColor: AppColors.neonCyan,
            ),
          ),

          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Top Header & Sensory HUD
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: const BoxDecoration(
                                        color: AppColors.neonCyan,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.neonCyan,
                                            blurRadius: 8,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'CHRONOSENSE',
                                      style: TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 2.0,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'Dynamic Sensory Memory Journal',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: AppColors.neonPurple.withOpacity(0.18),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppColors.neonPurple.withOpacity(0.5),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.bolt_rounded, size: 14, color: AppColors.neonPurple),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${controller.totalEntriesCount} Memories',
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),

                        // Sensory Telemetry Stats Ribbon
                        GlassContainer(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                          borderRadius: 20,
                          borderColor: AppColors.glassBorderGlow,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatItem(
                                'Acoustic Avg',
                                '${controller.averageDecibels.toStringAsFixed(0)} dB',
                                Icons.graphic_eq_rounded,
                                AppColors.neonCyan,
                              ),
                              Container(width: 1, height: 32, color: AppColors.glassBorder),
                              _buildStatItem(
                                'Motion Index',
                                '${controller.averageMovement.toStringAsFixed(0)}%',
                                Icons.vibration_rounded,
                                AppColors.neonPink,
                              ),
                              Container(width: 1, height: 32, color: AppColors.glassBorder),
                              _buildStatItem(
                                'Status',
                                'Sync Active',
                                Icons.sensors_rounded,
                                AppColors.neonGreen,
                              ),
                            ],
                          ),
                        ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, end: 0),

                        const SizedBox(height: 16),

                        // Search Field
                        TextField(
                          controller: _searchCtrl,
                          onChanged: controller.setSearchQuery,
                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'Search memories, keywords, or sensory tags...',
                            prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 20),
                            suffixIcon: _searchCtrl.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, color: AppColors.textMuted, size: 18),
                                    onPressed: () {
                                      _searchCtrl.clear();
                                      controller.setSearchQuery('');
                                    },
                                  )
                                : null,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Filter Chips by Mood
                        SizedBox(
                          height: 38,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            children: [
                              _buildFilterChip(
                                label: 'All Moods',
                                isSelected: controller.selectedMoodFilter == null,
                                color: AppColors.neonPurple,
                                onTap: () => controller.setMoodFilter(null),
                              ),
                              ...MoodType.values.map(
                                (mood) => _buildFilterChip(
                                  label: '${mood.emoji} ${mood.label}',
                                  isSelected: controller.selectedMoodFilter == mood,
                                  color: mood.accentColor,
                                  onTap: () => controller.setMoodFilter(
                                    controller.selectedMoodFilter == mood ? null : mood,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Journal Timeline Entries
                if (controller.isLoading)
                  const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.neonPurple),
                    ),
                  )
                else if (entries.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(22),
                              decoration: BoxDecoration(
                                color: AppColors.glassFillCard,
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.glassBorder, width: 1.5),
                              ),
                              child: const Icon(
                                Icons.hourglass_empty_rounded,
                                size: 40,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 18),
                            const Text(
                              'No Sensory Memories Found',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Tap the floating crystal below to capture your first ambient sensory memory.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 90),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final entry = entries[index];
                          return _buildTimelineCard(entry, index);
                        },
                        childCount: entries.length,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCaptureScreen,
        backgroundColor: AppColors.neonPurple,
        elevation: 8,
        icon: const Icon(Icons.blur_on_rounded, color: Colors.white, size: 22),
        label: const Text(
          'Capture Telemetry',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ).animate().scale(delay: 300.ms, duration: 400.ms, curve: Curves.easeOutBack),
    );
  }

  Widget _buildTimelineCard(JournalEntry entry, int index) {
    final snapshot = entry.sensorSnapshot;
    final ambianceColor = snapshot.dominantAmbianceColor;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: GlassContainer(
        borderRadius: 22,
        borderColor: ambianceColor.withOpacity(0.35),
        borderWidth: 1.2,
        fillColor: AppColors.glassFillCard,
        shadows: [
          BoxShadow(
            color: ambianceColor.withOpacity(0.12),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
        onTap: () => _openEntryDetail(entry),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Mood Badge, Date, Chevron
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: entry.mood.accentColor.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: entry.mood.accentColor.withOpacity(0.6),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(entry.mood.emoji, style: const TextStyle(fontSize: 12)),
                          const SizedBox(width: 5),
                          Text(
                            entry.mood.label,
                            style: TextStyle(
                              color: entry.mood.accentColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      DateFormatter.formatEntryDate(entry.createdAt),
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 13,
                  color: ambianceColor.withOpacity(0.8),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Title
            Text(
              entry.title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
            ),

            const SizedBox(height: 6),

            // Content Snippet
            Text(
              entry.content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.45,
              ),
            ),

            const SizedBox(height: 14),

            // Sensor Badge Pills (Audio dB & Motion Score)
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                SensorBadgePill.audio(snapshot.decibelLevel),
                SensorBadgePill.motion(snapshot.movementScore),
                if (snapshot.isSimulated)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.neonAmber.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.neonAmber.withOpacity(0.4),
                        width: 0.8,
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.hub_rounded, size: 11, color: AppColors.neonAmber),
                        SizedBox(width: 4),
                        Text(
                          'Simulated',
                          style: TextStyle(
                            color: AppColors.neonAmber,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 350.ms, delay: (index * 60).ms).slideY(begin: 0.08, end: 0);
  }

  Widget _buildStatItem(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 5),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.w800,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.25) : AppColors.glassFill,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? color : AppColors.glassBorder,
              width: isSelected ? 1.4 : 1.0,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 10,
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
