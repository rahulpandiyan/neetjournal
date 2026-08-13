import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/db/database.dart';
import '../../../core/db/tables.dart';
import '../../../core/utils/dates.dart';
import '../../../state/focus_controller.dart';
import '../../../state/providers.dart';
import '../../../state/today_controller.dart';
import '../../focus/start_session.dart';
import '../../widgets/countdown_card.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(todayProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: dataAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Something went wrong:\n$e')),
        data: (data) {
          final nowMin = minutesSinceMidnight(data.now);
          final nowSlot = _nowSlot(data.slots, nowMin);
          final nextSlot = _nextSlot(data.slots, nowMin);
          final missed = _missedSlots(data);

          return SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${greetingFor(data.now)} 👋',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          DateFormat('EEEE, d MMMM').format(data.now),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 16),
                        CountdownCard(daysLeft: data.daysLeft),
                        const SizedBox(height: 16),
                        _BadDayToggle(active: data.badDay, now: data.now),
                        if (data.badDay) ...[
                          const SizedBox(height: 16),
                          _BadDayCard(subjectIds: studySubjectIds(data.slots)),
                        ],
                        if (missed.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          _MissedCard(slots: missed),
                        ],
                        if (data.pending.isNotEmpty)
                          _PendingCard(pending: data.pending),
                        if (data.pending.isNotEmpty) const SizedBox(height: 16),
                        _NowCard(slot: nowSlot),
                        const SizedBox(height: 16),
                        if (nextSlot != null) ...[
                          _NextCard(slot: nextSlot),
                          const SizedBox(height: 24),
                        ],
                        Text(
                          'TODAY',
                          style: theme.textTheme.labelLarge?.copyWith(
                            letterSpacing: 1.5,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _TodayList(slots: data.slots, data: data),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  TimetableSlot? _nowSlot(List<TimetableSlot> slots, int nowMin) {
    TimetableSlot? ongoing;
    for (final s in slots) {
      if (s.startMin <= nowMin && nowMin < s.endMin) {
        if (ongoing == null || s.endMin > ongoing.endMin) ongoing = s;
      }
    }
    if (ongoing != null) return ongoing;
    for (final s in slots) {
      if (s.startMin == nowMin && s.endMin == s.startMin) return s;
    }
    return null;
  }

  TimetableSlot? _nextSlot(List<TimetableSlot> slots, int nowMin) {
    for (final s in slots) {
      if (s.startMin > nowMin) return s;
    }
    return null;
  }

  List<TimetableSlot> _missedSlots(TodayData data) {
    final nowMin = minutesSinceMidnight(data.now);
    return data.slots
        .where(
          (s) =>
              s.activityType.isStudyLike &&
              !s.isOptional &&
              !data.completedSlotIds.contains(s.id) &&
              s.endMin <= nowMin,
        )
        .toList();
  }
}

/// "NOW" — the session currently in progress (or the next one to start).
class _NowCard extends ConsumerWidget {
  const _NowCard({required this.slot});

  final TimetableSlot? slot;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final subjects = ref.watch(subjectsByIdProvider).valueOrNull;
    final s = slot;
    if (s == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No activity right now. Rest, or start a pending task.'),
        ),
      );
    }
    final subjectName = subjects?[s.subjectId]?.name;
    return Card(
      margin: EdgeInsets.zero,
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'NOW',
              style: theme.textTheme.labelLarge?.copyWith(
                letterSpacing: 1.5,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${timeOfDay(s.startMin)} – ${timeOfDay(s.endMin)}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 8),
            if (subjectName != null)
              Text(
                subjectName,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            Text(
              s.title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            if (s.target != null && s.target!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                s.target!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ],
            if (s.activityType.isStudyLike) ...[
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => _start(context, ref, s),
                child: const Text('START STUDY'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _start(
    BuildContext context,
    WidgetRef ref,
    TimetableSlot slot,
  ) async {
    final subjects = await ref.read(subjectsByIdProvider.future);
    final subjectName = subjects[slot.subjectId]?.name ?? slot.title;
    final durations = await ref
        .read(settingsRepositoryProvider)
        .focusDurations();
    if (!context.mounted) return;
    await StartSession.begin(
      context,
      ref.read(focusControllerProvider.notifier),
      slot,
      subjectName,
      durations.$1,
      durations.$2,
    );
  }
}

class _BadDayToggle extends ConsumerWidget {
  const _BadDayToggle({required this.active, required this.now});

  final bool active;
  final DateTime now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: SwitchListTile(
        secondary: Icon(
          Icons.sentiment_dissatisfied_outlined,
          color: theme.colorScheme.tertiary,
        ),
        title: const Text("I'm having a bad day"),
        subtitle: const Text('Reduce today to a 30-minute minimum per subject'),
        value: active,
        onChanged: (v) =>
            ref.read(settingsRepositoryProvider).setBadDay(now, v),
      ),
    );
  }
}

Set<int> studySubjectIds(List<TimetableSlot> slots) => slots
    .where((s) => s.activityType.isStudyLike && s.subjectId != null)
    .map((s) => s.subjectId!)
    .toSet();

class _BadDayCard extends ConsumerWidget {
  const _BadDayCard({required this.subjectIds});

  final Set<int> subjectIds;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final subjects = ref.watch(subjectsByIdProvider).valueOrNull;
    final names = [
      for (final id in subjectIds) subjects?[id]?.name,
    ].whereType<String>().toList();
    final onColor = theme.colorScheme.onTertiaryContainer;

    return Card(
      margin: EdgeInsets.zero,
      color: theme.colorScheme.tertiaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "TODAY'S MINIMUM",
              style: theme.textTheme.labelLarge?.copyWith(
                letterSpacing: 1.5,
                color: onColor,
              ),
            ),
            const SizedBox(height: 10),
            if (names.isEmpty)
              Text(
                'No study sessions today — rest up.',
                style: theme.textTheme.bodyMedium?.copyWith(color: onColor),
              )
            else
              for (final name in names)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '• $name — 30 min',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: onColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            const SizedBox(height: 8),
            Text(
              'Everything else can move.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: onColor,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Don't try to recover everything tonight. "
              'Do what you can and reset tomorrow.',
              style: theme.textTheme.bodySmall?.copyWith(color: onColor),
            ),
          ],
        ),
      ),
    );
  }
}

