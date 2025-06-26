import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task_filter.dart';
import '../providers/task_provider.dart';

/// Widget displaying filter chips for task filtering
/// 
/// Demonstrates StateProvider usage - both watching for UI updates
/// and updating the state when user selects a different filter.
class FilterChips extends ConsumerWidget {
  const FilterChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the current filter - UI rebuilds when this changes
    final currentFilter = ref.watch(taskFilterProvider);
    
    // Get task counts for displaying on chips
    final allCount = ref.watch(taskCountProvider);
    final completedCount = ref.watch(completedTaskCountProvider);
    final pendingCount = ref.watch(pendingTaskCountProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: TaskFilter.values.map((filter) {
          final count = switch (filter) {
            TaskFilter.all => allCount,
            TaskFilter.done => completedCount,
            TaskFilter.notDone => pendingCount,
          };

          return ChoiceChip(
            label: Text('${filter.label} ($count)'),
            selected: currentFilter == filter,
            onSelected: (selected) {
              if (selected) {
                // Update the filter state using ref.read()
                // This will cause filteredTasksProvider to recalculate
                ref.read(taskFilterProvider.notifier).state = filter;
              }
            },
            selectedColor: Theme.of(context).colorScheme.primaryContainer,
            labelStyle: TextStyle(
              color: currentFilter == filter
                  ? Theme.of(context).colorScheme.onPrimaryContainer
                  : null,
            ),
          );
        }).toList(),
      ),
    );
  }
} 