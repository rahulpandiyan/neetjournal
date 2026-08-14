import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';

import '../../../core/db/database.dart';
import '../../../core/db/tables.dart';
import '../../../core/utils/dates.dart';
import '../../../state/providers.dart';
import '../../widgets/widgets.dart';

class JournalScreen extends StatelessWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: SafeArea(child: _JournalTabs()));
  }
}

/// Sleek pill-segmented navigation with swipeable pages.
class _JournalTabs extends StatefulWidget {
  const _JournalTabs();

  @override
  State<_JournalTabs> createState() => _JournalTabsState();
}

class _JournalTabsState extends State<_JournalTabs>
    with SingleTickerProviderStateMixin {
  late final TabController _tab = TabController(length: 3, vsync: this);

  static const _labels = ["Today's Entry", 'History', 'Pending'];

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ScreenHeader(
          title: 'Journal',
          subtitle: DateFormat('EEEE, d MMM').format(DateTime.now()),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _SegmentedTabs(controller: _tab, labels: _labels),
        ),
        const SizedBox(height: 4),
        Expanded(
          child: TabBarView(
            controller: _tab,
            children: const [_TodayEntry(), _History(), _PendingTab()],
          ),
        ),
      ],
    );
  }
}

class _SegmentedTabs extends StatelessWidget {
  const _SegmentedTabs({required this.controller, required this.labels});

  final TabController controller;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final index = controller.index;
        return Container(
          height: 46,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(999),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final segW = constraints.maxWidth / labels.length;
              return Stack(
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeOutCubic,
                    left: index * segW + 4,
                    top: 0,
                    bottom: 0,
                    width: segW - 8,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: scheme.primaryContainer,
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: [
                          BoxShadow(
                            color: scheme.primary.withValues(alpha: 0.18),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      for (var i = 0; i < labels.length; i++)
                        Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => controller.animateTo(i),
                            child: Center(
                              child: Text(
                                labels[i],
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: i == index
                                      ? FontWeight.w700
                                      : FontWeight.w600,
                                  color: i == index
                                      ? scheme.onPrimaryContainer
                                      : scheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Today's entry
// ---------------------------------------------------------------------------

class _TodayEntry extends ConsumerWidget {
  const _TodayEntry();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entryAsync = ref.watch(journalTodayProvider);
    return entryAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (entry) => _TodayEntryForm(entry: entry),
    );
  }
}

class _TodayEntryForm extends ConsumerStatefulWidget {
  const _TodayEntryForm({this.entry});

  final JournalEntry? entry;

  @override
  ConsumerState<_TodayEntryForm> createState() => _TodayEntryFormState();
}

class _TodayEntryFormState extends ConsumerState<_TodayEntryForm> {
  late final TextEditingController _learned;
  late final TextEditingController _pending;
  DateTime _pendingDue = DateTime.now();
  JournalMood? _mood;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _learned = TextEditingController(text: widget.entry?.learnedText ?? '');
    _pending = TextEditingController();
    _mood = widget.entry?.mood;
  }

  @override
  void dispose() {
    _learned.dispose();
    _pending.dispose();
    super.dispose();
  }

  Future<void> _addPending() async {
    final text = _pending.text.trim();
    if (text.isEmpty) return;
    await ref
        .read(pendingRepositoryProvider)
        .add(
          subjectId: null,
          description: text,
          dueDate: _pendingDue,
          source: 'journal',
        );
    if (!mounted) return;
    _pending.clear();
    setState(() {});
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Added to pending')));
  }

  bool _dueIn(int days) {
    final a = DateTime(_pendingDue.year, _pendingDue.month, _pendingDue.day);
    final target = DateTime.now().add(Duration(days: days));
    final b = DateTime(target.year, target.month, target.day);
    return a.isAtSameMomentAs(b);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        Reveal(
          child: _MoodCard(
            mood: _mood,
            onChanged: (m) => setState(() => _mood = m),
          ),
        ),
        const SizedBox(height: 20),
        Reveal(
          delay: const Duration(milliseconds: 60),
          child: const _StudyCard(),
        ),
        const SizedBox(height: 24),
        SectionHeader(
          title: 'What did I learn?',
          icon: HugeIcons.strokeRoundedIdea,
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _learned,
          minLines: 3,
          maxLines: 6,
          decoration: const InputDecoration(
            labelText: 'Write what you learned today...',
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: 24),
        SectionHeader(
          title: 'What is pending?',
          icon: HugeIcons.strokeRoundedFlag01,
        ),
        const SizedBox(height: 10),
        _PendingComposer(
          controller: _pending,
          dueIn: _dueIn,
          onSubmit: _addPending,
          onPickDate: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _pendingDue,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (date != null && mounted) {
              setState(() => _pendingDue = date);
            }
          },
          onDueSelected: (days) => setState(() {
            _pendingDue = DateTime.now().add(Duration(days: days));
          }),
        ),
        const SizedBox(height: 12),
        Reveal(
          delay: const Duration(milliseconds: 120),
          child: _PendingPreview(),
        ),
        const SizedBox(height: 24),
        SectionHeader(
          title: 'Chapters completed',
          icon: HugeIcons.strokeRoundedCheckmarkCircle01,
        ),
        const SizedBox(height: 6),
        Text(
          'Tick off chapters you finished. This feeds your progress stats.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        Reveal(
          delay: const Duration(milliseconds: 180),
          child: ChapterChecklist(),
        ),
        const SizedBox(height: 28),
        Reveal(
          delay: const Duration(milliseconds: 240),
          child: FilledButton.icon(
            onPressed: _saving
                ? null
                : () async {
                    final messenger = ScaffoldMessenger.of(context);
                    setState(() => _saving = true);
                    await ref
                        .read(journalRepositoryProvider)
                        .save(
                          day: DateTime.now(),
                          learnedText: _learned.text.trim(),
                          mood: _mood,
                          isComplete: true,
                        );
                    if (!mounted) return;
                    setState(() => _saving = false);
                    messenger.showSnackBar(
                      const SnackBar(content: Text('Journal saved')),
                    );
                  },
            icon: _saving
                ? SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: scheme.onPrimary,
                    ),
                  )
                : const HugeIcon(
                    icon: HugeIcons.strokeRoundedCheckmarkCircle01,
                    size: 20,
                  ),
            label: Text(_saving ? 'SAVING...' : 'SAVE JOURNAL'),
          ),
        ),
      ],
    );
  }
}

