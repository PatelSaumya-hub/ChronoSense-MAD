import 'mood_type.dart';
import 'sensor_snapshot.dart';

class JournalEntry {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final MoodType mood;
  final SensorSnapshot sensorSnapshot;
  final List<String> tags;

  const JournalEntry({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.mood,
    required this.sensorSnapshot,
    this.tags = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'mood': mood.name,
      'sensorSnapshot': sensorSnapshot.toMap(),
      'tags': tags,
    };
  }

  factory JournalEntry.fromMap(Map<String, dynamic> map) {
    return JournalEntry(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? 'Sensory Fragment',
      content: map['content'] as String? ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      mood: MoodType.fromString(map['mood'] as String? ?? 'reflective'),
      sensorSnapshot: map['sensorSnapshot'] != null
          ? SensorSnapshot.fromMap(Map<String, dynamic>.from(map['sensorSnapshot'] as Map))
          : SensorSnapshot.calmBaseline(),
      tags: (map['tags'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  JournalEntry copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? createdAt,
    MoodType? mood,
    SensorSnapshot? sensorSnapshot,
    List<String>? tags,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      mood: mood ?? this.mood,
      sensorSnapshot: sensorSnapshot ?? this.sensorSnapshot,
      tags: tags ?? this.tags,
    );
  }
}
