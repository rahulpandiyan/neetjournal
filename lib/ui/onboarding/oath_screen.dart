import 'dart:async' as async;
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../state/providers.dart';
import '../screens/home_shell.dart';
import '../widgets/widgets.dart';

class OathScreen extends ConsumerStatefulWidget {
  const OathScreen({super.key});

  @override
  ConsumerState<OathScreen> createState() => _OathScreenState();
}

class _OathScreenState extends ConsumerState<OathScreen> {
  static const _pledges = [
    'I will show up every single day.',
    'I will guard my focus hours.',
    'I will rest without guilt.',
    'I will finish what I start.',
  ];

  final _nameController = TextEditingController();

  String _name = '';
  int _step = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final saved = ref.read(profileNameProvider).valueOrNull ?? '';

      if (saved.isNotEmpty && _nameController.text.isEmpty) {
        _nameController.text = saved;
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _continueWithName() {
    final name = _nameController.text.trim();

    if (name.isEmpty) return;

    FocusScope.of(context).unfocus();

    ref.read(settingsRepositoryProvider).setSetting('profileName', name);

    Future.delayed(const Duration(milliseconds: 80), () {
      if (!mounted) return;

      setState(() {
        _name = name;
        _step = 1;
      });
    });
  }

  Future<void> _seal() async {
    final repo = ref.read(settingsRepositoryProvider);

    if (_name.isNotEmpty) {
      await repo.setSetting('profileName', _name);
    }

    await repo.setSetting('oathTaken', '1');

    if (!mounted) return;

    Future.delayed(const Duration(milliseconds: 80), () {
      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, animation, secondary) => const HomeShell(),
          transitionsBuilder: (_, animation, secondary, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 450),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: SizedBox(
                  width: double.infinity,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 320),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    transitionBuilder: (child, animation) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                    child: _step == 0
                        ? _NameStep(
                            key: const ValueKey('name-step'),
                            controller: _nameController,
                            onChanged: () => setState(() {}),
                            onContinue: _continueWithName,
                          )
                        : _OathStep(
                            key: const ValueKey('oath-step'),
                            name: _name,
                            pledges: _pledges,
                            onSealed: _seal,
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

class _NameStep extends StatelessWidget {
  const _NameStep({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onContinue,
  });

  final TextEditingController controller;
  final VoidCallback onChanged;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Reveal(
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: scheme.surfaceContainerHigh,
              border: Border.all(color: scheme.outlineVariant, width: 1),
            ),
            child: Center(
              child: SvgPicture.asset(
                'assets/svg/fingerprint.svg',
                colorFilter: ColorFilter.mode(scheme.primary, BlendMode.srcIn),
                width: 36,
                height: 36,
              ),
            ),
          ),
        ),

        const SizedBox(height: 32),

        Reveal(
          delay: const Duration(milliseconds: 80),
          child: Text(
            'THE STUDY OATH',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 12.5,
              color: scheme.primary,
              fontWeight: FontWeight.w700,
              letterSpacing: 3,
            ),
          ),
        ),

        const SizedBox(height: 12),

        Reveal(
          delay: const Duration(milliseconds: 150),
          child: Text(
            'Bro, how can\nwe call you?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontSize: 40,
              height: 1.08,
              fontWeight: FontWeight.w700,
              letterSpacing: -1.2,
              color: scheme.onSurface,
            ),
          ),
        ),

        const SizedBox(height: 12),

        Reveal(
          delay: const Duration(milliseconds: 220),
          child: Text(
            'One name is enough. The oath hits different '
            'when it\'s signed with yours.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 15,
              height: 1.6,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),

        const SizedBox(height: 32),

        Reveal(
          delay: const Duration(milliseconds: 300),
          child: TextField(
            controller: controller,
            autofocus: true,
            maxLength: 30,
            textCapitalization: TextCapitalization.words,
            cursorColor: scheme.primary,
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: scheme.onSurface,
            ),
            decoration: InputDecoration(
              hintText: 'Your name, bro',
              hintStyle: TextStyle(
                color: scheme.onSurfaceVariant.withValues(alpha: 0.4),
                fontWeight: FontWeight.w500,
              ),
              counterText: '',
              prefixIcon: HugeIcon(
                icon: HugeIcons.strokeRoundedUserCircle,
                size: 22,
                color: scheme.onSurfaceVariant,
              ),
              filled: true,
              fillColor: scheme.surfaceContainerLow,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: scheme.outlineVariant,
                  width: 1.2,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: scheme.outlineVariant,
                  width: 1.2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: scheme.primary, width: 1.6),
              ),
            ),
            onChanged: (_) => onChanged(),
            onSubmitted: (_) => onContinue(),
          ),
        ),

        const SizedBox(height: 18),

        Reveal(
          delay: const Duration(milliseconds: 360),
          child: FilledButton.icon(
            onPressed: controller.text.trim().isNotEmpty ? onContinue : null,
            icon: Icon(
              controller.text.trim().isNotEmpty
                  ? Icons.arrow_forward_rounded
                  : Icons.check_circle_outline,
            ),
            label: Text(
              controller.text.trim().isNotEmpty ? 'Let\'s go' : 'Ready',
            ),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              textStyle: const TextStyle(
                fontFamily: 'DMSans',
                fontSize: 15.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        Reveal(
          delay: const Duration(milliseconds: 420),
          child: Text(
            'Just your name. It stays on this device.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 12,
              color: scheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
          ),
        ),
      ],
    );
  }
}

class _OathStep extends StatelessWidget {
  const _OathStep({
    super.key,
    required this.name,
    required this.pledges,
    required this.onSealed,
  });

