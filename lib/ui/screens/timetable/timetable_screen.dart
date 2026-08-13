import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/database.dart';
import '../../../core/db/tables.dart';
import '../../../core/utils/dates.dart';
import '../../../state/providers.dart';

class TimetableScreen extends ConsumerStatefulWidget {
  const TimetableScreen({super.key});

  @override
  ConsumerState<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends ConsumerState<TimetableScreen> {
  late int _day = DateTime.now().weekday;

  static const _dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final template = ref.watch(templateByDayProvider);
    return Scaffold(
      body: SafeArea(
        child: template.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
          data: (byDay) {
            final slots = byDay[_day] ?? const <TimetableSlot>[];
            final isSunday = _day == kSunday;
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Timetable',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'The timetable guides; it never forces.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                SegmentedButton<int>(
                  segments: [
                    for (var i = 0; i < 7; i++)
                      ButtonSegment(value: i + 1, label: Text(_dayNames[i])),
                  ],
                  selected: {_day},
                  onSelectionChanged: (s) => setState(() => _day = s.first),
                ),
                if (isSunday) ...[
                  const SizedBox(height: 12),
                  Card(
                    margin: EdgeInsets.zero,
                    color: theme.colorScheme.tertiaryContainer,
                    child: const Padding(
                      padding: EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Icon(Icons.self_improvement),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Sunday is a protected recovery day. Study is optional — only the weekly planning is kept.',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                for (final s in slots) _SlotTile(slot: s),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SlotTile extends ConsumerWidget {
  const _SlotTile({required this.slot});

  final TimetableSlot slot;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final subjects = ref.watch(subjectsByIdProvider).valueOrNull;
    final subjectName = subjects?[slot.subjectId]?.name;

    final time = slot.endMin == slot.startMin
        ? timeOfDay(slot.startMin)
        : '${timeOfDay(slot.startMin)} – ${timeOfDay(slot.endMin)}';

    final icon = switch (slot.activityType) {
      ActivityType.study => Icons.menu_book,
      ActivityType.recovery => Icons.self_improvement,
      ActivityType.wake => Icons.wb_sunny,
      ActivityType.breakActivity => Icons.coffee,
      ActivityType.meal => Icons.restaurant,
      ActivityType.college => Icons.school,
      ActivityType.reset => Icons.autorenew,
      ActivityType.sleep => Icons.bedtime,
      ActivityType.planning => Icons.event_note,
      ActivityType.free => Icons.free_breakfast,
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
          child: Icon(icon, size: 20),
        ),
        title: Text(slot.title),
        subtitle: subjectName != null
            ? Text('$subjectName · $time')
            : Text(time),
        trailing: slot.isOptional
            ? const Icon(Icons.lock_open, size: 16)
            : null,
      ),
    );
  }
}
