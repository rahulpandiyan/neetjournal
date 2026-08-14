import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../state/providers.dart';
import '../../widgets/widgets.dart';
import '../tests/tests_screen.dart';

class ProgressScreen extends ConsumerStatefulWidget {
  const ProgressScreen({super.key});

  @override
  ConsumerState<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends ConsumerState<ProgressScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const ScreenHeader(
              title: 'Progress',
              subtitle: 'Consistency and learning — not maximum hours.',
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 0),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionHeader(
                          title: 'Subjects & Chapters',
                          icon: HugeIcons.strokeRoundedBook02,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tap a subject to tick off the chapters you have learned.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Reveal(
                          delay: const Duration(milliseconds: 80),
                          child: const ChapterChecklist(),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                  Reveal(
                    delay: const Duration(milliseconds: 160),
                    child: const _TestTrackingCard(),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),
                        const SectionHeader(
                          title: 'This Week',
                          icon: HugeIcons.strokeRoundedCalendar02,
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                  Reveal(
                    delay: const Duration(milliseconds: 240),
                    child: _buildThisWeek(theme),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThisWeek(ThemeData theme) {
    final stats = ref.watch(weekStatsProvider).valueOrNull;
    if (stats == null) {
      return SoftCard(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Loading weekly stats…',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    final maxDaily = stats.dailyFocus.values.fold<int>(
      0,
      (a, b) => a > b ? a : b,
    );

    return SoftCard(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _StatTile(
                  label: 'Sessions',
                  value: '${stats.sessionsCompleted}',
                ),
                _StatTile(
                  label: 'Questions',
                  value: '${stats.questionsSolved}',
                ),
                _StatTile(
                  label: 'Revision',
                  value: '${stats.revisionSessions}',
                ),
                _StatTile(
                  label: 'Study time',
                  value: '${stats.focusMinutes ~/ 60}h',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '${stats.chaptersLearned} chapters learned overall',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            _DailyFocusChart(dailyFocus: stats.dailyFocus, maxValue: maxDaily),
          ],
        ),
      ),
    );
  }
}

class _TestTrackingCard extends StatelessWidget {
  const _TestTrackingCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SoftCard(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: IconBubble(
          icon: HugeIcons.strokeRoundedClipboard,
          color: theme.colorScheme.primaryContainer,
          iconColor: theme.colorScheme.onPrimaryContainer,
        ),
        title: Text(
          'Test Tracking',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: const Text('Record mock test scores and mistakes → revision'),
        trailing: HugeIcon(
          icon: HugeIcons.strokeRoundedArrowRight02,
          color: theme.colorScheme.outline,
        ),
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const TestsScreen())),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHigh.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: scheme.primary,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DailyFocusChart extends StatelessWidget {
  const _DailyFocusChart({required this.dailyFocus, required this.maxValue});

  final Map<int, int> dailyFocus;
  final int maxValue;

  static const _labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final barHeight = 96.0;
    final today = DateTime.now().weekday;

    return SizedBox(
      height: barHeight + 20,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var day = 1; day <= 7; day++)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '${dailyFocus[day] ?? 0}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontSize: 10,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOutCubic,
                      height: maxValue == 0
                          ? 2
                          : (dailyFocus[day] ?? 0) / maxValue * barHeight,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: day == today
                            ? LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  scheme.primary,
                                  scheme.primary.withValues(alpha: 0.7),
                                ],
                              )
                            : null,
                        color: day == today
                            ? null
                            : scheme.primary.withValues(alpha: 0.28),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _labels[day - 1],
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: day == today
                            ? scheme.primary
                            : scheme.onSurfaceVariant,
                        fontWeight: day == today
                            ? FontWeight.w800
                            : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
