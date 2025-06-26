import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/timer_state.dart';

class TimerNotifier extends StateNotifier<TimerState> {
  TimerNotifier() : super(const TimerState());
  Timer? _timer;

  void startTimer() {
    if (state.status == TimerStatus.idle) {
      _resetTimer();
    }
    
    state = state.copyWith(status: TimerStatus.running);
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.remainingSeconds <= 0) {
        _completeSession();
      } else {
        state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
      }
    });
  }

  void pauseTimer() {
    _timer?.cancel();
    state = state.copyWith(status: TimerStatus.paused);
  }

  void resetTimer() {
    _timer?.cancel();
    _resetTimer();
    state = state.copyWith(status: TimerStatus.idle);
  }

  void _resetTimer() {
    final seconds = state.sessionType == SessionType.work ? 1500 : 300;
    state = state.copyWith(remainingSeconds: seconds);
  }

  void _completeSession() {
    _timer?.cancel();
    
    final newCompletedSessions = state.completedSessions + 1;
    SessionType nextSession;
    
    if (state.sessionType == SessionType.work) {
      nextSession = newCompletedSessions % 4 == 0 
          ? SessionType.longBreak 
          : SessionType.shortBreak;
    } else {
      nextSession = SessionType.work;
    }
    
    state = state.copyWith(
      status: TimerStatus.idle,
      sessionType: nextSession,
      completedSessions: newCompletedSessions,
    );
    
    _resetTimer();
  }

  void switchToWork() {
    if (state.status == TimerStatus.running) return;
    state = state.copyWith(sessionType: SessionType.work);
    _resetTimer();
  }

  void switchToBreak() {
    if (state.status == TimerStatus.running) return;
    state = state.copyWith(sessionType: SessionType.shortBreak);
    _resetTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final timerProvider = StateNotifierProvider<TimerNotifier, TimerState>((ref) {
  return TimerNotifier();
});

final isTimerRunningProvider = Provider<bool>((ref) {
  return ref.watch(timerProvider).status == TimerStatus.running;
});

final currentSessionTypeProvider = Provider<SessionType>((ref) {
  return ref.watch(timerProvider).sessionType;
}); 