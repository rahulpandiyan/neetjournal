import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../state/providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Settings',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            const _ExamDateTile(),
            const Divider(),
            const _PomodoroTile(),
            const Divider(),
            const _WaterReminderTile(),
            const Divider(),
            Card(
              margin: EdgeInsets.zero,
              child: const ListTile(
                leading: Icon(Icons.notifications_none),
                title: Text('Notifications'),
                subtitle: Text(
                  'Study, rest and sleep reminders arrive in the next milestone.',
                ),
                enabled: false,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'The app is a coach, not a controller.\nMissed sessions? Just decide what to do next — no guilt.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExamDateTile extends ConsumerStatefulWidget {
  const _ExamDateTile();

  @override
  ConsumerState<_ExamDateTile> createState() => _ExamDateTileState();
}

class _ExamDateTileState extends ConsumerState<_ExamDateTile> {
  @override
  Widget build(BuildContext context) {
    final examAsync = ref.watch(examDateProvider);
    return examAsync.when(
      loading: () => const ListTile(
        leading: Icon(Icons.event),
        title: Text('Exam date'),
        subtitle: Text('Loading...'),
      ),
      error: (e, _) => ListTile(title: Text('$e')),
      data: (exam) => ListTile(
        leading: const Icon(Icons.event),
        title: const Text('NEET Exam Date'),
        subtitle: Text(DateFormat('d MMMM yyyy').format(exam)),
        trailing: const Icon(Icons.chevron_right),
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: exam,
            firstDate: DateTime.now(),
            lastDate: DateTime(2030, 12, 31),
          );
          if (picked != null) {
            await ref.read(settingsRepositoryProvider).setExamDate(picked);
          }
        },
      ),
    );
  }
}

class _PomodoroTile extends ConsumerStatefulWidget {
  const _PomodoroTile();

  @override
  ConsumerState<_PomodoroTile> createState() => _PomodoroTileState();
}

class _PomodoroTileState extends ConsumerState<_PomodoroTile> {
  static const _presets = [
    (name: '25/5', focus: 25, brk: 5),
    (name: '50/10', focus: 50, brk: 10),
    (name: '60/10', focus: 60, brk: 10),
    (name: '90/15', focus: 90, brk: 15),
    (name: 'Custom', focus: -1, brk: -1),
  ];

  @override
  Widget build(BuildContext context) {
    final durationsAsync = ref.watch(focusDurationsProvider);
    return durationsAsync.when(
      loading: () => const ListTile(title: Text('Focus timer')),
      error: (e, _) => ListTile(title: Text('$e')),
      data: (d) {
        final currentName =
            _presets.any((p) => p.focus == d.$1 && p.brk == d.$2)
            ? _presets.firstWhere((p) => p.focus == d.$1 && p.brk == d.$2).name
            : 'Custom';
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: const Icon(Icons.timer_outlined),
              title: const Text('Focus timer'),
              subtitle: Text(
                'Focus ${d.$1} min · Break ${d.$2} min ($currentName)',
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final p in _presets)
                    ChoiceChip(
                      label: Text(p.name),
                      selected: currentName == p.name,
                      onSelected: (_) {
                        if (p.name == 'Custom') {
                          _showCustom(d);
                        } else {
                          ref
                              .read(settingsRepositoryProvider)
                              .setFocusDurations(p.focus, p.brk);
                        }
                      },
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  Future<void> _showCustom((int, int) d) async {
    var focus = d.$1;
    var brk = d.$2;
    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Custom timer'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              StatefulBuilder(
                builder: (ctx, setState) {
                  return Column(
                    children: [
                      Text('Focus: $focus min'),
                      Slider(
                        value: focus.toDouble(),
                        min: 15,
                        max: 120,
                        divisions: 21,
                        label: '$focus',
                        onChanged: (v) => setState(() => focus = v.round()),
                      ),
                      Text('Break: $brk min'),
                      Slider(
                        value: brk.toDouble(),
                        min: 5,
                        max: 30,
                        divisions: 5,
                        label: '$brk',
                        onChanged: (v) => setState(() => brk = v.round()),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                ref
                    .read(settingsRepositoryProvider)
                    .setFocusDurations(focus, brk);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

class _WaterReminderTile extends ConsumerWidget {
  const _WaterReminderTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final waterAsync = ref.watch(waterReminderProvider);
    return waterAsync.when(
      loading: () => const SwitchListTile(
        secondary: Icon(Icons.local_drink_outlined),
        title: Text('Drink water reminder'),
        subtitle: Text('Loading...'),
        value: false,
        onChanged: null,
      ),
      error: (e, _) => ListTile(title: Text('$e')),
      data: (water) {
        final (enabled: enabled, minutes: minutes) = water;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              secondary: const Icon(Icons.local_drink_outlined),
              title: const Text('Drink water reminder'),
              subtitle: const Text(
                'A gentle reminder during every focus session',
              ),
              value: enabled,
              onChanged: (v) => ref
                  .read(settingsRepositoryProvider)
                  .setWaterReminder(v, minutes),
            ),
            if (enabled)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Text('Every'),
                    Expanded(
                      child: Slider(
                        value: minutes.toDouble(),
                        min: 15,
                        max: 60,
                        divisions: 9,
                        label: '$minutes min',
                        onChanged: (v) => ref
                            .read(settingsRepositoryProvider)
                            .setWaterReminder(enabled, v.round()),
                      ),
                    ),
                    Text('$minutes min'),
                  ],
                ),
              ),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }
}
