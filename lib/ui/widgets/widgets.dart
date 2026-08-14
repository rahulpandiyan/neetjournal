import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heroicons/heroicons.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../core/db/database.dart';
import '../../core/db/tables.dart';
import '../../state/providers.dart';

/// Filled heart glyph (path data for [HugeIcon]).
const List<List<dynamic>> filledHeart = [
  [
    'path',
    {
      'd':
          'M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 '
          '2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09 '
          'C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5 '
          'c0 3.78-3.4 6.86-8.55 11.54L12 21.35z',
      'fill': 'currentColor',
    },
  ],
];

/// Rounded-square chip that holds a HugeIcon, used as a recurring visual motif
/// (section headers, list leading badges, header accents).
class IconBubble extends StatelessWidget {
  const IconBubble({
    super.key,
    required this.icon,
    this.size = 26,
    this.radius = 8,
    this.iconSize = 15,
    this.color,
    this.iconColor,
    this.child,
  });

  final List<List<dynamic>> icon;
  final double size;
  final double radius;
  final double iconSize;
  final Color? color;
  final Color? iconColor;

  /// Optional custom icon widget (e.g. a [HeroIcon]); takes precedence over
  /// [icon].
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color ?? scheme.primaryContainer,
        borderRadius: BorderRadius.circular(radius),
      ),
      child:
          child ??
          HugeIcon(
            icon: icon,
            size: iconSize,
            color: iconColor ?? scheme.onPrimaryContainer,
          ),
    );
  }
}

/// Heroicons-style check state: a clean outline check-circle when [done],
/// an empty circle otherwise. Used for completion states across the app.
class HeroCheck extends StatelessWidget {
  const HeroCheck({super.key, required this.done, this.color, this.size = 22});

  final bool done;
  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (done) {
      return HeroIcon(
        HeroIcons.checkCircle,
        style: HeroIconStyle.outline,
        color: color,
        size: size,
      );
    }
    final borderColor = color ?? Theme.of(context).colorScheme.outlineVariant;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 1.5),
      ),
    );
  }
}

/// Fixed app header: clean bold title + subtitle with a slim brand accent.
/// Shared across tabs; screens pin it above their scrollable content.
class ScreenHeader extends StatelessWidget {
  const ScreenHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.action,
    this.showBack,
    this.padding = const EdgeInsets.fromLTRB(20, 16, 20, 10),
  });

  final String title;
  final String subtitle;
  final Widget? action;

  /// When `null` (default), a back button is shown automatically whenever
  /// the route can pop (i.e. this screen was pushed), so desktop/web users
  /// without a system back gesture always have a way back.
  final bool? showBack;

  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final back = showBack ?? Navigator.maybeOf(context)?.canPop() ?? false;
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (back) ...[
                IconButton(
                  onPressed: () => Navigator.maybePop(context),
                  tooltip: 'Back',
                  icon: const HugeIcon(
                    icon: HugeIcons.strokeRoundedArrowLeft01,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 4),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.6,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (action != null) ...[const SizedBox(width: 12), action!],
            ],
          ),
        ],
      ),
    );
  }
}

/// Neumorphic surface: soft dual shadows (light highlight top-left, shade
/// bottom-right) so cards read as gently raised "soft 3D" tiles.
List<BoxShadow> softShadows(BuildContext context, {double strength = 1}) {
  if (Theme.of(context).brightness == Brightness.dark) {
    return [
      BoxShadow(
        color: const Color(0xFF000000).withValues(alpha: 0.42 * strength),
        offset: const Offset(6, 6),
        blurRadius: 14,
      ),
      BoxShadow(
        color: Colors.white.withValues(alpha: 0.045 * strength),
        offset: const Offset(-4, -4),
        blurRadius: 10,
      ),
    ];
  }
  return [
    BoxShadow(
      color: Colors.white.withValues(alpha: 0.95 * strength),
      offset: const Offset(-6, -6),
      blurRadius: 14,
    ),
    BoxShadow(
      color: const Color(0xFF33402F).withValues(alpha: 0.10 * strength),
      offset: const Offset(6, 7),
      blurRadius: 16,
    ),
  ];
}

