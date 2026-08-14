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
    this.pausedRemaining,
    this.resumeFocusRemaining,
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

  /// Frozen countdown snapshot while paused. Kept separate from [endTime] so
  /// that `remaining()` does not keep draining against the wall clock while
  /// the timer is paused.
  final Duration? pausedRemaining;

  /// Remaining focus time captured when a mid-session break starts ("I'm
  /// tired"). When the break ends or is skipped, the interrupted focus session
  /// resumes with this much time left instead of restarting from zero.
  final Duration? resumeFocusRemaining;

  /// Remaining time in the current phase (computed for display).
  Duration remaining([DateTime? now]) {
    final ref = now ?? DateTime.now();
    if (phase == FocusPhase.focusing || phase == FocusPhase.breaking) {
      return endTime != null ? endTime!.difference(ref) : focusDuration;
    }
    if (phase == FocusPhase.paused || phase == FocusPhase.breakPaused) {
      return pausedRemaining ?? Duration.zero;
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
    Duration? pausedRemaining,
    Duration? resumeFocusRemaining,
    bool clearEndTime = false,
    bool clearPausedRemaining = false,
    bool clearResumeFocusRemaining = false,
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
      pausedRemaining: clearPausedRemaining
          ? null
          : (pausedRemaining ?? this.pausedRemaining),
      resumeFocusRemaining: clearResumeFocusRemaining
          ? null
          : (resumeFocusRemaining ?? this.resumeFocusRemaining),
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
        if (state.phase == FocusPhase.focusing) {
          _stopTicker();
          this.state = state.copyWith(
            phase: FocusPhase.sessionComplete,
            clearEndTime: true,
          );
          return;
        }
        // A break hit zero. If it interrupted a focus session ("I'm tired"),
        // resume that session with its remaining time instead of going to the
        // next-session prompt.
        final resume = state.resumeFocusRemaining;
        if (resume != null && resume > Duration.zero) {
          this.state = state.copyWith(
            phase: FocusPhase.focusing,
            endTime: now.add(resume),
            clearResumeFocusRemaining: true,
          );
        } else {
          _stopTicker();
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
      clearPausedRemaining: true,
      clearResumeFocusRemaining: true,
    );
    _ensureTicker();
  }

  void pause() {
    final s = state;
    if (s.phase != FocusPhase.focusing) return;
    _stopTicker();
    state = s.copyWith(
      phase: FocusPhase.paused,
      clearEndTime: true,
      pausedRemaining: s.remaining(),
    );
  }

  void resume() {
    final s = state;
    if (s.phase != FocusPhase.paused) return;
    state = s.copyWith(
      phase: FocusPhase.focusing,
      endTime: DateTime.now().add(s.remaining()),
      clearPausedRemaining: true,
    );
    _ensureTicker();
  }

  /// Finish the focus phase (button or auto). Never finished early counts as a
  /// completed focus; the completion flow records the outcome.
  void finish() {
    final s = state;
    if (s.phase != FocusPhase.focusing && s.phase != FocusPhase.paused) return;
    _stopTicker();
    state = s.copyWith(
      phase: FocusPhase.sessionComplete,
      clearEndTime: true,
      clearPausedRemaining: true,
      clearResumeFocusRemaining: true,
    );
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
      clearPausedRemaining: true,
      clearResumeFocusRemaining: true,
    );
    _ensureTicker();
  }

  void pauseBreak() {
    final s = state;
    if (s.phase != FocusPhase.breaking) return;
    _stopTicker();
    state = s.copyWith(
      phase: FocusPhase.breakPaused,
      clearEndTime: true,
      pausedRemaining: s.remaining(),
    );
  }

  void resumeBreak() {
    final s = state;
    if (s.phase != FocusPhase.breakPaused) return;
    state = s.copyWith(
      phase: FocusPhase.breaking,
      endTime: DateTime.now().add(s.remaining()),
      clearPausedRemaining: true,
    );
    _ensureTicker();
  }

  /// Skip the rest of the break.
  ///
  /// If the break interrupted a focus session ("I'm tired"), the session
  /// resumes with its remaining time. If it followed a completed session, the
  /// flow lands on the next-session prompt instead of silently starting a
  /// fresh session.
  void skipBreak() {
    final s = state;
    if (s.phase != FocusPhase.breaking && s.phase != FocusPhase.breakPaused) {
      return;
    }
    _stopTicker();
    final resume = s.resumeFocusRemaining;
    if (resume != null && resume > Duration.zero) {
      state = s.copyWith(
        phase: FocusPhase.focusing,
        endTime: DateTime.now().add(resume),
        clearPausedRemaining: true,
        clearResumeFocusRemaining: true,
      );
      _ensureTicker();
      return;
    }
    state = s.copyWith(
      phase: FocusPhase.breakComplete,
      clearEndTime: true,
      clearPausedRemaining: true,
    );
  }

  /// "I'm tired" → start a break of [minutes] right away, remembering how much
  /// focus time was left so the session can resume afterwards.
  void tiredBreak(int minutes) {
    final s = state;
    if (s.phase != FocusPhase.focusing && s.phase != FocusPhase.paused) return;
    _stopTicker();
    state = s.copyWith(
      phase: FocusPhase.breaking,
      breakDuration: Duration(minutes: minutes),
      endTime: DateTime.now().add(Duration(minutes: minutes)),
      resumeFocusRemaining: s.remaining(),
      clearPausedRemaining: true,
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
    state = s.copyWith(
      phase: FocusPhase.finished,
      clearEndTime: true,
      clearPausedRemaining: true,
      clearResumeFocusRemaining: true,
    );
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
