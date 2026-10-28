import 'package:flutter/foundation.dart';
import '../../domain/models/journal_entry.dart';
import '../../domain/models/mood_type.dart';
import '../../domain/repositories/journal_repository.dart';

class JournalController extends ChangeNotifier {
  final JournalRepository _repository;

  List<JournalEntry> _allEntries = [];
  bool _isLoading = true;
  String _searchQuery = '';
  MoodType? _selectedMoodFilter;

  JournalController(this._repository);

  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  MoodType? get selectedMoodFilter => _selectedMoodFilter;

  List<JournalEntry> get filteredEntries {
    return _allEntries.where((entry) {
      final matchesSearch = _searchQuery.isEmpty ||
          entry.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          entry.content.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          entry.tags.any((t) => t.toLowerCase().contains(_searchQuery.toLowerCase()));

      final matchesMood = _selectedMoodFilter == null || entry.mood == _selectedMoodFilter;

      return matchesSearch && matchesMood;
    }).toList();
  }

  int get totalEntriesCount => _allEntries.length;

  double get averageDecibels {
    if (_allEntries.isEmpty) return 0.0;
    final sum = _allEntries.fold<double>(
        0.0, (prev, e) => prev + e.sensorSnapshot.decibelLevel);
    return sum / _allEntries.length;
  }

  double get averageMovement {
    if (_allEntries.isEmpty) return 0.0;
    final sum = _allEntries.fold<double>(
        0.0, (prev, e) => prev + e.sensorSnapshot.movementScore);
    return sum / _allEntries.length;
  }

  Future<void> loadEntries() async {
    _isLoading = true;
    notifyListeners();
    try {
      _allEntries = await _repository.getEntries();
    } catch (e) {
      debugPrint('ChronoSense: Error loading entries: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setMoodFilter(MoodType? mood) {
    _selectedMoodFilter = mood;
    notifyListeners();
  }

  Future<void> addEntry(JournalEntry entry) async {
    await _repository.saveEntry(entry);
    _allEntries.insert(0, entry);
    notifyListeners();
  }

  Future<void> deleteEntry(String id) async {
    await _repository.deleteEntry(id);
    _allEntries.removeWhere((e) => e.id == id);
    notifyListeners();
  }
}