class _NextCard extends StatelessWidget {
  const _NextCard({required this.slot});

  final TimetableSlot slot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Icon(Icons.schedule, color: theme.colorScheme.primary),
        title: Text(
          'NEXT — ${timeOfDay(slot.startMin)}',
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(slot.title),
        ),
      ),
    );
  }
}

class _TodayList extends ConsumerWidget {
  const _TodayList({required this.slots, required this.data});

  final List<TimetableSlot> slots;
  final TodayData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studySlots = slots
        .where((s) => s.activityType.isStudyLike && !s.isOptional)
        .toList();
    return Column(
      children: [
        for (final s in studySlots)
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              data.completedSlotIds.contains(s.id)
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
              color: data.completedSlotIds.contains(s.id)
                  ? Colors.green
                  : Theme.of(context).colorScheme.outline,
            ),
            title: Text(
              s.title,
              style: TextStyle(
                decoration: data.completedSlotIds.contains(s.id)
                    ? TextDecoration.lineThrough
                    : null,
                color: data.completedSlotIds.contains(s.id)
                    ? Theme.of(context).colorScheme.onSurfaceVariant
                    : null,
              ),
            ),
            trailing: Text(
              timeOfDay(s.startMin),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
      ],
    );
  }
}

class _MissedCard extends ConsumerWidget {
  const _MissedCard({required this.slots});

