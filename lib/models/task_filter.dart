/// Filter options for displaying tasks
/// 
/// This enum will be used with a StateProvider to manage the current filter.
/// Simple enums work well with StateProvider for toggleable states.
enum TaskFilter {
  all('All'),
  done('Completed'),
  notDone('Pending');

  const TaskFilter(this.label);
  final String label;
} 