  final String name;
  final List<String> pledges;
  final VoidCallback onSealed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Reveal(
          child: Text(
            'THE STUDY OATH',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 12.5,
              color: scheme.primary,
              fontWeight: FontWeight.w700,
              letterSpacing: 3,
            ),
          ),
        ),

        const SizedBox(height: 14),

        Reveal(
          delay: const Duration(milliseconds: 80),
          child: Text.rich(
            TextSpan(
              children: [
                const TextSpan(text: 'I, '),
                TextSpan(
                  text: name,
                  style: TextStyle(color: scheme.tertiary),
                ),
                const TextSpan(text: ',\nswear on\nmy dream.'),
              ],
            ),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontSize: 38,
              height: 1.08,
              fontWeight: FontWeight.w700,
              letterSpacing: -1.1,
              color: scheme.onSurface,
            ),
          ),
        ),

        const SizedBox(height: 10),

        Reveal(
          delay: const Duration(milliseconds: 160),
          child: Text(
            'Before the white coat, there is this. '
            'One promise to the hardest-working version of you.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 15,
              height: 1.6,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),

        const SizedBox(height: 28),

        Reveal(
          delay: const Duration(milliseconds: 220),
          child: _PledgeList(pledges: pledges, scheme: scheme),
        ),

        const SizedBox(height: 28),

        Reveal(
          delay: const Duration(milliseconds: 400),
          child: Center(child: _OathSealButton(onSealed: onSealed)),
        ),

        const SizedBox(height: 16),

        Reveal(
          delay: const Duration(milliseconds: 480),
          child: Text(
            'TAP THE SEAL TO TAKE THE OATH',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 11,
              letterSpacing: 2.2,
              fontWeight: FontWeight.w600,
              color: scheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
          ),
        ),
      ],
    );
  }
}

class _PledgeList extends StatelessWidget {
  const _PledgeList({required this.pledges, required this.scheme});

  final List<String> pledges;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final accents = [
      Icons.wb_sunny_outlined,
      Icons.timer_outlined,
      Icons.self_improvement_outlined,
      Icons.menu_book_outlined,
    ];

    final colors = [
      scheme.tertiary,
      scheme.primary,
      const Color(0xFF60A5FA),
      const Color(0xFFA78BFA),
    ];

    return Column(
      children: [
        for (int i = 0; i < pledges.length; i++)
          Padding(
            padding: EdgeInsets.only(bottom: i < pledges.length - 1 ? 10 : 0),
            child: Reveal(
              delay: Duration(milliseconds: 220 + i * 60),
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: scheme.outlineVariant, width: 1),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: colors[i].withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(accents[i], size: 17, color: colors[i]),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          pledges[i],
                          style: TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 14.5,
                            height: 1.4,
                            fontWeight: FontWeight.w600,
                            color: scheme.onSurface,
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
    );
  }
}

class _OathSealButton extends StatefulWidget {
  const _OathSealButton({required this.onSealed});

  final VoidCallback onSealed;

  @override
  State<_OathSealButton> createState() => _OathSealButtonState();
}

class _OathSealButtonState extends State<_OathSealButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progress = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  );

  bool _sealed = false;
  bool _pressing = false;
  async.Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    _progress.dispose();
    super.dispose();
  }

  void _pressStart() {
    if (_sealed) return;

    _timer?.cancel();

    setState(() => _pressing = true);

    _progress.forward(from: _progress.value);

    _timer = async.Timer(
      Duration(milliseconds: (1200 * (1 - _progress.value)).round()),
      () {
        if (!mounted) return;

        setState(() {
          _sealed = true;
          _pressing = false;
        });

        HapticFeedback.lightImpact();

        Future.delayed(const Duration(milliseconds: 80), () {
          if (!mounted) return;
          widget.onSealed();
        });
      },
    );
  }

  void _pressCancel() {
    if (_sealed || !_pressing) return;

    _timer?.cancel();

    setState(() => _pressing = false);

    _progress.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      label: 'Take the study oath',
      hint: 'Tap and hold the seal to take the oath',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _pressStart(),
        onTapUp: (_) => _pressCancel(),
        onTapCancel: _pressCancel,
        child: AnimatedBuilder(
          animation: _progress,
          builder: (context, _) {
            final t = _progress.value;

            return SizedBox(
              width: 120,
              height: 120,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size.square(120),
                    painter: _SealPainter(
                      progress: t,
                      sealed: _sealed,
                      scheme: scheme,
                    ),
                  ),
                  AnimatedScale(
                    scale: _pressing && !_sealed ? 0.92 : 1,
                    duration: const Duration(milliseconds: 150),
                    curve: Curves.easeOut,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _sealed
                            ? scheme.primary
                            : scheme.surfaceContainerHigh,
                        border: Border.all(
                          color: _sealed
                              ? scheme.primary
                              : scheme.outlineVariant,
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 260),
                          transitionBuilder: (child, anim) {
                            return ScaleTransition(scale: anim, child: child);
                          },
                          child: _sealed
                              ? Icon(
                                  Icons.check_rounded,
                                  key: const ValueKey('check'),
                                  color: scheme.onPrimary,
                                  size: 36,
                                )
                              : Padding(
                                  key: const ValueKey('fingerprint'),
                                  padding: const EdgeInsets.all(18),
                                  child: SvgPicture.asset(
                                    'assets/svg/fingerprint.svg',
                                    colorFilter: ColorFilter.mode(
                                      scheme.primary,
                                      BlendMode.srcIn,
                                    ),
                                    width: 32,
                                    height: 32,
                                  ),
                                ),
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
  const _SealPainter({
    required this.progress,
    required this.sealed,
    required this.scheme,
  });

  final double progress;
  final bool sealed;
  final ColorScheme scheme;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 3;

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..color = scheme.outlineVariant;

    canvas.drawCircle(center, radius, track);

    final fill = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..color = sealed ? scheme.primary : scheme.tertiary;

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
