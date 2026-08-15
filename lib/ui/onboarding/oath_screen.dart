import 'dart:async' as async;
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../state/providers.dart';
import '../screens/home_shell.dart';
import '../widgets/widgets.dart';

/// Onboarding: the user commits to their NEET journey by taking "The Study
/// Oath". Shown once after sign-in, skipped once taken. Deliberately an
/// immersive dark screen so it reads as a moment, not a form.
///
/// Two steps: first we ask how to call the user ("Bro, how can we call you?"),
/// then the oath is signed with that name.
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
    // Prefill with a name saved during a previous, incomplete visit.
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
    // Defer the step change to a microtask so the AnimatedSwitcher tree
    // swap does not happen during the pointer-event batch. Rebuilding the
    // oath step (which mounts the seal button's GestureDetector) mid-pointer
    // causes the MouseTracker to recurse into _deviceUpdatePhase on Linux
    // desktop, hitting the '!_debugDuringDeviceUpdate' assertion.
    Future.microtask(() {
      if (mounted) {
        setState(() {
          _name = name;
          _step = 1;
        });
      }
    });
  }

  Future<void> _seal() async {
    final repo = ref.read(settingsRepositoryProvider);
    if (_name.isNotEmpty) await repo.setSetting('profileName', _name);
    await repo.setSetting('oathTaken', '1');
    if (!mounted) return;
    // Defer navigation to a microtask so it runs after the current
    // pointer-event batch has fully drained. Calling pushReplacement
    // synchronously from the animation status listener (or even from a
    // post-frame callback) triggers a tree rebuild that re-enters the
    // mouse tracker during the same frame on Linux desktop, hitting the
    // '!_debugDuringDeviceUpdate' assertion and crashing the app.
    Future.microtask(() {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, animation, secondary) => const HomeShell(),
            transitionsBuilder: (_, animation, secondary, child) =>
                FadeTransition(opacity: animation, child: child),
            transitionDuration: const Duration(milliseconds: 450),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07130B),
      body: Stack(
        children: [
          // Ambient glow behind the content.
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
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 420),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    transitionBuilder: (child, animation) =>
                        FadeTransition(opacity: animation, child: child),
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
          ),
        ],
      ),
    );
  }
}

/// Step 1 — "Bro, how can we call you?"
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
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 20),
        Reveal(
          child: Center(
            child: _FingerprintHero(
              size: 116,
              iconSize: 58,
              color: const Color(0xFFA5D6A7),
              glow: const Color(0xFF2E7D32),
            ),
          ),
        ),
        const SizedBox(height: 22),
        Reveal(
          delay: const Duration(milliseconds: 100),
          child: Text(
            'THE STUDY OATH',
            textAlign: TextAlign.center,
            style: theme.textTheme.labelMedium?.copyWith(
              color: const Color(0xFFA5D6A7),
              fontWeight: FontWeight.w700,
              letterSpacing: 3,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Reveal(
          delay: const Duration(milliseconds: 180),
          child: Text(
            'Bro, how can\nwe call you?',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontSize: 42,
              height: 1.05,
              fontWeight: FontWeight.w800,
              letterSpacing: -1.3,
              color: Color(0xFFF2F5F0),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Reveal(
          delay: const Duration(milliseconds: 260),
          child: Text(
            'One name is enough. The oath hits different '
            'when it\'s signed with yours.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 14.5,
              height: 1.5,
              color: const Color(0xFF9CB09F),
            ),
          ),
        ),
        const SizedBox(height: 28),
        Reveal(
          delay: const Duration(milliseconds: 340),
          child: TextField(
            controller: controller,
            autofocus: true,
            maxLength: 30,
            textCapitalization: TextCapitalization.words,
            style: const TextStyle(
              fontFamily: 'DMSans',
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Color(0xFFE4EAE2),
            ),
            decoration: InputDecoration(
              hintText: 'Your name, bro',
              counterText: '',
              prefixIcon: const HugeIcon(
                icon: HugeIcons.strokeRoundedUserCircle,
                size: 22,
                color: Color(0xFF8FA993),
              ),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.06),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(
                  color: Colors.white.withValues(alpha: 0.12),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(
                  color: Colors.white.withValues(alpha: 0.12),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(
                  color: Color(0xFF66BB6A),
                  width: 1.5,
                ),
              ),
            ),
            onChanged: (_) => onChanged(),
            onSubmitted: (_) => onContinue(),
          ),
        ),
        const SizedBox(height: 18),
        Reveal(
          delay: const Duration(milliseconds: 420),
          child: _RaisedButton(
            label: 'Let\'s go',
            icon: HugeIcons.strokeRoundedArrowRight02,
            enabled: controller.text.trim().isNotEmpty,
            onTap: onContinue,
          ),
        ),
        const SizedBox(height: 14),
        Reveal(
          delay: const Duration(milliseconds: 500),
          child: Text(
            'Just your name. It stays on this device.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 12,
              color: const Color(0xFF6F8A73),
            ),
          ),
        ),
      ],
    );
  }
}