/// Card with a touch of neumorphism — drop-in replacement for [Card] used by
/// the main screens. Falls back to a plain surface when [neumorphic] is off
/// (for inset/colored tiles that shouldn't float).
class SoftCard extends StatelessWidget {
  const SoftCard({
    super.key,
    this.margin,
    this.padding,
    this.color,
    this.radius = 24,
    this.neumorphic = true,
    this.border,
    this.clipBehavior = Clip.none,
    required this.child,
  });

  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final double radius;
  final bool neumorphic;
  final BoxBorder? border;
  final Clip clipBehavior;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final r = BorderRadius.circular(radius);
    // The Material IS the card surface (color + shape), so child ListTiles
    // find it as their nearest Material ancestor and their ink splashes paint
    // on it visibly. Shadow/border live on a color-free outer box, which the
    // framework's "ListTile background may be invisible" check ignores.
    final surface = Material(
      color: color ?? scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: r),
      clipBehavior: clipBehavior,
      child: padding == null ? child : Padding(padding: padding!, child: child),
    );
    if (!neumorphic && border == null) {
      return Container(margin: margin, child: surface);
    }
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: r,
        border: border,
        boxShadow: neumorphic ? softShadows(context) : null,
      ),
      child: surface,
    );
  }
}

/// Subtle 3D: the child gently scales down while pressed, then springs back.
class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.onPress,
    required this.child,
    this.scale = 0.97,
  });

  final VoidCallback onPress;
  final Widget child;
  final double scale;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressed ? widget.scale : 1,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.onPress,
        child: widget.child,
      ),
    );
  }
}

/// One-shot entrance motion: fades [child] in once, after [delay]. Use
/// staggered delays for a cascading list of cards.
///
/// Fade-only on purpose: transform/scale entrance animations inside a
/// scrollable can leave render-parent data dirty during a semantics flush,
/// which trips `!semantics.parentDataDirty` on some devices. A plain fade
/// (render-only, no transform layer) is semantics-clean everywhere.
class Reveal extends StatefulWidget {
  const Reveal({super.key, required this.child, this.delay = Duration.zero});

  final Widget child;
  final Duration delay;

  @override
  State<Reveal> createState() => _RevealState();
}

class _RevealState extends State<Reveal> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 380),
  );

  late final Animation<double> _opacity = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOut,
  );

  @override
  void initState() {
    super.initState();
    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _opacity, child: widget.child);
  }
}

/// Section header with a small icon chip + bold title.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    required this.icon,
    this.iconWidget,
    this.color,
    this.iconColor,
    this.padding = EdgeInsets.zero,
  });

  final String title;
  final List<List<dynamic>> icon;
  final Widget? iconWidget;
  final Color? color;
  final Color? iconColor;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: padding,
      child: Row(
        children: [
          IconBubble(
            icon: icon,
            size: 26,
            radius: 8,
            iconSize: 15,
            color: color,
            iconColor: iconColor,
            child: iconWidget,
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

/// Small-caps section label with the signature leading accent bar.
class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key, this.trailing, this.accent});

  final String title;
  final Widget? trailing;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: accent ?? theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.onSurface,
            letterSpacing: 0.4,
          ),
        ),
        const Spacer(),
        ?trailing,
      ],
    );
  }
}

/// Subject → chapters checklist. Each subject is a card showing a progress bar;
/// tapping expands it into a chapter list where completed chapters are ticked.
class ChapterChecklist extends ConsumerStatefulWidget {
  const ChapterChecklist({super.key, this.initialExpanded = const <int>{}});

  final Set<int> initialExpanded;

  @override
  ConsumerState<ChapterChecklist> createState() => _ChapterChecklistState();
}

class _ChapterChecklistState extends ConsumerState<ChapterChecklist> {
  late final Set<int> _expanded = {...widget.initialExpanded};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subjects = ref.watch(subjectsProvider).valueOrNull ?? const [];
    final chapters =
        ref.watch(chaptersBySubjectProvider).valueOrNull ?? const {};
    final counts = ref.watch(chapterProgressProvider).valueOrNull ?? const {};
    final repo = ref.read(progressRepositoryProvider);

