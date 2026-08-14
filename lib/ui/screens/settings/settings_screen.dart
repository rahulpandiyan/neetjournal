import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';

import '../../../state/providers.dart';
import '../../widgets/widgets.dart';
import 'note_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const ScreenHeader(
              title: 'Settings',
              subtitle: 'Focus, reminders, and your NEET date',
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 6, 20, 32),
                children: [
                  const Reveal(
                    child: SoftCard(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: [
                          _ExamDateTile(),
                          Divider(),
                          _PomodoroTile(),
                          Divider(),
                          _WaterReminderTile(),
                          Divider(),
                          _StretchReminderTile(),
                          Divider(),
                          _NotificationsTile(),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Reveal(
                    delay: const Duration(milliseconds: 120),
                    child: SoftCard(
                      padding: EdgeInsets.zero,
                      clipBehavior: Clip.antiAlias,
                      child: ListTile(
                        leading: const IconBubble(
                          icon: filledHeart,
                          color: Color(0xFFE53950),
                          iconColor: Colors.white,
                          size: 34,
                          radius: 12,
                          iconSize: 18,
                        ),
                        title: const Text(
                          'A Note for You',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: const Text(
                          'A letter from Rahul',
                          style: TextStyle(fontSize: 13),
                        ),
                        trailing: const HugeIcon(
                          icon: HugeIcons.strokeRoundedArrowRight02,
                        ),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const NoteScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Reveal(
                    delay: const Duration(milliseconds: 200),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            HugeIcon(
                              icon: filledHeart,
                              color: theme.colorScheme.primary,
                              size: 15,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                'Made with ❤️ by Rahul — Bro, I\'ll see you at the finish line.',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
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
                ],
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
        leading: HugeIcon(icon: HugeIcons.strokeRoundedCalendar01),
        title: Text('Exam date'),
        subtitle: Text('Loading...'),
      ),
      error: (e, _) => ListTile(title: Text('$e')),
      data: (exam) => ListTile(
        leading: const HugeIcon(icon: HugeIcons.strokeRoundedCalendar01),
        title: const Text('NEET Exam Date'),
        subtitle: Text(DateFormat('d MMMM yyyy').format(exam)),
        trailing: const HugeIcon(icon: HugeIcons.strokeRoundedArrowRight02),
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
              leading: const HugeIcon(icon: HugeIcons.strokeRoundedTimer01),
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
        secondary: HugeIcon(icon: HugeIcons.strokeRoundedDrink),
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
              secondary: const HugeIcon(icon: HugeIcons.strokeRoundedDrink),
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

class _StretchReminderTile extends ConsumerWidget {
  const _StretchReminderTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stretchAsync = ref.watch(stretchReminderProvider);
    return stretchAsync.when(
      loading: () => const SwitchListTile(
        secondary: HugeIcon(icon: HugeIcons.strokeRoundedYoga01),
        title: Text('Stretch reminder'),
        subtitle: Text('Loading...'),
        value: false,
        onChanged: null,
      ),
      error: (e, _) => ListTile(title: Text('$e')),
      data: (stretch) {
        final (enabled: enabled, minutes: minutes) = stretch;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              secondary: const HugeIcon(icon: HugeIcons.strokeRoundedYoga01),
              title: const Text('Stretch reminder'),
              subtitle: const Text(
                'Stand up and move for 30 seconds during every session',
              ),
              value: enabled,
              onChanged: (v) => ref
                  .read(settingsRepositoryProvider)
                  .setStretchReminder(v, minutes),
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
                        max: 45,
                        divisions: 6,
                        label: '$minutes min',
                        onChanged: (v) => ref
                            .read(settingsRepositoryProvider)
                            .setStretchReminder(enabled, v.round()),
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

class _NotificationsTile extends ConsumerWidget {
  const _NotificationsTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefsAsync = ref.watch(notificationPrefsProvider);
    return prefsAsync.when(
      loading: () => const ListTile(
        leading: HugeIcon(icon: HugeIcons.strokeRoundedNotification01),
        title: Text('Notifications'),
        subtitle: Text('Loading...'),
      ),
      error: (e, _) => ListTile(title: Text('$e')),
      data: (prefs) {
        final repo = ref.read(settingsRepositoryProvider);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              secondary: const HugeIcon(icon: HugeIcons.strokeRoundedClock02),
              title: const Text('Study reminders'),
              subtitle: const Text(
                'A nudge before and when each study slot starts',
              ),
              value: prefs.study,
              onChanged: (v) async {
                await repo.setNotificationPrefs(study: v);
                await syncNotifications(ref);
              },
            ),
            SwitchListTile(
              secondary: const HugeIcon(icon: HugeIcons.strokeRoundedYoga01),
              title: const Text('Rest reminders'),
              subtitle: const Text(
                '“Session complete. Take a break” at the end of each slot',
              ),
              value: prefs.rest,
              onChanged: (v) async {
                await repo.setNotificationPrefs(rest: v);
                await syncNotifications(ref);
              },
            ),
            SwitchListTile(
              secondary: const HugeIcon(icon: HugeIcons.strokeRoundedRefresh01),
              title: const Text('Revision reminders'),
              subtitle: const Text(
                'A reminder when a revision task is due today',
              ),
              value: prefs.revision,
              onChanged: (v) async {
                await repo.setNotificationPrefs(revision: v);
                await syncNotifications(ref);
              },
            ),
            SwitchListTile(
              secondary: const HugeIcon(icon: HugeIcons.strokeRoundedSun01),
              title: const Text('Morning greeting'),
              subtitle: const Text(
                'Good morning + days left to NEET, at wake-up',
              ),
              value: prefs.morning,
              onChanged: (v) async {
                await repo.setNotificationPrefs(morning: v);
                await syncNotifications(ref);
              },
            ),
            SwitchListTile(
              secondary: const HugeIcon(icon: HugeIcons.strokeRoundedMoon01),
              title: const Text('Sleep reminder'),
              subtitle: const Text('Time to sleep and reset for tomorrow'),
              value: prefs.sleep,
              onChanged: (v) async {
                await repo.setNotificationPrefs(sleep: v);
                await syncNotifications(ref);
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ref
                            .read(notificationsServiceProvider)
                            .showImmediately(
                              title: 'Studyn',
                              body: 'Reminders are working. Keep going!',
                            );
                      },
                      icon: const HugeIcon(
                        icon: HugeIcons.strokeRoundedNotification02,
                      ),
                      label: const Text('Send test reminder'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
        );
      },
    );
  }
}