/// Step 2 — the oath, signed with the user's name.
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
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Reveal(
          child: Text(
            'THE STUDY OATH',
            textAlign: TextAlign.center,
            style: theme.textTheme.labelMedium?.copyWith(
              color: const Color(0xFFA5D6A7),
              fontWeight: FontWeight.w700,
              letterSpacing: 3,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Reveal(
          delay: const Duration(milliseconds: 100),
          child: Text.rich(
            TextSpan(
              children: [
                const TextSpan(text: 'I, '),
                TextSpan(
                  text: name,
                  style: const TextStyle(color: Color(0xFFFFC107)),
                ),
                const TextSpan(text: ',\nswear on\nmy dream.'),
              ],
            ),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'SpaceGrotesk',
              fontSize: 40,
              height: 1.05,
              fontWeight: FontWeight.w800,
              letterSpacing: -1.2,
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
        _BentoGrid(
          pledges: pledges,
          revealDelay: const Duration(milliseconds: 300),
        ),
        const SizedBox(height: 16),
        Reveal(
          delay: const Duration(milliseconds: 420),
          child: Text(
            'This I promise, $name — to yourself.',
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
          child: Center(child: _OathSealButton(onSealed: onSealed)),
        ),
        const SizedBox(height: 14),
        Reveal(
          delay: const Duration(milliseconds: 600),
          child: Text(
            'TAP THE SEAL TO TAKE THE OATH',
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
    );
  }
}

/// Fingerprint mark with a soft halo — the visual signature of the oath.
class _FingerprintHero extends StatelessWidget {
  const _FingerprintHero({
    required this.size,
    required this.iconSize,
    required this.color,
    required this.glow,
  });

  final double size;
  final double iconSize;
  final Color color;
  final Color glow;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(-0.25, -0.3),
          colors: [glow.withValues(alpha: 0.85), const Color(0xFF0C1F11)],
          stops: const [0, 1],
        ),
        border: Border.all(color: color.withValues(alpha: 0.30), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: glow.withValues(alpha: 0.35),
            blurRadius: 36,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            offset: const Offset(0, 10),
            blurRadius: 22,
          ),
        ],
      ),
      child: Center(
        child: SvgPicture.asset(
          'assets/svg/fingerprint.svg',
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
          width: iconSize,
          height: iconSize,
        ),
      ),
    );
  }
}

/// Skeuomorphic raised button: gradient face, top highlight, soft drop shadow.
class _RaisedButton extends StatelessWidget {
  const _RaisedButton({
    required this.label,
    required this.onTap,
    this.icon,
    this.enabled = true,
  });

  final String label;
  final VoidCallback onTap;
  final List<List<dynamic>>? icon;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: enabled ? 1 : 0.55,
      duration: const Duration(milliseconds: 180),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: enabled
                    ? const [Color(0xFF3E9B46), Color(0xFF1F6B2E)]
                    : const [Color(0xFF26352A), Color(0xFF1D281F)],
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.16),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF9BD39F).withValues(alpha: 0.10),
                  offset: const Offset(-3, -3),
                  blurRadius: 12,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.40),
                  offset: const Offset(0, 10),
                  blurRadius: 20,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                if (icon != null) ...[
                  const SizedBox(width: 10),
                  HugeIcon(icon: icon!, size: 20, color: Colors.white),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Bento-style grid of pledges: one wide card, two half cards, one wide card.
class _BentoGrid extends StatelessWidget {
  const _BentoGrid({required this.pledges, required this.revealDelay});

  final List<String> pledges;
  final Duration revealDelay;

  static const _accents = [
    (icon: HugeIcons.strokeRoundedSun01, color: Color(0xFFFFC107)),
    (icon: HugeIcons.strokeRoundedTimer01, color: Color(0xFF66BB6A)),
    (icon: HugeIcons.strokeRoundedYoga01, color: Color(0xFFA5D6A7)),
    (icon: HugeIcons.strokeRoundedBook02, color: Color(0xFF9BE0A1)),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _BentoRow(
          revealDelay: revealDelay,
          child: _BentoCard(
            pledge: pledges[0],
            accent: _accents[0],
            wide: true,
          ),
        ),
        const SizedBox(height: 12),
        _BentoRow(
          revealDelay: revealDelay + const Duration(milliseconds: 80),
          children: [
            _BentoCard(pledge: pledges[1], accent: _accents[1], wide: false),
            const SizedBox(width: 12),
            _BentoCard(pledge: pledges[2], accent: _accents[2], wide: false),
          ],
        ),
        const SizedBox(height: 12),
        _BentoRow(
          revealDelay: revealDelay + const Duration(milliseconds: 160),
          child: _BentoCard(
            pledge: pledges[3],
            accent: _accents[3],
            wide: true,
          ),
        ),
      ],
    );
  }
}

