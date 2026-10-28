import '../../domain/models/journal_entry.dart';
import '../../domain/repositories/journal_repository.dart';
import '../datasources/local_storage_datasource.dart';

class JournalRepositoryImpl implements JournalRepository {
  final LocalStorageDataSource _localDataSource;

  JournalRepositoryImpl(this._localDataSource);

  @override
  Future<List<JournalEntry>> getEntries() async {
    return await _localDataSource.getEntries();
  }

  @override
  Future<void> saveEntry(JournalEntry entry) async {
    await _localDataSource.saveEntry(entry);
  }

  @override
  Future<void> deleteEntry(String id) async {
    await _localDataSource.deleteEntry(id);
  }

  @override
  Future<void> updateEntry(JournalEntry entry) async {
    await _localDataSource.saveEntry(entry);
  }

  @override
  Future<void> clearAllEntries() async {
    await _localDataSource.clearAll();
  }
}
