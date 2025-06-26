import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/timer_provider.dart';
import '../models/timer_state.dart';

class TimerScreen extends ConsumerWidget {
  const TimerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(timerProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pomodoro Timer'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _getSessionLabel(timerState.sessionType),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            
            Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: CircularProgressIndicator(
                      value: timerState.progress,
                      strokeWidth: 8,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getSessionColor(timerState.sessionType),
                      ),
                    ),
                  ),
                  Text(
                    timerState.formattedTime,
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: timerState.status == TimerStatus.running
                      ? () => ref.read(timerProvider.notifier).pauseTimer()
                      : () => ref.read(timerProvider.notifier).startTimer(),
                  icon: Icon(
                    timerState.status == TimerStatus.running
                        ? Icons.pause
                        : Icons.play_arrow,
                  ),
                  label: Text(
                    timerState.status == TimerStatus.running ? 'Pause' : 'Start',
                  ),
                ),
                
                ElevatedButton.icon(
                  onPressed: () => ref.read(timerProvider.notifier).resetTimer(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset'),
                ),
              ],
            ),
            
            const SizedBox(height: 40),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ChoiceChip(
                  label: const Text('Work'),
                  selected: timerState.sessionType == SessionType.work,
                  onSelected: (selected) {
                    if (selected) {
                      ref.read(timerProvider.notifier).switchToWork();
                    }
                  },
                ),
                ChoiceChip(
                  label: const Text('Break'),
                  selected: timerState.sessionType != SessionType.work,
                  onSelected: (selected) {
                    if (selected) {
                      ref.read(timerProvider.notifier).switchToBreak();
                    }
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            Text(
              'Completed Sessions: ${timerState.completedSessions}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }

  String _getSessionLabel(SessionType type) {
    switch (type) {
      case SessionType.work:
        return 'Work Session';
      case SessionType.shortBreak:
        return 'Short Break';
      case SessionType.longBreak:
        return 'Long Break';
    }
  }

  Color _getSessionColor(SessionType type) {
    switch (type) {
      case SessionType.work:
        return Colors.red;
      case SessionType.shortBreak:
        return Colors.green;
      case SessionType.longBreak:
        return Colors.blue;
    }
  }
} 