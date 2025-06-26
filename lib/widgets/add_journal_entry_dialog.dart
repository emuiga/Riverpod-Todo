import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/journal_entry.dart';
import '../providers/journal_provider.dart';

class AddJournalEntryDialog extends ConsumerStatefulWidget {
  const AddJournalEntryDialog({super.key});

  @override
  ConsumerState<AddJournalEntryDialog> createState() => _AddJournalEntryDialogState();
}

class _AddJournalEntryDialogState extends ConsumerState<AddJournalEntryDialog> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _sourceController = TextEditingController();
  final _tagsController = TextEditingController();
  
  JournalType _selectedType = JournalType.personal;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _sourceController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Journal Entry'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<JournalType>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Entry Type',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: JournalType.personal,
                  child: Text('Personal'),
                ),
                DropdownMenuItem(
                  value: JournalType.nugget,
                  child: Text('Nugget'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedType = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: 'Content',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            
            if (_selectedType == JournalType.nugget)
              TextField(
                controller: _sourceController,
                decoration: const InputDecoration(
                  labelText: 'Source (book, article, etc.)',
                  border: OutlineInputBorder(),
                ),
              ),
            if (_selectedType == JournalType.nugget) const SizedBox(height: 16),
            
            TextField(
              controller: _tagsController,
              decoration: const InputDecoration(
                labelText: 'Tags (comma separated)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _addEntry,
          child: const Text('Add Entry'),
        ),
      ],
    );
  }

  void _addEntry() {
    if (_titleController.text.trim().isEmpty || _contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in title and content')),
      );
      return;
    }

    final tags = _tagsController.text
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();

    final entry = JournalEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      type: _selectedType,
      date: DateTime.now(),
      source: _sourceController.text.trim().isEmpty ? null : _sourceController.text.trim(),
      tags: tags,
    );

    ref.read(journalProvider.notifier).addEntry(entry);
    Navigator.of(context).pop();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Journal entry added')),
    );
  }
} 