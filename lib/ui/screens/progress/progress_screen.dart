import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/database.dart';
import '../../../core/db/tables.dart';
import '../../../state/providers.dart';
import '../tests/tests_screen.dart';

class ProgressScreen extends ConsumerStatefulWidget {
  const ProgressScreen({super.key});

  @override
  ConsumerState<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends ConsumerState<ProgressScreen> {
  final Set<int> _expanded = {};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Progress',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Consistency and learning — not maximum hours.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            _buildSubjectCards(theme),
            const SizedBox(height: 16),
            Card(
              margin: EdgeInsets.zero,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                leading: Icon(
                  Icons.assignment_outlined,
                  color: theme.colorScheme.primary,
                ),
                title: Text(
                  'Test Tracking',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: const Text(
                  'Record mock test scores and mistakes → revision',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const TestsScreen())),
              ),
            ),
            const SizedBox(height: 24),
            _buildThisWeek(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectCards(ThemeData theme) {
    final subjects = ref.watch(subjectsProvider).valueOrNull ?? const [];
    final chapters =
        ref.watch(chaptersBySubjectProvider).valueOrNull ?? const {};
    final counts = ref.watch(chapterProgressProvider).valueOrNull ?? const {};
    final repo = ref.read(progressRepositoryProvider);

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
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  s.name,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '${(pct * 100).round()}%',
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    color: Color(s.colorValue),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: pct,
                                minHeight: 8,
                                backgroundColor:
                                    theme.colorScheme.surfaceContainerHighest,
                                color: Color(s.colorValue),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '$learned of $total chapters learned',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                Icon(
                                  expanded
                                      ? Icons.expand_less
                                      : Icons.expand_more,
                                  size: 18,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (expanded)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                        child: Column(
                          children: [
                            for (final ch in list)
                              CheckboxListTile(
                                dense: true,
                                value: ch.status == ChapterStatus.learned,
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                activeColor: Color(s.colorValue),
                                title: Text(
                                  ch.name,
                                  style: theme.textTheme.bodySmall,
                                ),
                                onChanged: (checked) {
                                  repo.setChapterStatus(
                                    ch,
                                    checked!
                                        ? ChapterStatus.learned
                                        : ChapterStatus.todo,
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildThisWeek(ThemeData theme) {
    final stats = ref.watch(weekStatsProvider).valueOrNull;
    if (stats == null) {
      return Card(
        margin: EdgeInsets.zero,
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

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This Week',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
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

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
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
    final barHeight = 96.0;

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
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      height: maxValue == 0
                          ? 2
                          : (dailyFocus[day] ?? 0) / maxValue * barHeight,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: maxValue == 0
                            ? theme.colorScheme.surfaceContainerHighest
                            : theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _labels[day - 1],
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
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