    if (subjects.isEmpty) {
      return Text(
        'No subjects yet. Add sessions in the timetable first.',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }

    return Column(
      children: [
        for (final s in subjects)
          Builder(
            builder: (context) {
              final c = counts[s.id];
              final total = c?.$1 ?? 0;
              final learned = c?.$2 ?? 0;
              final pct = total == 0 ? 0.0 : learned / total;
              final expanded = _expanded.contains(s.id);
              final color = Color(s.colorValue);
              final list = chapters[s.id] ?? const <Chapter>[];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () => setState(() {
                        if (!_expanded.add(s.id)) _expanded.remove(s.id);
                      }),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          s.name,
                                          style: theme.textTheme.titleSmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.w700,
                                              ),
                                        ),
                                      ),
                                      Text(
                                        '$learned/$total',
                                        style: theme.textTheme.labelLarge
                                            ?.copyWith(
                                              color: color,
                                              fontFeatures: const [
                                                FontFeature.tabularFigures(),
                                              ],
                                            ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(5),
                                    child: LinearProgressIndicator(
                                      value: pct,
                                      minHeight: 8,
                                      color: color,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        total == 0
                                            ? 'No chapters yet'
                                            : '$learned of $total chapters learned',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: theme
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                            ),
                                      ),
                                      AnimatedRotation(
                                        turns: expanded ? 0.5 : 0,
                                        duration: const Duration(
                                          milliseconds: 200,
                                        ),
                                        child: HugeIcon(
                                          icon: HugeIcons
                                              .strokeRoundedArrowDown02,
                                          size: 18,
                                          color: theme
                                              .colorScheme
                                              .onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (expanded)
                      Column(
                        children: [
                          Divider(height: 1),
                          for (final ch in list)
                            _ChapterRow(
                              chapter: ch,
                              color: color,
                              onChanged: (learned) => repo.setChapterStatus(
                                ch,
                                learned
                                    ? ChapterStatus.learned
                                    : ChapterStatus.todo,
                              ),
                            ),
                        ],
                      ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}

class _ChapterRow extends StatelessWidget {
  const _ChapterRow({
    required this.chapter,
    required this.color,
    required this.onChanged,
  });

  final Chapter chapter;
  final Color color;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final learned = chapter.status == ChapterStatus.learned;
    return InkWell(
      onTap: () => onChanged(!learned),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        child: Row(
          children: [
            HeroCheck(
              done: learned,
              color: learned ? color : theme.colorScheme.outlineVariant,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                chapter.name,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: learned ? FontWeight.w600 : FontWeight.w400,
                  color: learned
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onSurfaceVariant,
                  decoration: learned ? TextDecoration.lineThrough : null,
                  decorationColor: theme.colorScheme.outline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A button that only fires after the user presses and HOLDS it for
/// [duration]. Fills up as you hold; releasing early cancels it.
class HoldToConfirmButton extends StatefulWidget {
  const HoldToConfirmButton({
    super.key,
    required this.onConfirmed,
    required this.label,
    this.icon = HugeIcons.strokeRoundedStop,
    this.color,
    this.duration = const Duration(milliseconds: 1600),
  });

  final VoidCallback onConfirmed;
  final String label;
  final List<List<dynamic>> icon;
  final Color? color;
  final Duration duration;

  @override
  State<HoldToConfirmButton> createState() => _HoldToConfirmButtonState();
}

class _HoldToConfirmButtonState extends State<HoldToConfirmButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progress =
      AnimationController(vsync: this, duration: widget.duration)
        ..addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            widget.onConfirmed();
            _progress.reverse();
          }
        });

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = widget.color ?? scheme.error;
    return Semantics(
      button: true,
      label: widget.label,
      hint: 'Press and hold to confirm',
      child: GestureDetector(
        onTapDown: (_) => _progress.forward(),
        onTapUp: (_) => _progress.reverse(),
        onTapCancel: _progress.reverse,
        child: AnimatedBuilder(
          animation: _progress,
          builder: (context, _) {
            final t = _progress.value;
            return ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                height: 54,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: color.withValues(alpha: 0.5)),
                ),
                clipBehavior: Clip.antiAlias,
                alignment: Alignment.center,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: t,
                        child: Container(color: color.withValues(alpha: 0.85)),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        HugeIcon(
                          icon: widget.icon,
                          size: 20,
                          color: scheme.onErrorContainer,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.label,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: scheme.onErrorContainer,
                          ),
                        ),
                        if (t > 0 && t < 1) ...[
                          const SizedBox(width: 8),
                          Text(
                            '${(t * 100).round()}%',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: scheme.onErrorContainer,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
