enum TimerStatus { idle, running, paused }
enum SessionType { work, shortBreak, longBreak }

class TimerState {
  const TimerState({
    this.remainingSeconds = 1500,
    this.status = TimerStatus.idle,
    this.sessionType = SessionType.work,
    this.completedSessions = 0,
  });

  final int remainingSeconds;
  final TimerStatus status;
  final SessionType sessionType;
  final int completedSessions;

  TimerState copyWith({
    int? remainingSeconds,
    TimerStatus? status,
    SessionType? sessionType,
    int? completedSessions,
  }) {
    return TimerState(
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      status: status ?? this.status,
      sessionType: sessionType ?? this.sessionType,
      completedSessions: completedSessions ?? this.completedSessions,
    );
  }

  String get formattedTime {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  double get progress {
    final totalSeconds = sessionType == SessionType.work ? 1500 : 300;
    return (totalSeconds - remainingSeconds) / totalSeconds;
  }
} 