class _MoodCard extends StatelessWidget {
  const _MoodCard({required this.mood, required this.onChanged});

  final JournalMood? mood;
  final ValueChanged<JournalMood?> onChanged;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: 'How was today?',
              icon: HugeIcons.strokeRoundedSmile,
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                for (final m in JournalMood.values) ...[
                  if (m != JournalMood.values.first) const SizedBox(width: 8),
                  Expanded(
                    child: _MoodButton(
                      mood: m,
                      selected: mood == m,
                      onTap: () => onChanged(mood == m ? null : m),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MoodButton extends StatelessWidget {
  const _MoodButton({
    required this.mood,
    required this.selected,
    required this.onTap,
  });

  final JournalMood mood;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? scheme.tertiaryContainer
              : scheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? scheme.tertiary.withValues(alpha: 0.7)
                : scheme.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
        child: Column(
          children: [
            Text(mood.emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 6),
            Text(
              mood.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                color: selected
                    ? scheme.onTertiaryContainer
                    : scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StudyCard extends ConsumerWidget {
  const _StudyCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sessionsAsync = ref.watch(todaySessionsProvider);

    return SoftCard(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: "Today's study",
              icon: HugeIcons.strokeRoundedBook02,
            ),
            const SizedBox(height: 10),
            sessionsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: LinearProgressIndicator(),
              ),
              error: (e, _) => Text('$e'),
              data: (sessions) {
                final study = sessions
                    .where(
                      (s) =>
                          s.activityType == ActivityType.study ||
                          s.activityType == ActivityType.recovery,
                    )
                    .toList();
                if (study.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      'Nothing recorded yet today.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  );
                }
                return Column(
                  children: [
                    for (final s in study)
                      ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: scheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: HeroCheck(
                            done: true,
                            color: scheme.primary,
                            size: 18,
                          ),
                        ),
                        title: Text(
                          s.title,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: s.learned != null
                            ? Text('Learned: ${s.learned}')
                            : null,
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PendingComposer extends StatelessWidget {
  const _PendingComposer({
    required this.controller,
    required this.dueIn,
    required this.onSubmit,
    required this.onPickDate,
    required this.onDueSelected,
  });

  final TextEditingController controller;
  final bool Function(int days) dueIn;
  final VoidCallback onSubmit;
  final VoidCallback onPickDate;
  final ValueChanged<int> onDueSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SoftCard(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: 'Add something pending...',
                hintText: 'e.g. 20 PYQs from Electrostatics',
                prefixIcon: HugeIcon(
                  icon: HugeIcons.strokeRoundedPlusSign,
                  color: scheme.onSurfaceVariant,
                ),
              ),
              onSubmitted: (_) => onSubmit(),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                for (final (label, days) in const [
                  ('Today', 0),
                  ('Tomorrow', 1),
                  ('This week', 7),
                ])
                  ChoiceChip(
                    label: Text(label),
                    selected: dueIn(days),
                    onSelected: (_) => onDueSelected(days),
                  ),
                IconButton(
                  tooltip: 'Pick a date',
                  onPressed: onPickDate,
                  icon: const HugeIcon(
                    icon: HugeIcons.strokeRoundedCalendar01,
                    size: 20,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PendingPreview extends ConsumerWidget {
  const _PendingPreview();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final openAsync = ref.watch(openPendingProvider);

    return openAsync.when(
      loading: () => const SoftCard(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: LinearProgressIndicator(),
        ),
      ),
      error: (e, _) => SoftCard(
        margin: EdgeInsets.zero,
        child: Padding(padding: const EdgeInsets.all(16), child: Text('$e')),
      ),
      data: (open) {
        if (open.isEmpty) {
          return SoftCard(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: HugeIcon(
                      icon: HugeIcons.strokeRoundedHourglass,
                      size: 18,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Nothing pending. Clear head. 😌',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return SoftCard(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final p in open.take(5))
                  ListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    leading: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedHourglass,
                        size: 16,
                        color: scheme.tertiary,
                      ),
                    ),
                    title: Text(
                      p.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      dueLabel(p.dueDate),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: _dueColor(context, p.dueDate),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                if (open.length > 5)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
                    child: Text(
                      '${open.length - 5} more — see the Pending tab',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// History
// ---------------------------------------------------------------------------

class _History extends ConsumerWidget {
  const _History();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final historyAsync = ref.watch(journalHistoryProvider);
    return historyAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (entries) {
        if (entries.isEmpty) {
          return _EmptyState(
            icon: HugeIcons.strokeRoundedTransactionHistory,
            message:
                'No journal entries yet.\nStart today — it takes a minute.',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
          itemCount: entries.length,
          itemBuilder: (context, i) {
            final e = entries[i];
            final date = strToDate(e.date);
            return SoftCard(
              margin: const EdgeInsets.only(bottom: 10),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: e.mood != null
                            ? scheme.tertiaryContainer
                            : scheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Center(
                        child: e.mood != null
                            ? Text(
                                e.mood!.emoji,
                                style: const TextStyle(fontSize: 22),
                              )
                            : Text(
                                date.day.toString().padLeft(2, '0'),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat('EEE, d MMM yyyy').format(date),
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            e.learnedText.isEmpty ? 'No notes' : e.learnedText,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: e.learnedText.isEmpty
                                  ? scheme.onSurfaceVariant
                                  : scheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Pending
// ---------------------------------------------------------------------------

class _PendingTab extends ConsumerWidget {
  const _PendingTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final pendingAsync = ref.watch(allPendingProvider);
    final subjects = ref.watch(subjectsByIdProvider).valueOrNull;

    return pendingAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (tasks) {
        if (tasks.isEmpty) {
          return _EmptyState(
            icon: HugeIcons.strokeRoundedCheckmarkCircle01,
            message: 'No pending tasks.\nYou are all caught up. Nice.',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
          itemCount: tasks.length,
          itemBuilder: (context, i) {
            final t = tasks[i];
            final diff = daysUntil(DateTime.now(), strToDate(t.dueDate));
            final overdue = diff < 0;
            final statusColor = overdue
                ? theme.colorScheme.error
                : diff == 0
                ? theme.colorScheme.tertiary
                : theme.colorScheme.onSurfaceVariant;
            return SoftCard(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                contentPadding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: HugeIcon(
                    icon: overdue
                        ? HugeIcons.strokeRoundedAlert02
                        : diff == 0
                        ? HugeIcons.strokeRoundedRadioButton
                        : HugeIcons.strokeRoundedClock02,
                    size: 19,
                    color: statusColor,
                  ),
                ),
                title: Text(
                  t.description,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: t.subjectId != null
                    ? Text(
                        '${subjects?[t.subjectId]?.name ?? ''} · ${dueLabel(t.dueDate)}',
                      )
                    : Text(dueLabel(t.dueDate)),
                trailing: PopupMenuButton<String>(
                  onSelected: (action) => _handle(ref, action, t),
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'today', child: Text('Do Today')),
                    PopupMenuItem(
                      value: 'tomorrow',
                      child: Text('Move to Tomorrow'),
                    ),
                    PopupMenuItem(value: 'skip', child: Text('Skip')),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _handle(WidgetRef ref, String action, PendingTask task) async {
    final repo = ref.read(pendingRepositoryProvider);
    switch (action) {
      case 'today':
        await repo.moveTo(task.id, DateTime.now());
        break;
      case 'tomorrow':
        await repo.moveTo(task.id, DateTime.now().add(const Duration(days: 1)));
        break;
      case 'skip':
        await repo.setStatus(task.id, PendingStatus.skipped);
        break;
    }
    await syncNotifications(ref);
  }
}

// ---------------------------------------------------------------------------
// Shared bits
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.message});

  final List<List<dynamic>> icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHigh,
              shape: BoxShape.circle,
            ),
            child: HugeIcon(
              icon: icon,
              size: 30,
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

String dueLabel(String dueDate) {
  final d = strToDate(dueDate);
  final today = DateTime.now();
  final diff = daysUntil(today, d);
  if (diff < 0) return 'Overdue by ${-diff} day${diff == -1 ? '' : 's'}';
  if (diff == 0) return 'Due today';
  if (diff == 1) return 'Due tomorrow';
  return 'Due ${DateFormat('d MMM').format(d)}';
}

Color _dueColor(BuildContext context, String dueDate) {
  final diff = daysUntil(DateTime.now(), strToDate(dueDate));
  if (diff < 0) return Theme.of(context).colorScheme.error;
  if (diff == 0) return Theme.of(context).colorScheme.tertiary;
  return Theme.of(context).colorScheme.onSurfaceVariant;
}

extension on JournalMood {
  String get label {
    switch (this) {
      case JournalMood.difficult:
        return 'Difficult';
      case JournalMood.okay:
        return 'Okay';
      case JournalMood.good:
        return 'Good';
      case JournalMood.excellent:
        return 'Excellent';
    }
  }

  String get emoji {
    switch (this) {
      case JournalMood.difficult:
        return '😔';
      case JournalMood.okay:
        return '😐';
      case JournalMood.good:
        return '🙂';
      case JournalMood.excellent:
        return '😄';
    }
  }
}
