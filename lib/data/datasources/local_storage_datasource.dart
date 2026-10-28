import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/journal_entry.dart';
import '../../domain/models/mood_type.dart';
import '../../domain/models/sensor_snapshot.dart';

class LocalStorageDataSource {
  static const String _entriesKey = 'chronosense_journal_entries_v1';
  static const String _initializedKey = 'chronosense_seeded_v1';

  final SharedPreferences _prefs;

  LocalStorageDataSource(this._prefs);

  static Future<LocalStorageDataSource> create() async {
    final prefs = await SharedPreferences.getInstance();
    final dataSource = LocalStorageDataSource(prefs);
    await dataSource._seedInitialEntriesIfNeeded();
    return dataSource;
  }

  Future<void> _seedInitialEntriesIfNeeded() async {
    final hasSeeded = _prefs.getBool(_initializedKey) ?? false;
    final existingData = _prefs.getString(_entriesKey);

    if (!hasSeeded || existingData == null || existingData.isEmpty) {
      final now = DateTime.now();
      final initialEntries = [
        JournalEntry(
          id: 'seed-entry-1',
          title: 'Midnight Astronomy Peak',
          content: 'The valley was submerged in silence. Only faint mountain air brushing against the obsidian rocks. A tranquil feeling of deep alignment with the cosmos.',
          createdAt: now.subtract(const Duration(hours: 3, minutes: 12)),
          mood: MoodType.serene,
          sensorSnapshot: SensorSnapshot(
            accelX: 0.05,
            accelY: 0.12,
            accelZ: 9.78,
            gyroX: 0.01,
            gyroY: 0.02,
            gyroZ: 0.01,
            decibelLevel: 31.2,
            movementScore: 7.5,
            pitch: 0.02,
            roll: 0.01,
            isSimulated: true,
            timestamp: now.subtract(const Duration(hours: 3, minutes: 12)),
          ),
          tags: ['Astronomy', 'Night', 'Zen'],
        ),
        JournalEntry(
          id: 'seed-entry-2',
          title: 'Neon Metro Transit Pulse',
          content: 'Subway speeding through the underground corridor. Neon reflections dancing across vibrating metallic glass doors. A rush of adrenaline and metropolitan rhythm.',
          createdAt: now.subtract(const Duration(days: 1, hours: 5)),
          mood: MoodType.energetic,
          sensorSnapshot: SensorSnapshot(
            accelX: 2.15,
            accelY: -1.82,
            accelZ: 9.94,
            gyroX: 0.42,
            gyroY: -0.38,
            gyroZ: 0.51,
            decibelLevel: 82.4,
            movementScore: 86.0,
            pitch: 0.28,
            roll: -0.22,
            isSimulated: true,
            timestamp: now.subtract(const Duration(days: 1, hours: 5)),
          ),
          tags: ['Commute', 'Adrenaline', 'Cyber'],
        ),
        JournalEntry(
          id: 'seed-entry-3',
          title: 'Rainy Loft Architecture Study',
          content: 'Rain drops tapping persistently against the skylight window. Steam rising steadily from hot oolong tea. Writing down project concepts while the world slows down.',
          createdAt: now.subtract(const Duration(days: 2, hours: 2)),
          mood: MoodType.reflective,
          sensorSnapshot: SensorSnapshot(
            accelX: 0.18,
            accelY: -0.14,
            accelZ: 9.81,
            gyroX: 0.04,
            gyroY: 0.03,
            gyroZ: -0.02,
            decibelLevel: 51.7,
            movementScore: 24.0,
            pitch: -0.05,
            roll: 0.04,
            isSimulated: true,
            timestamp: now.subtract(const Duration(days: 2, hours: 2)),
          ),
          tags: ['Rain', 'Tea', 'DeepFocus'],
        ),
      ];

      await saveEntries(initialEntries);
      await _prefs.setBool(_initializedKey, true);
    }
  }

  Future<List<JournalEntry>> getEntries() async {
    final jsonString = _prefs.getString(_entriesKey);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList
          .map((item) => JournalEntry.fromMap(Map<String, dynamic>.from(item as Map)))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      return [];
    }
  }

  Future<void> saveEntries(List<JournalEntry> entries) async {
    final listMap = entries.map((e) => e.toMap()).toList();
    final jsonString = jsonEncode(listMap);
    await _prefs.setString(_entriesKey, jsonString);
  }

  Future<void> saveEntry(JournalEntry entry) async {
    final currentEntries = await getEntries();
    final existingIndex = currentEntries.indexWhere((e) => e.id == entry.id);

    if (existingIndex >= 0) {
      currentEntries[existingIndex] = entry;
    } else {
      currentEntries.insert(0, entry);
    }

    await saveEntries(currentEntries);
  }

  Future<void> deleteEntry(String id) async {
    final currentEntries = await getEntries();
    currentEntries.removeWhere((e) => e.id == id);
    await saveEntries(currentEntries);
  }

  Future<void> clearAll() async {
    await _prefs.remove(_entriesKey);
  }
}
