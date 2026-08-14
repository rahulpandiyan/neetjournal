import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../state/auth_providers.dart';
import '../../state/providers.dart';
import '../screens/home_shell.dart';
import '../widgets/widgets.dart';

/// Onboarding: the user commits to their NEET journey by taking "The Study
/// Oath". Shown once after sign-in, skipped once taken. Deliberately an
/// immersive dark screen so it reads as a moment, not a form.
class OathScreen extends ConsumerWidget {
  const OathScreen({super.key});

  static const _pledges = [
    'I will show up every single day.',
    'I will guard my focus hours.',
    'I will rest without guilt.',
    'I will finish what I start.',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    Future<void> seal() async {
      await ref.read(settingsRepositoryProvider).setSetting('oathTaken', '1');
      if (!context.mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, animation, secondary) => const HomeShell(),
          transitionsBuilder: (_, animation, secondary, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 450),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF07130B),
      body: Stack(
        children: [
          // Ambient glow behind the seal.
          Positioned(
            top: -140,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Container(
                height: 420,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF2E7D32).withValues(alpha: 0.55),
                      Colors.transparent,
                    ],
                    stops: const [0, 1],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(28, 24, 28, 40),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Reveal(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'THE STUDY OATH',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: const Color(0xFFA5D6A7),
                                fontWeight: FontWeight.w700,
                                letterSpacing: 3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Reveal(
                        delay: const Duration(milliseconds: 100),
                        child: Text(
                          'I swear on\nmy dream.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'SpaceGrotesk',
                            fontSize: 44,
                            height: 1.05,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1.4,
                            color: Color(0xFFF2F5F0),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Reveal(
                        delay: const Duration(milliseconds: 200),
                        child: Text(
                          'Before the white coat, there is this. '
                          'One promise to the hardest-working version of you.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 14.5,
                            height: 1.5,
                            color: const Color(0xFF9CB09F),
                          ),
                        ),
                      ),
                      const SizedBox(height: 26),
                      Reveal(
                        delay: const Duration(milliseconds: 300),
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.055),
                            borderRadius: BorderRadius.circular(26),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.10),
                            ),
                          ),
                          child: Column(
                            children: [
                              for (final pledge in _pledges)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 9,
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 22,
                                        height: 22,
                                        margin: const EdgeInsets.only(top: 1),
                                        decoration: BoxDecoration(
                                          color: const Color(
                                            0xFFFFC107,
                                          ).withValues(alpha: 0.16),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.star_rounded,
                                          size: 14,
                                          color: Color(0xFFFFC107),
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Text(
                                          pledge,
                                          style: const TextStyle(
                                            fontFamily: 'DMSans',
                                            fontSize: 15,
                                            height: 1.4,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFFE4EAE2),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Reveal(
                        delay: const Duration(milliseconds: 400),
                        child: Text(
                          'This I promise — to myself.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                            color: const Color(0xFF8FA993),
                          ),
                        ),
                      ),
                      const SizedBox(height: 26),
                      Reveal(
                        delay: const Duration(milliseconds: 500),
                        child: Center(child: _OathSealButton(onSealed: seal)),
                      ),
                      const SizedBox(height: 14),
                      Reveal(
                        delay: const Duration(milliseconds: 600),
                        child: Text(
                          'HOLD THE SEAL TO TAKE THE OATH',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 11,
                            letterSpacing: 2.2,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF6F8A73),
                          ),
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
    );
  }
}

/// A golden seal that fills while held; completing the hold seals the oath.
class _OathSealButton extends StatefulWidget {
  const _OathSealButton({required this.onSealed});

  final VoidCallback onSealed;

  @override
  State<_OathSealButton> createState() => _OathSealButtonState();
}

class _OathSealButtonState extends State<_OathSealButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progress =
      AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1200),
      )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() => _sealed = true);
          widget.onSealed();
        }
      });

  bool _sealed = false;

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Take the study oath',
      hint: 'Press and hold the seal to take the oath',
      child: GestureDetector(
        onTapDown: (_) => _progress.forward(),
        onTapUp: (_) {
          if (!_sealed) _progress.reverse();
        },
        onTapCancel: () {
          if (!_sealed) _progress.reverse();
        },
        child: AnimatedBuilder(
          animation: _progress,
          builder: (context, _) {
            final t = _progress.value;
            return SizedBox(
              width: 132,
              height: 132,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer ring + progress.
                  CustomPaint(
                    size: const Size.square(132),
                    painter: _SealPainter(progress: t, sealed: _sealed),
                  ),
                  // Inner disc.
                  Container(
                    width: 104,
                    height: 104,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(
                        0xFF2E7D32,
                      ).withValues(alpha: _sealed ? 1 : 0.20),
                      border: Border.all(
                        color: const Color(0xFFA5D6A7).withValues(alpha: 0.55),
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 320),
                        transitionBuilder: (child, anim) =>
                            ScaleTransition(scale: anim, child: child),
                        child: _sealed
                            ? const Icon(
                                Icons.check_rounded,
                                key: ValueKey('check'),
                                color: Colors.white,
                                size: 46,
                              )
                            : Transform.scale(
                                key: const ValueKey('pen'),
                                scale: 1 - 0.25 * t,
                                child: const HugeIcon(
                                  icon: HugeIcons.strokeRoundedPenTool01,
                                  color: Color(0xFFEAF5EC),
                                  size: 40,
                                ),
                              ),
                      ),
                    ),
                  ),
                  // Growing glow as the seal fills.
                  if (!_sealed && t > 0)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFFFFC107,
                                ).withValues(alpha: 0.28 * t),
                                blurRadius: 18 + 26 * t,
                                spreadRadius: 2 + 8 * t,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SealPainter extends CustomPainter {
  const _SealPainter({required this.progress, required this.sealed});

  final double progress;
  final bool sealed;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 3;

    // Track.
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: sealed ? 0.5 : 0.18);
    canvas.drawCircle(center, radius, track);

    // Progress arc (golden, clockwise from the top).
    final fill = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFFFFC107).withValues(alpha: sealed ? 1 : 0.9);
    if (sealed) {
      canvas.drawCircle(center, radius, fill);
    } else if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        fill,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SealPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.sealed != sealed;
  }
}
