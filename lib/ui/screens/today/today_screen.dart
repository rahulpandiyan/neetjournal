import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';

import '../../../core/data/motivations.dart';
import '../../../core/db/database.dart';
import '../../../core/db/tables.dart';
import '../../../core/utils/dates.dart';
import '../../../state/focus_controller.dart';
import '../../../state/providers.dart';
import '../../../state/today_controller.dart';
import '../../focus/start_session.dart';
import '../../widgets/widgets.dart';
import '../../widgets/countdown_card.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(todayProvider);
    final name = ref.watch(profileNameProvider).valueOrNull ?? '';
    final motivation =
        ref.watch(dailyMotivationProvider).valueOrNull ??
        Motivations.daily(DateTime.now());

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ScreenHeader(
                  title: name.isEmpty
                      ? '${greetingFor(data.now)} 👋'
                      : '${greetingFor(data.now)}, $name 👋',
                  subtitle: DateFormat('EEEE, d MMMM').format(data.now),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 6, 20, 32),
                    children: [
                      CountdownCard(daysLeft: data.daysLeft),
                      const SizedBox(height: 16),
                      _MotivationCard(line: motivation),
                      const SizedBox(height: 16),
                      if (nextSlot != null) ...[
                        IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(child: _NextCard(slot: nextSlot)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _BadDayToggle(
                                  active: data.badDay,
                                  now: data.now,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else
                        _BadDayToggle(active: data.badDay, now: data.now),
                      if (data.badDay) ...[
                        const SizedBox(height: 16),
                        _BadDayCard(subjectIds: studySubjectIds(data.slots)),
                      ],
                      if (missed.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _MissedCard(slots: missed),
                      ],
                      if (data.pending.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _PendingCard(pending: data.pending),
                      ],
                      const SizedBox(height: 16),
                      _NowCard(slot: nowSlot),
                      const SizedBox(height: 24),
                      SectionHeader(
                        title: "Today's sessions",
                        icon: HugeIcons.strokeRoundedBook02,
                      ),
                      const SizedBox(height: 8),
                      _TodayList(slots: data.slots, data: data),
                    ],
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

/// Today's rotating motivational line.
class _MotivationCard extends StatelessWidget {
  const _MotivationCard({required this.line});

  final Motivation line;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Reveal(
      child: SoftCard(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconBubble(
              icon: HugeIcons.strokeRoundedQuotes,
              size: 34,
              radius: 12,
              iconSize: 18,
              color: scheme.tertiaryContainer,
              iconColor: scheme.onTertiaryContainer,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '"${line.text}"',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '— ${line.author}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (line.source != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      'via ZenQuotes',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: scheme.outline,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
      return Reveal(
        child: SoftCard(
          padding: const EdgeInsets.all(16),
          child: Text(
            'No activity right now. Rest, or start a pending task.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }
    final subjectName = subjects?[s.subjectId]?.name;
    final scheme = theme.colorScheme;
    return Reveal(
      delay: const Duration(milliseconds: 120),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              scheme.primaryContainer,
              scheme.primaryContainer.withValues(alpha: 0.55),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: scheme.primary.withValues(alpha: 0.16),
              offset: const Offset(0, 8),
              blurRadius: 20,
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const _LiveDot(),
                const SizedBox(width: 8),
                Text(
                  'NOW',
                  style: theme.textTheme.labelLarge?.copyWith(
                    letterSpacing: 1.5,
                    color: scheme.onPrimaryContainer,
                  ),
                ),
                const Spacer(),
                Text(
                  '${timeOfDay(s.startMin)} – ${timeOfDay(s.endMin)}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: scheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (subjectName != null)
              Text(
                subjectName,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: scheme.onPrimaryContainer,
                ),
              ),
            Text(
              s.title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: scheme.onPrimaryContainer,
              ),
            ),
            if (s.target != null && s.target!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                s.target!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onPrimaryContainer,
                ),
              ),
            ],
            if (s.activityType.isStudyLike) ...[
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => _start(context, ref, s),
                icon: const HugeIcon(
                  icon: HugeIcons.strokeRoundedPlay,
                  size: 18,
                ),
                label: const Text('START STUDY'),
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
    void toggle() =>
        ref.read(settingsRepositoryProvider).setBadDay(now, !active);
    return Reveal(
      delay: const Duration(milliseconds: 80),
      child: SoftCard(
        padding: EdgeInsets.zero,
        child: InkWell(
          onTap: toggle,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconBubble(
                      icon: HugeIcons.strokeRoundedSad01,
                      size: 30,
                      radius: 10,
                      iconSize: 17,
                      color: theme.colorScheme.tertiaryContainer,
                      iconColor: theme.colorScheme.onTertiaryContainer,
                    ),
                    const Spacer(),
                    ExcludeSemantics(
                      child: Switch(
                        value: active,
                        onChanged: (v) => ref
                            .read(settingsRepositoryProvider)
                            .setBadDay(now, v),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  "I'm having a bad day",
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Reduce today to a 30-minute minimum',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
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

    return SoftCard(
      margin: EdgeInsets.zero,
      color: theme.colorScheme.tertiaryContainer,
      neumorphic: false,
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
    );
  }
}

class _NextCard extends StatelessWidget {
  const _NextCard({required this.slot});

  final TimetableSlot slot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Reveal(
      delay: const Duration(milliseconds: 40),
      child: SoftCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconBubble(
                  icon: HugeIcons.strokeRoundedClock02,
                  size: 30,
                  radius: 10,
                  iconSize: 17,
                  color: theme.colorScheme.primaryContainer,
                  iconColor: theme.colorScheme.onPrimaryContainer,
                ),
                const Spacer(),
                Text(
                  timeOfDay(slot.startMin),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'NEXT',
              style: theme.textTheme.labelMedium?.copyWith(
                letterSpacing: 1.5,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              slot.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
          ],
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
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final studySlots = slots
        .where((s) => s.activityType.isStudyLike && !s.isOptional)
        .toList();
    return SoftCard(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        children: [
          for (final s in studySlots)
            Builder(
              builder: (context) {
                final done = data.completedSlotIds.contains(s.id);
                final badDayActive = data.badDay && !done;
                return ListTile(
                  dense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  leading: IconBubble(
                    icon: HugeIcons.strokeRoundedRadioButton,
                    color: done
                        ? scheme.primary.withValues(alpha: 0.14)
                        : scheme.surfaceContainerHighest,
                    iconColor: done ? scheme.primary : scheme.outline,
                    child: HeroCheck(
                      done: done,
                      color: done ? scheme.primary : scheme.outline,
                      size: 16,
                    ),
                  ),
                  title: Text(
                    s.title,
                    style: TextStyle(
                      decoration: done ? TextDecoration.lineThrough : null,
                      color: done ? scheme.onSurfaceVariant : null,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: badDayActive
                      ? Text(
                          '${timeOfDay(s.startMin)} · 30 min minimum',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.tertiary,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      : null,
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: badDayActive
                          ? scheme.tertiaryContainer
                          : scheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      badDayActive ? '30 MIN' : timeOfDay(s.startMin),
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: badDayActive
                            ? scheme.onTertiaryContainer
                            : scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
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
    return Reveal(
      child: SoftCard(
        margin: EdgeInsets.zero,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconBubble(
                  icon: HugeIcons.strokeRoundedClock02,
                  size: 40,
                  radius: 12,
                  iconSize: 20,
                  color: theme.colorScheme.errorContainer,
                  iconColor: theme.colorScheme.onErrorContainer,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${slot.title} was missed',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'No guilt. Just decide what to do next.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.colorScheme.error,
                    foregroundColor: theme.colorScheme.onError,
                    minimumSize: const Size(120, 44),
                  ),
                  onPressed: () => _studyNow(context, ref, slot),
                  icon: const HugeIcon(
                    icon: HugeIcons.strokeRoundedPlay,
                    size: 18,
                  ),
                  label: const Text('Study Now'),
                ),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(120, 44),
                  ),
                  onPressed: () => _moveLater(context, ref, slot),
                  icon: const HugeIcon(
                    icon: HugeIcons.strokeRoundedClock02,
                    size: 18,
                  ),
                  label: const Text('Move Later'),
                ),
                OutlinedButton.icon(
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
                  icon: const HugeIcon(
                    icon: HugeIcons.strokeRoundedCalendar02,
                    size: 18,
                  ),
                  label: const Text('Tomorrow'),
                ),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(120, 44),
                  ),
                  onPressed: () => _moveToSaturday(context, ref, slot),
                  icon: const HugeIcon(
                    icon: HugeIcons.strokeRoundedCalendar02,
                    size: 18,
                  ),
                  label: const Text('Saturday'),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Pending tasks',
          icon: HugeIcons.strokeRoundedHourglass,
        ),
        const SizedBox(height: 8),
        SoftCard(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            children: [
              for (final p in pending.take(3))
                ListTile(
                  dense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  leading: IconBubble(
                    icon: HugeIcons.strokeRoundedHourglass,
                    color: theme.colorScheme.tertiaryContainer,
                    iconColor: theme.colorScheme.onTertiaryContainer,
                  ),
                  title: Text(
                    p.description,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: p.subjectId != null
                      ? Text(
                          subjects?[p.subjectId]?.name ?? '',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        )
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
      ],
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

/// Softly pulsing dot used to signal "live" states (e.g. the NOW session).
class _LiveDot extends StatefulWidget {
  const _LiveDot();

  @override
  State<_LiveDot> createState() => _LiveDotState();
}

class _LiveDotState extends State<_LiveDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return FadeTransition(
      opacity: Tween<double>(begin: 0.35, end: 1).animate(_controller),
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.8, end: 1).animate(_controller),
        child: Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
      ),
    );
  }
}