  final List<TimetableSlot> slots;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final slot = slots.first;
    return Card(
      margin: EdgeInsets.zero,
      color: theme.colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${slot.title} was missed',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onErrorContainer,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'No guilt. Just decide what to do next.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.colorScheme.error,
                    foregroundColor: theme.colorScheme.onError,
                    minimumSize: const Size(120, 44),
                  ),
                  onPressed: () => _studyNow(context, ref, slot),
                  child: const Text('Study Now'),
                ),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(120, 44),
                  ),
                  onPressed: () => _moveLater(context, ref, slot),
                  child: const Text('Move Later'),
                ),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(120, 44),
                  ),
                  onPressed: () => _move(
                    context,
                    ref,
                    slot,
                    date: DateTime.now().add(const Duration(days: 1)),
                    label: 'Move Tomorrow',
                  ),
                  child: const Text('Tomorrow'),
                ),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(120, 44),
                  ),
                  onPressed: () => _moveToSaturday(context, ref, slot),
                  child: const Text('Saturday'),
                ),
                TextButton(
                  onPressed: () => _skip(context, ref, slot),
                  child: const Text('Skip'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _studyNow(
    BuildContext context,
    WidgetRef ref,
    TimetableSlot slot,
  ) async {
    final subjects = await ref.read(subjectsByIdProvider.future);
    final subjectName = subjects[slot.subjectId]?.name ?? slot.title;
    final durations = await ref
        .read(settingsRepositoryProvider)
        .focusDurations();
    if (!context.mounted) return;
    await StartSession.begin(
      context,
      ref.read(focusControllerProvider.notifier),
      slot,
      subjectName,
      durations.$1,
      durations.$2,
    );
  }

  Future<void> _moveLater(
    BuildContext context,
    WidgetRef ref,
    TimetableSlot slot,
  ) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: 19, minute: 0),
    );
    if (time == null) return;
    final startMin = time.hour * 60 + time.minute;
    final duration = slot.endMin - slot.startMin;
    await ref
        .read(timetableRepositoryProvider)
        .addOneOff(
          date: DateTime.now(),
          startMin: startMin,
          endMin: startMin + duration,
          subjectId: slot.subjectId,
          activityType: slot.activityType,
          title: slot.title,
          target: slot.target,
        );
  }

  Future<void> _move(
    BuildContext context,
    WidgetRef ref,
    TimetableSlot slot, {
    required DateTime date,
    required String label,
  }) async {
    final duration = slot.endMin - slot.startMin;
    await ref
        .read(timetableRepositoryProvider)
        .addOneOff(
          date: date,
          startMin: slot.startMin,
          endMin: slot.startMin + duration,
          subjectId: slot.subjectId,
          activityType: slot.activityType,
          title: slot.title,
          target: slot.target,
        );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$label — added to ${dateToStr(date)}')),
      );
    }
  }

  Future<void> _moveToSaturday(
    BuildContext context,
    WidgetRef ref,
    TimetableSlot slot,
  ) async {
    var sat = DateTime.now();
    while (sat.weekday != DateTime.saturday) {
      sat = sat.add(const Duration(days: 1));
    }
    await _move(context, ref, slot, date: sat, label: 'Moved to Saturday');
  }

  Future<void> _skip(
    BuildContext context,
    WidgetRef ref,
    TimetableSlot slot,
  ) async {
    final now = DateTime.now();
    await ref
        .read(sessionRepositoryProvider)
        .record(
          slotId: slot.id,
          subjectId: slot.subjectId,
          activityType: slot.activityType,
          title: slot.title,
          startedAt: DateTime(now.year, now.month, now.day, 0, 0),
          endedAt: now,
          status: SessionStatus.notCompleted,
          focusMinutes: 0,
        );
  }
}

class _PendingCard extends ConsumerWidget {
  const _PendingCard({required this.pending});

  final List<PendingTask> pending;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final subjects = ref.watch(subjectsByIdProvider).valueOrNull;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PENDING',
              style: theme.textTheme.labelLarge?.copyWith(
                letterSpacing: 1.5,
                color: theme.colorScheme.tertiary,
              ),
            ),
            const SizedBox(height: 8),
            for (final p in pending.take(3))
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  Icons.pending_outlined,
                  color: theme.colorScheme.tertiary,
                ),
                title: Text(p.description),
                subtitle: p.subjectId != null
                    ? Text(subjects?[p.subjectId]?.name ?? '')
                    : null,
                trailing: PopupMenuButton<String>(
                  onSelected: (action) => _handle(ref, action, p),
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
          ],
        ),
      ),
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