class _BentoRow extends StatelessWidget {
  const _BentoRow({required this.revealDelay, this.children, this.child})
    : assert((children == null) != (child == null));

  final Duration revealDelay;
  final List<Widget>? children;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Reveal(
      delay: revealDelay,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children ?? [child!],
      ),
    );
  }
}

/// A single bento cell with a neo-skeuomorphic face: soft light + dark
/// shadows (neumorphic) and a beveled top highlight, with an accent chip.
class _BentoCard extends StatelessWidget {
  const _BentoCard({
    required this.pledge,
    required this.accent,
    required this.wide,
  });

  final String pledge;
  final ({List<List<dynamic>> icon, Color color}) accent;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final accentColor = accent.color;
    return Expanded(
      flex: wide ? 3 : 2,
      child: Container(
        constraints: BoxConstraints(minHeight: wide ? 84 : 96),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.085),
              Colors.white.withValues(alpha: 0.018),
            ],
          ),
          border: Border(
            top: BorderSide(color: Colors.white.withValues(alpha: 0.16)),
            right: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
            bottom: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
            left: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.05),
              offset: const Offset(-4, -4),
              blurRadius: 12,
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              offset: const Offset(0, 8),
              blurRadius: 20,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: accentColor.withValues(alpha: 0.25)),
              ),
              child: HugeIcon(icon: accent.icon, size: 18, color: accentColor),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Text(
                pledge,
                style: const TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 14.5,
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFE4EAE2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A golden seal that fills over 1.2 s after a tap; completing the fill
/// seals the oath. Uses a timer instead of hold-gesture callbacks to avoid
/// triggering the Linux desktop mouse-tracker recursive-update assertion.
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
  async.Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    _progress.dispose();
    super.dispose();
  }

  void _startTimer() {
    if (_sealed) return;
    _timer?.cancel();
    _progress.forward(from: 0);
    _timer = async.Timer(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      setState(() => _sealed = true);
      widget.onSealed();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Take the study oath',
      hint: 'Tap the seal to take the oath',
      child: InkWell(
        onTap: _startTimer,
        borderRadius: BorderRadius.circular(74),
        child: AnimatedBuilder(
          animation: _progress,
          builder: (context, _) {
            final t = _progress.value;
            return SizedBox(
              width: 148,
              height: 148,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Bezel: neumorphic depth behind the ring.
                  Container(
                    width: 148,
                    height: 148,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(
                            0xFF9BD39F,
                          ).withValues(alpha: 0.10),
                          offset: const Offset(-5, -5),
                          blurRadius: 16,
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.45),
                          offset: const Offset(0, 12),
                          blurRadius: 24,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  // Golden progress ring.
                  CustomPaint(
                    size: const Size.square(148),
                    painter: _SealPainter(progress: t, sealed: _sealed),
                  ),
                  // The disc: glossy radial face holding the fingerprint.
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        center: const Alignment(-0.3, -0.35),
                        radius: 1.25,
                        colors: _sealed
                            ? const [Color(0xFF4CAF50), Color(0xFF1B5E20)]
                            : [
                                const Color(0xFF3E8E44).withValues(alpha: 0.55),
                                const Color(0xFF1E5E28).withValues(alpha: 0.55),
                              ],
                      ),
                      border: Border.all(
                        color: const Color(0xFFA5D6A7).withValues(alpha: 0.55),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.40),
                          offset: const Offset(0, 6),
                          blurRadius: 12,
                        ),
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.08),
                          offset: const Offset(-3, -3),
                          blurRadius: 8,
                        ),
                      ],
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
                            : Padding(
                                key: const ValueKey('fingerprint'),
                                padding: const EdgeInsets.all(22),
                                child: Transform.scale(
                                  scale: 1 - 0.12 * t,
                                  child: SvgPicture.asset(
                                    'assets/svg/fingerprint.svg',
                                    colorFilter: const ColorFilter.mode(
                                      Color(0xFFEAF5EC),
                                      BlendMode.srcIn,
                                    ),
                                    width: 44,
                                    height: 44,
                                  ),
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
