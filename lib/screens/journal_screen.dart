import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/journal_provider.dart';
import '../models/journal_entry.dart';
import '../widgets/journal_entry_card.dart';
import '../widgets/add_journal_entry_dialog.dart';

class JournalScreen extends ConsumerWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(journalLoaderProvider, (previous, next) {
      next.when(
        data: (entries) => ref.read(journalProvider.notifier).loadEntries(entries),
        loading: () {},
        error: (error, stack) {},
      );
    });

    final filteredEntries = ref.watch(filteredEntriesProvider);
    final currentFilter = ref.watch(entryFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          PopupMenuButton<JournalType?>(
            icon: const Icon(Icons.filter_list),
            onSelected: (filter) {
              ref.read(entryFilterProvider.notifier).state = filter;
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: null,
                child: Text('All Entries'),
              ),
              const PopupMenuItem(
                value: JournalType.personal,
                child: Text('Personal'),
              ),
              const PopupMenuItem(
                value: JournalType.nugget,
                child: Text('Nuggets'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: Text('All (${filteredEntries.length})'),
                    selected: currentFilter == null,
                    onSelected: (selected) {
                      if (selected) {
                        ref.read(entryFilterProvider.notifier).state = null;
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ChoiceChip(
                    label: Text('Personal (${ref.watch(personalEntriesProvider).length})'),
                    selected: currentFilter == JournalType.personal,
                    onSelected: (selected) {
                      if (selected) {
                        ref.read(entryFilterProvider.notifier).state = JournalType.personal;
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ChoiceChip(
                    label: Text('Nuggets (${ref.watch(nuggetEntriesProvider).length})'),
                    selected: currentFilter == JournalType.nugget,
                    onSelected: (selected) {
                      if (selected) {
                        ref.read(entryFilterProvider.notifier).state = JournalType.nugget;
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: filteredEntries.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.book, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No journal entries yet!', 
                             style: TextStyle(fontSize: 18, color: Colors.grey)),
                        SizedBox(height: 8),
                        Text('Tap + to add your first entry',
                             style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredEntries.length,
                    itemBuilder: (context, index) {
                      final entry = filteredEntries[index];
                      return JournalEntryCard(
                        key: ValueKey(entry.id),
                        entry: entry,
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEntryDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Entry'),
      ),
    );
  }

  void _showAddEntryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddJournalEntryDialog(),
    );
  }
} 