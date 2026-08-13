import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/db/database.dart';
import '../../../core/db/tables.dart';
import '../../../core/utils/dates.dart';
import '../../../state/providers.dart';

class JournalScreen extends ConsumerWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: DefaultTabController(
          length: 2,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Journal',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const TabBar(
                tabs: [
                  Tab(text: "Today's Entry"),
                  Tab(text: 'History'),
                ],
              ),
              const Expanded(
                child: TabBarView(children: [_TodayEntry(), _History()]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
  JournalMood? _mood;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _learned = TextEditingController(text: widget.entry?.learnedText ?? '');
    _mood = widget.entry?.mood;
  }

  @override
  void dispose() {
    _learned.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sessionsAsync = ref.watch(todaySessionsProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('What did I study?', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: sessionsAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('$e'),
              data: (sessions) {
                final study = sessions.where(
                  (s) =>
                      s.activityType == ActivityType.study ||
                      s.activityType == ActivityType.recovery,
                );
                if (study.isEmpty) {
                  return Text(
                    'Nothing recorded yet today.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final s in study)
                      ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                        ),
                        title: Text(s.title),
                        subtitle: s.learned != null
                            ? Text('Learned: ${s.learned}')
                            : null,
                      ),
                  ],
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text('What did I learn?', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        TextField(
          controller: _learned,
          minLines: 3,
          maxLines: 6,
          decoration: const InputDecoration(
            labelText: 'Write what you learned today...',
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: 20),
        Text('How was today?', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            for (final mood in JournalMood.values)
              ChoiceChip(
                label: Text(mood.label),
                selected: _mood == mood,
                onSelected: (_) => setState(() => _mood = mood),
              ),
          ],
        ),
        const SizedBox(height: 24),
        FilledButton(
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
          child: _saving
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('SAVE JOURNAL'),
        ),
      ],
    );
  }
}

class _History extends ConsumerWidget {
  const _History();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(journalHistoryProvider);
    return historyAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (entries) {
        if (entries.isEmpty) {
          return const Center(child: Text('No journal entries yet.'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: entries.length,
          itemBuilder: (context, i) {
            final e = entries[i];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: e.mood != null ? Text(e.mood!.emoji) : null,
                title: Text(
                  '${strToDate(e.date).day.toString().padLeft(2, '0')} '
                  '${DateFormat('MMM').format(strToDate(e.date))}',
                ),
                subtitle: e.learnedText.isEmpty
                    ? Text(
                        'No notes',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      )
                    : Text(
                        e.learnedText,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
              ),
            );
          },
        );
      },
    );
  }
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
