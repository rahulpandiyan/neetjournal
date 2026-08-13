import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/focus_controller.dart';
import '../../state/providers.dart';
import 'session_complete_sheet.dart';

class FocusScreen extends ConsumerStatefulWidget {
  const FocusScreen({super.key});

  @override
  ConsumerState<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends ConsumerState<FocusScreen> {
  bool _sheetOpen = false;

  String _fmt(Duration d) {
    if (d.isNegative) d = Duration.zero;
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Future<void> _showCompletion() async {
    if (_sheetOpen) return;
    _sheetOpen = true;
    final state = ref.read(focusControllerProvider);
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (_) => SessionCompleteSheet(state: state),
    );
    _sheetOpen = false;
    if (mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  void _onNextSession() {
    ref.read(focusControllerProvider.notifier).nextSession();
    _showCompletion();
  }

  void _onEndTired() {
    ref.read(focusControllerProvider.notifier).endTired();
  }

  Future<void> _showTiredSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'What would you like to do?',
                style: Theme.of(ctx).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton.tonal(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  ref.read(focusControllerProvider.notifier).tiredBreak(10);
                },
                child: const Text('Take 10 min Break'),
              ),
              const SizedBox(height: 8),
              FilledButton.tonal(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  ref.read(focusControllerProvider.notifier).tiredBreak(20);
                },
                child: const Text('Take 20 min Break'),
              ),
              const SizedBox(height: 8),
              FilledButton.tonal(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  _onEndTired();
                },
                child: const Text('End Session'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(focusControllerProvider);

    // If the session was ended early ("I'm tired" → End Session).
    if (state.phase == FocusPhase.finished) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _showCompletion());
      return const Scaffold(body: SizedBox.shrink());
    }

    final phase = state.phase;
    final inBreak =
        phase == FocusPhase.breaking || phase == FocusPhase.breakPaused;

    final remaining = state.remaining();
    final timerText = inBreak ? 'Break ${_fmt(remaining)}' : _fmt(remaining);

    // Drink-water reminder: shows for ~12s at each interval boundary and once
    // more in the final 90s of the session, so short sessions never miss it.
    // Cadence is based on active (non-paused) focus time, since `remaining()`
    // is end-time based and re-anchored on pause/resume.
    final water =
        ref.watch(waterReminderProvider).valueOrNull ??
        (enabled: true, minutes: 30);
    final (enabled: waterEnabled, minutes: waterMinutes) = water;
    var showWater = false;
    if (phase == FocusPhase.focusing && waterEnabled) {
      final active = state.focusDuration - remaining;
      final cycle = waterMinutes * 60;
      final atBoundary =
          active.inSeconds >= cycle && active.inSeconds % cycle < 12;
      final finalStretch =
          remaining.inSeconds > 0 &&
          remaining.inSeconds <= 90 &&
          (active.inSeconds < cycle || active.inSeconds % cycle > cycle - 90);
      showWater = atBoundary || finalStretch;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0D1220),
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      state.subjectName,
                      style: const TextStyle(
                        color: Color(0xFF9FA8DA),
                        fontSize: 16,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (state.target != null && state.target!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        state.target!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 14,
                        ),
                      ),
                    ],
                    const SizedBox(height: 48),
                    Text(
                      timerText,
                      style: TextStyle(
                        color: inBreak ? const Color(0xFF81C784) : Colors.white,
                        fontSize: 64,
                        fontWeight: FontWeight.w300,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    if (phase == FocusPhase.focusing &&
                        remaining.isNegative) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0x1AFFFFFF),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0x33FFF59D)),
                        ),
                        child: const Text(
                          "You've been studying too long. "
                          'Your timetable planned a break now.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFFFFF59D),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 48),
                    if (phase == FocusPhase.focusing ||
                        phase == FocusPhase.paused) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white38),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 14,
                              ),
                            ),
                            onPressed: () {
                              final c = ref.read(
                                focusControllerProvider.notifier,
                              );
                              if (phase == FocusPhase.focusing) {
                                c.pause();
                              } else {
                                c.resume();
                              }
                            },
                            icon: Icon(
                              phase == FocusPhase.focusing
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                            ),
                            label: Text(
                              phase == FocusPhase.focusing ? 'PAUSE' : 'RESUME',
                            ),
                          ),
                          const SizedBox(width: 16),
                          FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF3949AB),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 14,
                              ),
                            ),
                            onPressed: () => ref
                                .read(focusControllerProvider.notifier)
                                .finish(),
                            child: const Text('FINISH'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      TextButton.icon(
                        onPressed: _showTiredSheet,
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white54,
                        ),
                        icon: const Icon(
                          Icons.sentiment_satisfied_alt_outlined,
                        ),
                        label: const Text("I'M TIRED"),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Stay focused.\nYour break is coming soon.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white38, fontSize: 13),
                      ),
                    ] else if (phase == FocusPhase.sessionComplete) ...[
                      const Text('🎉', style: TextStyle(fontSize: 56)),
                      const SizedBox(height: 12),
                      const Text(
                        'Session Complete',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${state.subjectName} is done.\nTake a ${state.breakDuration.inMinutes}-minute break.\n\nDrink water.\nStretch.\nRest your eyes.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white60,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 32),
                      FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () => ref
                            .read(focusControllerProvider.notifier)
                            .startBreak(),
                        child: const Text('START BREAK'),
                      ),
                    ] else if (inBreak) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white38),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 14,
                              ),
                            ),
                            onPressed: () {
                              final c = ref.read(
                                focusControllerProvider.notifier,
                              );
                              if (phase == FocusPhase.breaking) {
                                c.pauseBreak();
                              } else {
                                c.resumeBreak();
                              }
                            },
                            icon: Icon(
                              phase == FocusPhase.breaking
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                            ),
                            label: Text(
                              phase == FocusPhase.breaking ? 'PAUSE' : 'RESUME',
                            ),
                          ),
                          const SizedBox(width: 16),
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Colors.white38),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 14,
                              ),
                            ),
                            onPressed: () => ref
                                .read(focusControllerProvider.notifier)
                                .skipBreak(),
                            child: const Text('SKIP BREAK'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Rest your eyes. No phone. ☕',
                        style: TextStyle(color: Colors.white38, fontSize: 13),
                      ),
                    ] else if (phase == FocusPhase.breakComplete) ...[
                      const Text('🔔', style: TextStyle(fontSize: 56)),
                      const SizedBox(height: 12),
                      const Text(
                        'Break Complete',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Time to get back to it.',
                        style: TextStyle(color: Colors.white60),
                      ),
                      const SizedBox(height: 32),
                      FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF3949AB),
                          foregroundColor: Colors.white,
                        ),
                        onPressed: _onNextSession,
                        child: const Text('START NEXT SESSION'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (showWater)
              Positioned(
                top: 16,
                left: 0,
                right: 0,
                child: IgnorePointer(
                  child: Align(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0x1AFFFFFF),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0x3381D4FA)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.local_drink_outlined,
                            color: Color(0xFF81D4FA),
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Time for water. Stay hydrated!',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
