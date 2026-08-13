import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/database.dart';
import '../../core/db/tables.dart';
import '../../state/providers.dart';

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
                                        child: Icon(
                                          Icons.keyboard_arrow_down_rounded,
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
            Icon(
              learned ? Icons.check_circle_rounded : Icons.circle_outlined,
              size: 22,
              color: learned ? color : theme.colorScheme.outlineVariant,
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
    this.icon = Icons.stop_circle_outlined,
    this.color,
    this.duration = const Duration(milliseconds: 1600),
  });

  final VoidCallback onConfirmed;
  final String label;
  final IconData icon;
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
        onLongPressEnd: (_) => _progress.reverse(),
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
                        Icon(
                          widget.icon,
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
