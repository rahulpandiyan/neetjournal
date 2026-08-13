import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

enum FocusPhase {
  idle,
  focusing,
  paused,
  sessionComplete,
  breaking,
  breakPaused,
  breakComplete,
  finished,
}

class FocusState {
  const FocusState({
    this.phase = FocusPhase.idle,
    this.focusDuration = const Duration(minutes: 50),
    this.breakDuration = const Duration(minutes: 10),
    this.subjectName = '',
    this.title = '',
    this.target,
    this.subjectId,
    this.slotId,
    this.startedAt,
    this.endTime,
  });

  final FocusPhase phase;
  final Duration focusDuration;
  final Duration breakDuration;
  final String subjectName;
  final String title;
  final String? target;
  final int? subjectId;
  final int? slotId;
  final DateTime? startedAt;
  final DateTime? endTime;

  /// Remaining time in the current phase (computed for display).
  Duration remaining([DateTime? now]) {
    final ref = now ?? DateTime.now();
    if (phase == FocusPhase.focusing || phase == FocusPhase.breaking) {
      return endTime != null ? endTime!.difference(ref) : focusDuration;
    }
    if (phase == FocusPhase.paused || phase == FocusPhase.breakPaused) {
      return endTime != null ? endTime!.difference(ref) : Duration.zero;
    }
    return Duration.zero;
  }

  FocusState copyWith({
    FocusPhase? phase,
    Duration? focusDuration,
    Duration? breakDuration,
    String? subjectName,
    String? title,
    String? target,
    int? subjectId,
    int? slotId,
    DateTime? startedAt,
    DateTime? endTime,
    bool clearEndTime = false,
  }) {
    return FocusState(
      phase: phase ?? this.phase,
      focusDuration: focusDuration ?? this.focusDuration,
      breakDuration: breakDuration ?? this.breakDuration,
      subjectName: subjectName ?? this.subjectName,
      title: title ?? this.title,
      target: target ?? this.target,
      subjectId: subjectId ?? this.subjectId,
      slotId: slotId ?? this.slotId,
      startedAt: startedAt ?? this.startedAt,
      endTime: clearEndTime ? null : (endTime ?? this.endTime),
    );
  }
}

/// In-app Pomodoro state machine. Runs a 1-second ticker while focusing or
/// breaking; all deadlines are end-time based so they survive a paused clock.
class FocusController extends Notifier<FocusState> {
  Timer? _ticker;

  @override
  FocusState build() {
    ref.onDispose(() => _ticker?.cancel());
    return const FocusState();
  }

  void _ensureTicker() {
    _ticker ??= Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  void _tick() {
    final now = DateTime.now();
    final state = this.state;
    if (state.phase == FocusPhase.focusing ||
        state.phase == FocusPhase.breaking) {
      final remaining = state.endTime!.difference(now);
      if (remaining <= Duration.zero) {
        _stopTicker();
        if (state.phase == FocusPhase.focusing) {
          this.state = state.copyWith(
            phase: FocusPhase.sessionComplete,
            clearEndTime: true,
          );
        } else {
          this.state = state.copyWith(
            phase: FocusPhase.breakComplete,
            clearEndTime: true,
          );
        }
      } else {
        this.state = state.copyWith(endTime: state.endTime);
      }
    }
  }

  void startFocus({
    int? slotId,
    int? subjectId,
    required String subjectName,
    required String title,
    String? target,
    int? focusMinutes,
    int? breakMinutes,
  }) {
    final state = this.state;
    this.state = state.copyWith(
      phase: FocusPhase.focusing,
      slotId: slotId,
      subjectId: subjectId,
      subjectName: subjectName,
      title: title,
      target: target,
      focusDuration: Duration(
        minutes: focusMinutes ?? state.focusDuration.inMinutes,
      ),
      breakDuration: Duration(
        minutes: breakMinutes ?? state.breakDuration.inMinutes,
      ),
      startedAt: DateTime.now(),
      endTime: DateTime.now().add(
        Duration(minutes: focusMinutes ?? state.focusDuration.inMinutes),
      ),
    );
    _ensureTicker();
  }

  void pause() {
    final s = state;
    if (s.phase != FocusPhase.focusing) return;
    _stopTicker();
    state = s.copyWith(
      phase: FocusPhase.paused,
      endTime: DateTime.now().add(s.remaining()),
    );
  }

  void resume() {
    final s = state;
    if (s.phase != FocusPhase.paused) return;
    state = s.copyWith(
      phase: FocusPhase.focusing,
      endTime: DateTime.now().add(s.remaining()),
    );
    _ensureTicker();
  }

  /// Finish the focus phase (button or auto). Never finished early counts as a
  /// completed focus; the completion flow records the outcome.
  void finish() {
    final s = state;
    if (s.phase != FocusPhase.focusing && s.phase != FocusPhase.paused) return;
    _stopTicker();
    state = s.copyWith(phase: FocusPhase.sessionComplete, clearEndTime: true);
  }

  void startBreak() {
    final s = state;
    if (s.phase != FocusPhase.sessionComplete &&
        s.phase != FocusPhase.breakComplete) {
      return;
    }
    state = s.copyWith(
      phase: FocusPhase.breaking,
      endTime: DateTime.now().add(s.breakDuration),
    );
    _ensureTicker();
  }

  void pauseBreak() {
    final s = state;
    if (s.phase != FocusPhase.breaking) return;
    _stopTicker();
    state = s.copyWith(
      phase: FocusPhase.breakPaused,
      endTime: DateTime.now().add(s.remaining()),
    );
  }

  void resumeBreak() {
    final s = state;
    if (s.phase != FocusPhase.breakPaused) return;
    state = s.copyWith(
      phase: FocusPhase.breaking,
      endTime: DateTime.now().add(s.remaining()),
    );
    _ensureTicker();
  }

  void skipBreak() {
    final s = state;
    if (s.phase != FocusPhase.breaking && s.phase != FocusPhase.breakPaused) {
      return;
    }
    _stopTicker();
    state = s.copyWith(phase: FocusPhase.breakComplete, clearEndTime: true);
  }

  /// "I'm tired" → start a break of [minutes] right away.
  void tiredBreak(int minutes) {
    final s = state;
    if (s.phase != FocusPhase.focusing && s.phase != FocusPhase.paused) return;
    _stopTicker();
    state = s.copyWith(
      phase: FocusPhase.breaking,
      breakDuration: Duration(minutes: minutes),
      endTime: DateTime.now().add(Duration(minutes: minutes)),
    );
    _ensureTicker();
  }

  /// "I'm tired" → end the session immediately (completion flow follows).
  void endTired() => endSession();

  /// End the session right now (early-stop or "I'm tired"). The completion
  /// flow follows and records the actual outcome.
  void endSession() {
    final s = state;
    if (s.phase != FocusPhase.focusing && s.phase != FocusPhase.paused) return;
    _stopTicker();
    state = s.copyWith(phase: FocusPhase.finished, clearEndTime: true);
  }

  /// "Start next session" — the focus flow is complete; reset for the next one.
  void nextSession() => reset();

  void reset() {
    _stopTicker();
    state = const FocusState();
  }
}

final focusControllerProvider = NotifierProvider<FocusController, FocusState>(
  FocusController.new,
);
