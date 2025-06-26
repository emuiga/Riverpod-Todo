import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/journal_entry.dart';
import '../services/storage_service.dart';

class JournalNotifier extends StateNotifier<List<JournalEntry>> {
  JournalNotifier() : super([]);

  void addEntry(JournalEntry entry) {
    state = [...state, entry];
    _saveToStorage();
  }

  void updateEntry(String id, JournalEntry updatedEntry) {
    state = state.map((entry) {
      return entry.id == id ? updatedEntry : entry;
    }).toList();
    _saveToStorage();
  }

  void deleteEntry(String id) {
    state = state.where((entry) => entry.id != id).toList();
    _saveToStorage();
  }

  void loadEntries(List<JournalEntry> entries) {
    state = entries;
  }

  Future<void> _saveToStorage() async {
    await StorageService.saveJournalEntries(state);
  }
}

final journalProvider = StateNotifierProvider<JournalNotifier, List<JournalEntry>>((ref) {
  return JournalNotifier();
});

final journalLoaderProvider = FutureProvider<List<JournalEntry>>((ref) async {
  return await StorageService.loadJournalEntries();
});

final personalEntriesProvider = Provider<List<JournalEntry>>((ref) {
  final entries = ref.watch(journalProvider);
  return entries.where((entry) => entry.type == JournalType.personal).toList()
    ..sort((a, b) => b.date.compareTo(a.date));
});

final nuggetEntriesProvider = Provider<List<JournalEntry>>((ref) {
  final entries = ref.watch(journalProvider);
  return entries.where((entry) => entry.type == JournalType.nugget).toList()
    ..sort((a, b) => b.date.compareTo(a.date));
});

final entryFilterProvider = StateProvider<JournalType?>((ref) => null);

final filteredEntriesProvider = Provider<List<JournalEntry>>((ref) {
  final entries = ref.watch(journalProvider);
  final filter = ref.watch(entryFilterProvider);
  
  final filtered = filter == null 
      ? entries 
      : entries.where((entry) => entry.type == filter).toList();
  
  return filtered..sort((a, b) => b.date.compareTo(a.date));
}); 