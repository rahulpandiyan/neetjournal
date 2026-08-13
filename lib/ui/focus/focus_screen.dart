import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/focus_controller.dart';
import '../../state/providers.dart';
import '../../ui/widgets/widgets.dart';
import 'session_complete_sheet.dart';

/// Immersive dark palette for the focus screen (locked to the app identity:
/// green ink, lab teal, warm amber energy).
class _Palette {
  static const ink = Color(0xFF0B1210);
  static const panel = Color(0xFF1E2B27);
  static const teal = Color(0xFF66D9DE);
  static const tealSoft = Color(0xFF20403B);
  static const amber = Color(0xFFFFC857);
  static const redSoft = Color(0xFFFFB4A9);
  static const text = Colors.white;
  static const textSoft = Color(0xFF93A19B);
  static const textDim = Color(0xFF5C6B64);
  static const track = Color(0x1AFFFFFF);
}

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
      backgroundColor: _Palette.panel,
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

  Future<void> _showTiredSheet() async {
    final theme = Theme.of(context);
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: _Palette.panel,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'What would you like to do?',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: _Palette.text,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton.tonal(
                style: FilledButton.styleFrom(
                  backgroundColor: _Palette.tealSoft,
                  foregroundColor: _Palette.text,
                ),
                onPressed: () {
                  Navigator.of(ctx).pop();
                  ref.read(focusControllerProvider.notifier).tiredBreak(10);
                },
                child: const Text('Take 10 min Break'),
              ),
              const SizedBox(height: 8),
              FilledButton.tonal(
                style: FilledButton.styleFrom(
                  backgroundColor: _Palette.tealSoft,
                  foregroundColor: _Palette.text,
                ),
                onPressed: () {
                  Navigator.of(ctx).pop();
                  ref.read(focusControllerProvider.notifier).tiredBreak(20);
                },
                child: const Text('Take 20 min Break'),
              ),
              const SizedBox(height: 8),
              FilledButton.tonal(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF3A2222),
                  foregroundColor: _Palette.redSoft,
                ),
                onPressed: () {
                  Navigator.of(ctx).pop();
                  ref.read(focusControllerProvider.notifier).endTired();
                },
                child: const Text('End Session'),
              ),
              const SizedBox(height: 8),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: _Palette.textSoft),
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Early-stop confirmation: shows why finishing the stretch matters and
  /// requires a press-and-hold to actually end the session.
  Future<void> _onEndPressed() async {
    final state = ref.read(focusControllerProvider);
    final total = state.focusDuration.inSeconds;
    final left = state.remaining().inSeconds;
    final elapsed = total - left;
    final progress = total <= 0 ? 1.0 : (elapsed / total).clamp(0.0, 1.0);
    final done = (elapsed / 60).floor().clamp(0, 999);
    final minsLeft = (left / 60).ceil().clamp(1, 999);

    final String title;
    final String message;
    if (progress < 0.4) {
      title = 'You are only $done minutes in';
      message =
          'Every early stop trains the quitting habit. Your break is '
          'just $minsLeft minutes away. Hold on through this stretch and '
          'count this session as a real win.';
    } else if (progress < 0.8) {
      title = 'The hardest part is behind you';
      message =
          'You are past the middle of the session. Stopping now throws '
          'away the momentum you just built. $minsLeft more minutes. '
          'You have got this.';
    } else {
      title = 'Almost there, $minsLeft minutes to go';
      message =
          'The timer is nearly done. Hold on a few more minutes and '
          'finish this session the way you started it: focused.';
    }

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: _Palette.panel,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Icon(Icons.flag_outlined, color: _Palette.amber, size: 30),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _Palette.text,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _Palette.textSoft,
                  fontSize: 14.5,
                  height: 1.55,
                ),
              ),
              const SizedBox(height: 24),
              HoldToConfirmButton(
                label: 'HOLD TO END SESSION',
                onConfirmed: () {
                  Navigator.of(ctx).pop();
                  ref.read(focusControllerProvider.notifier).endSession();
                },
              ),
              const SizedBox(height: 10),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: _Palette.textSoft),
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Keep going'),
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

    // Session ended early (END / "I'm tired" → End Session).
    if (state.phase == FocusPhase.finished) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _showCompletion());
      return const Scaffold(body: SizedBox.shrink());
    }

    final phase = state.phase;
    final inBreak =
        phase == FocusPhase.breaking || phase == FocusPhase.breakPaused;

    final remaining = state.remaining();
    final timerText = _fmt(remaining);

    // Drink-water reminder: shows for ~12s at each interval boundary and once
    // more in the final 90s of the session, so short sessions never miss it.
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
      backgroundColor: _Palette.ink,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      radius: 1.1,
                      colors: [
                        _Palette.panel.withValues(alpha: 0.55),
                        _Palette.ink,
                      ],
                      stops: const [0.0, 0.6],
                    ),
                  ),
                ),
              ),
            ),
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      MediaQuery.sizeOf(context).height -
                      MediaQuery.paddingOf(context).vertical,
                ),
                child: Center(
                  child: _buildBody(
                    state,
                    phase,
                    inBreak,
                    remaining,
                    timerText,
                  ),
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

  Widget _buildBody(
    FocusState state,
    FocusPhase phase,
    bool inBreak,
    Duration remaining,
    String timerText,
  ) {
    if (phase == FocusPhase.focusing || phase == FocusPhase.paused) {
      final total = state.focusDuration;
      final elapsed = total - remaining;
      final progress = total.inSeconds <= 0
          ? 0.0
          : (elapsed.inSeconds / total.inSeconds).clamp(0.0, 1.0);
      final paused = phase == FocusPhase.paused;

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            (paused ? 'Paused' : state.subjectName).toUpperCase(),
            style: const TextStyle(
              color: _Palette.teal,
              fontSize: 13,
              letterSpacing: 2.4,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            state.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _Palette.text,
              fontSize: 24,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
          if (state.target != null && state.target!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              state.target!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: _Palette.textSoft, fontSize: 14),
            ),
          ],
          const SizedBox(height: 28),
          _TimerRing(
            progress: progress,
            color: _Palette.teal,
            dimmed: paused,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  paused ? 'PAUSED' : 'FOCUS',
                  style: const TextStyle(
                    color: _Palette.textDim,
                    fontSize: 12,
                    letterSpacing: 2.2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  timerText,
                  style: const TextStyle(
                    color: _Palette.text,
                    fontSize: 58,
                    fontWeight: FontWeight.w300,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'of ${_fmt(total)}',
                  style: const TextStyle(
                    color: _Palette.textDim,
                    fontSize: 13,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
          if (phase == FocusPhase.focusing && remaining.isNegative) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0x1AFFFFFF),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0x33FFF59D)),
              ),
              child: const Text(
                "You've been studying too long. "
                'Your timetable planned a break now.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFFFFF59D), fontSize: 13),
              ),
            ),
          ],
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: _Palette.tealSoft,
                    foregroundColor: _Palette.text,
                  ),
                  onPressed: () {
                    final c = ref.read(focusControllerProvider.notifier);
                    if (paused) {
                      c.resume();
                    } else {
                      c.pause();
                    }
                  },
                  icon: Icon(
                    paused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                  ),
                  label: Text(paused ? 'Resume' : 'Pause'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _Palette.redSoft,
                    side: const BorderSide(color: Colors.white24),
                  ),
                  onPressed: _onEndPressed,
                  icon: const Icon(Icons.stop_circle_outlined),
                  label: const Text('End'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: _showTiredSheet,
            style: TextButton.styleFrom(foregroundColor: _Palette.textDim),
            icon: const Icon(Icons.sentiment_satisfied_alt_outlined, size: 18),
            label: const Text("I'm tired"),
          ),
          const SizedBox(height: 8),
          Text(
            paused ? 'Paused. Come back when you are ready.' : 'Stay focused.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: _Palette.textDim, fontSize: 13),
          ),
        ],
      );
    }

    if (phase == FocusPhase.sessionComplete) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: _Palette.tealSoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              color: _Palette.teal,
              size: 52,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Session Complete',
            style: TextStyle(
              color: _Palette.text,
              fontSize: 26,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${state.subjectName} is done.\n'
            'Take a ${state.breakDuration.inMinutes}-minute break.\n\n'
            'Drink water.\nStretch.\nRest your eyes.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: _Palette.textSoft, height: 1.6),
          ),
          const SizedBox(height: 28),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: _Palette.teal,
              foregroundColor: _Palette.ink,
            ),
            onPressed: () =>
                ref.read(focusControllerProvider.notifier).startBreak(),
            child: const Text('START BREAK'),
          ),
        ],
      );
    }

    if (inBreak) {
      final total = state.breakDuration;
      final elapsed = total - remaining;
      final progress = total.inSeconds <= 0
          ? 0.0
          : (elapsed.inSeconds / total.inSeconds).clamp(0.0, 1.0);
      final paused = phase == FocusPhase.breakPaused;

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'BREAK',
            style: TextStyle(
              color: _Palette.amber,
              fontSize: 13,
              letterSpacing: 2.4,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 28),
          _TimerRing(
            progress: progress,
            color: _Palette.amber,
            dimmed: paused,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  paused ? 'PAUSED' : 'REST',
                  style: const TextStyle(
                    color: _Palette.textDim,
                    fontSize: 12,
                    letterSpacing: 2.2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  timerText,
                  style: const TextStyle(
                    color: _Palette.text,
                    fontSize: 58,
                    fontWeight: FontWeight.w300,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'of ${_fmt(total)}',
                  style: const TextStyle(
                    color: _Palette.textDim,
                    fontSize: 13,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Rest your eyes. No phone.',
            style: TextStyle(color: _Palette.textDim, fontSize: 13),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: _Palette.tealSoft,
                    foregroundColor: _Palette.text,
                  ),
                  onPressed: () {
                    final c = ref.read(focusControllerProvider.notifier);
                    if (paused) {
                      c.resumeBreak();
                    } else {
                      c.pauseBreak();
                    }
                  },
                  icon: Icon(
                    paused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                  ),
                  label: Text(paused ? 'Resume' : 'Pause'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _Palette.textSoft,
                    side: const BorderSide(color: Colors.white24),
                  ),
                  onPressed: () =>
                      ref.read(focusControllerProvider.notifier).skipBreak(),
                  child: const Text('Skip Break'),
                ),
              ),
            ],
          ),
        ],
      );
    }

    // breakComplete
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            color: const Color(0xFF3A3020),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.notifications_active_rounded,
            color: _Palette.amber,
            size: 48,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Break Complete',
          style: TextStyle(
            color: _Palette.text,
            fontSize: 26,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Time to get back to it.',
          style: TextStyle(color: _Palette.textSoft),
        ),
        const SizedBox(height: 28),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: _Palette.teal,
            foregroundColor: _Palette.ink,
          ),
          onPressed: _onNextSession,
          child: const Text('START NEXT SESSION'),
        ),
      ],
    );
  }
}

class _TimerRing extends StatelessWidget {
  const _TimerRing({
    required this.progress,
    required this.color,
    required this.child,
    this.dimmed = false,
  });

  static const _size = 252.0;
  static const _stroke = 12.0;

  final double progress;
  final Color color;
  final Widget child;
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _size,
      height: _size,
      child: Opacity(
        opacity: dimmed ? 0.45 : 1,
        child: CustomPaint(
          painter: _RingPainter(
            progress: progress,
            color: color,
            stroke: _stroke,
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.progress,
    required this.color,
    required this.stroke,
  });

  final double progress;
  final Color color;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - stroke) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = _Palette.track
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, track);

    if (progress > 0) {
      final arc = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = color
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        rect,
        -math.pi / 2,
        2 * math.pi * progress.clamp(0.0, 1.0),
        false,
        arc,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.color != color || old.stroke != stroke;
}
