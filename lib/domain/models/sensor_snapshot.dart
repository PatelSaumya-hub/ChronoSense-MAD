import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class SensorSnapshot {
  final double accelX;
  final double accelY;
  final double accelZ;
  final double gyroX;
  final double gyroY;
  final double gyroZ;
  final double decibelLevel;
  final double movementScore; // Normalized 0.0 - 100.0
  final double pitch; // Radians for 3D card tilt
  final double roll;  // Radians for 3D card tilt
  final bool isSimulated;
  final DateTime timestamp;

  const SensorSnapshot({
    required this.accelX,
    required this.accelY,
    required this.accelZ,
    required this.gyroX,
    required this.gyroY,
    required this.gyroZ,
    required this.decibelLevel,
    required this.movementScore,
    required this.pitch,
    required this.roll,
    required this.isSimulated,
    required this.timestamp,
  });

  /// Factory constructor for a calm, baseline sensory state
  factory SensorSnapshot.calmBaseline({bool isSimulated = true}) {
    return SensorSnapshot(
      accelX: 0.0,
      accelY: 0.1,
      accelZ: 9.8,
      gyroX: 0.0,
      gyroY: 0.0,
      gyroZ: 0.0,
      decibelLevel: 36.5,
      movementScore: 8.0,
      pitch: 0.0,
      roll: 0.0,
      isSimulated: isSimulated,
      timestamp: DateTime.now(),
    );
  }

  /// Calculates a combined sensory chaos factor from 0.0 (utterly serene) to 1.0 (ultra turbulent)
  double get chaosFactor {
    final normDb = ((decibelLevel - 30.0) / 60.0).clamp(0.0, 1.0);
    final normMotion = (movementScore / 100.0).clamp(0.0, 1.0);
    return (normDb * 0.5 + normMotion * 0.5).clamp(0.0, 1.0);
  }

  /// Categorical audio description label
  String get soundCategoryLabel {
    if (decibelLevel < 42) return '${decibelLevel.toStringAsFixed(0)} dB • Serene Whisper';
    if (decibelLevel < 58) return '${decibelLevel.toStringAsFixed(0)} dB • Gentle Murmur';
    if (decibelLevel < 74) return '${decibelLevel.toStringAsFixed(0)} dB • Ambient Buzz';
    if (decibelLevel < 88) return '${decibelLevel.toStringAsFixed(0)} dB • Energetic Pulse';
    return '${decibelLevel.toStringAsFixed(0)} dB • Chaotic Surge';
  }

  /// Categorical movement description label
  String get motionCategoryLabel {
    if (movementScore < 20) return '${movementScore.toStringAsFixed(0)}% • Grounded Stillness';
    if (movementScore < 45) return '${movementScore.toStringAsFixed(0)}% • Gentle Drift';
    if (movementScore < 70) return '${movementScore.toStringAsFixed(0)}% • Active Rhythm';
    return '${movementScore.toStringAsFixed(0)}% • High Turbulence';
  }

  /// Dominant ambiance glow color depending on decibels and movement
  Color get dominantAmbianceColor {
    final chaos = chaosFactor;
    if (chaos < 0.25) {
      return AppColors.neonCyan;
    } else if (chaos < 0.55) {
      return AppColors.neonPurple;
    } else if (chaos < 0.8) {
      return AppColors.neonAmber;
    } else {
      return AppColors.neonPink;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'accelX': accelX,
      'accelY': accelY,
      'accelZ': accelZ,
      'gyroX': gyroX,
      'gyroY': gyroY,
      'gyroZ': gyroZ,
      'decibelLevel': decibelLevel,
      'movementScore': movementScore,
      'pitch': pitch,
      'roll': roll,
      'isSimulated': isSimulated,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory SensorSnapshot.fromMap(Map<String, dynamic> map) {
    return SensorSnapshot(
      accelX: (map['accelX'] as num?)?.toDouble() ?? 0.0,
      accelY: (map['accelY'] as num?)?.toDouble() ?? 0.0,
      accelZ: (map['accelZ'] as num?)?.toDouble() ?? 9.8,
      gyroX: (map['gyroX'] as num?)?.toDouble() ?? 0.0,
      gyroY: (map['gyroY'] as num?)?.toDouble() ?? 0.0,
      gyroZ: (map['gyroZ'] as num?)?.toDouble() ?? 0.0,
      decibelLevel: (map['decibelLevel'] as num?)?.toDouble() ?? 40.0,
      movementScore: (map['movementScore'] as num?)?.toDouble() ?? 10.0,
      pitch: (map['pitch'] as num?)?.toDouble() ?? 0.0,
      roll: (map['roll'] as num?)?.toDouble() ?? 0.0,
      isSimulated: map['isSimulated'] as bool? ?? false,
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  SensorSnapshot copyWith({
    double? accelX,
    double? accelY,
    double? accelZ,
    double? gyroX,
    double? gyroY,
    double? gyroZ,
    double? decibelLevel,
    double? movementScore,
    double? pitch,
    double? roll,
    bool? isSimulated,
    DateTime? timestamp,
  }) {
    return SensorSnapshot(
      accelX: accelX ?? this.accelX,
      accelY: accelY ?? this.accelY,
      accelZ: accelZ ?? this.accelZ,
      gyroX: gyroX ?? this.gyroX,
      gyroY: gyroY ?? this.gyroY,
      gyroZ: gyroZ ?? this.gyroZ,
      decibelLevel: decibelLevel ?? this.decibelLevel,
      movementScore: movementScore ?? this.movementScore,
      pitch: pitch ?? this.pitch,
      roll: roll ?? this.roll,
      isSimulated: isSimulated ?? this.isSimulated,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
