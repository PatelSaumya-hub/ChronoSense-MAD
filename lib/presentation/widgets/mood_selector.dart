import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/models/mood_type.dart';

class MoodSelector extends StatelessWidget {
  final MoodType selectedMood;
  final ValueChanged<MoodType> onMoodSelected;

  const MoodSelector({
    super.key,
    required this.selectedMood,
    required this.onMoodSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: MoodType.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final mood = MoodType.values[index];
          final isSelected = mood == selectedMood;

          return GestureDetector(
            onTap: () => onMoodSelected(mood),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? mood.accentColor.withOpacity(0.22)
                    : AppColors.glassFill,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? mood.accentColor : AppColors.glassBorder,
                  width: isSelected ? 1.6 : 1.0,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: mood.accentColor.withOpacity(0.35),
                          blurRadius: 14,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    mood.emoji,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    mood.label,
                    style: TextStyle(
                      color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
