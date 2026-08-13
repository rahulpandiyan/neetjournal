import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';

import '../../../core/db/database.dart';
import '../../../core/db/tables.dart';
import '../../../core/utils/dates.dart';
import '../../../state/providers.dart';

class TestsScreen extends ConsumerWidget {
  const TestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final testsAsync = ref.watch(testsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Test Tracking')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addTest(context, ref),
        icon: const HugeIcon(icon: HugeIcons.strokeRoundedPlusSign),
        label: const Text('Record Test'),
      ),
      body: testsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (tests) {
          if (tests.isEmpty) {
            return const _EmptyState();
          }
          final avg =
              tests.fold<int>(0, (a, t) => a + t.totalScore) / tests.length;
          final best = tests.fold<int>(
            0,
            (a, t) => t.totalScore > a ? t.totalScore : a,
          );
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      _SummaryStat(label: 'Tests', value: '${tests.length}'),
                      _SummaryStat(label: 'Best total', value: '$best'),
                      _SummaryStat(
                        label: 'Average',
                        value: avg.round().toString(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              for (final t in tests) ...[
                _TestCard(test: t),
                const SizedBox(height: 8),
              ],
              const SizedBox(height: 88),
            ],
          );
        },
      ),
    );
  }

  Future<void> _addTest(BuildContext context, WidgetRef ref) async {
    final result = await showModalBottomSheet<_TestDraft>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _AddTestSheet(),
    );
    if (result == null) return;
    await ref
        .read(testRepositoryProvider)
        .addTest(
          date: result.date,
          physicsScore: result.physics,
          chemistryScore: result.chemistry,
          biologyScore: result.biology,
          notes: result.notes,
        );
  }
}

class _SummaryStat extends StatelessWidget {
  const _SummaryStat({required this.label, required this.value});

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
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends ConsumerWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            HugeIcon(
              icon: HugeIcons.strokeRoundedClipboard,
              size: 56,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'No tests recorded yet',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Record your mock test scores and the mistakes you made.\n'
              'Mistakes can become revision tasks.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TestCard extends ConsumerStatefulWidget {
  const _TestCard({required this.test});

  final Test test;

  @override
  ConsumerState<_TestCard> createState() => _TestCardState();
}

class _TestCardState extends ConsumerState<_TestCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = widget.test;
    final mistakesAsync = ref.watch(testMistakesProvider(t.id));

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        t.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (action) {
                          if (action == 'delete') _delete(context, t);
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(
                            value: 'delete',
                            child: Text('Delete test'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Text(
                    DateFormat('EEEE, d MMMM yyyy').format(strToDate(t.date)),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _ScoreChip(label: 'Phy', score: t.physicsScore),
                      const SizedBox(width: 8),
                      _ScoreChip(label: 'Che', score: t.chemistryScore),
                      const SizedBox(width: 8),
                      _ScoreChip(label: 'Bio', score: t.biologyScore),
                      const Spacer(),
                      Text(
                        '${t.totalScore}',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  if (t.notes != null && t.notes!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      t.notes!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Mistakes', style: theme.textTheme.titleSmall),
                      TextButton.icon(
                        onPressed: () => _addMistake(context, t),
                        icon: const HugeIcon(
                          icon: HugeIcons.strokeRoundedPlusSign,
                          size: 18,
                        ),
                        label: const Text('Add'),
                      ),
                    ],
                  ),
                  mistakesAsync.when(
                    loading: () => const LinearProgressIndicator(),
                    error: (e, _) => Text('$e'),
                    data: (mistakes) {
                      if (mistakes.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            'No mistakes recorded. Tap Add after reviewing.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        );
                      }
                      return Column(
                        children: [
                          for (final m in mistakes)
                            ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              leading: HugeIcon(
                                icon: m.isRevisioned
                                    ? HugeIcons.strokeRoundedCheckmarkCircle01
                                    : HugeIcons.strokeRoundedAlert02,
                                size: 20,
                                color: m.isRevisioned
                                    ? Colors.green
                                    : theme.colorScheme.tertiary,
                              ),
                              title: Text(m.description),
                              subtitle: Text(
                                '${m.category.label}'
                                '${m.subjectId != null ? ' · ${_subjectName(ref, m.subjectId!)}' : ''}',
                              ),
                              trailing: m.isRevisioned
                                  ? const HugeIcon(
                                      icon: HugeIcons.strokeRoundedRefresh01,
                                      size: 18,
                                      color: Colors.green,
                                    )
                                  : IconButton(
                                      tooltip: 'Add to revision',
                                      icon: const HugeIcon(
                                        icon: HugeIcons.strokeRoundedRadar01,
                                        size: 20,
                                      ),
                                      onPressed: () => ref
                                          .read(testRepositoryProvider)
                                          .convertMistakeToRevision(m),
                                    ),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _subjectName(WidgetRef ref, int id) {
    return ref.read(subjectsByIdProvider).valueOrNull?[id]?.name ?? '';
  }

  Future<void> _addMistake(BuildContext context, Test t) async {
    final result = await showModalBottomSheet<_MistakeDraft>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _AddMistakeSheet(test: t),
    );
    if (result == null) return;
    await ref
        .read(testRepositoryProvider)
        .addMistake(
          testId: t.id,
          subjectId: result.subjectId,
          category: result.category,
          description: result.description,
        );
  }

  Future<void> _delete(BuildContext context, Test t) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete test?'),
        content: Text('${t.name} and its mistakes will be removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(testRepositoryProvider).deleteTest(t.id);
    }
  }
}

class _ScoreChip extends StatelessWidget {
  const _ScoreChip({required this.label, required this.score});

  final String label;
  final int score;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label ',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            '$score',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _TestDraft {
  const _TestDraft({
    required this.date,
    required this.physics,
    required this.chemistry,
    required this.biology,
    this.notes,
  });

  final DateTime date;
  final int physics;
  final int chemistry;
  final int biology;
  final String? notes;
}

class _AddTestSheet extends ConsumerStatefulWidget {
  const _AddTestSheet();

  @override
  ConsumerState<_AddTestSheet> createState() => _AddTestSheetState();
}

class _AddTestSheetState extends ConsumerState<_AddTestSheet> {
  final _physics = TextEditingController();
  final _chemistry = TextEditingController();
  final _biology = TextEditingController();
  final _notes = TextEditingController();
  DateTime _date = DateTime.now();
  int? _nextNumber;

  @override
  void initState() {
    super.initState();
    ref
        .read(testRepositoryProvider)
        .nextTestNumber()
        .then((n) => setState(() => _nextNumber = n));
  }

  @override
  void dispose() {
    _physics.dispose();
    _chemistry.dispose();
    _biology.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final next = _nextNumber?.toString().padLeft(2, '0') ?? '?';

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Record Test', style: theme.textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              'NEET TEST #$next',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const HugeIcon(icon: HugeIcons.strokeRoundedCalendar01),
              title: Text(DateFormat('EEEE, d MMMM yyyy').format(_date)),
              trailing: const HugeIcon(icon: HugeIcons.strokeRoundedEdit02),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _date,
                  firstDate: DateTime(2026, 1, 1),
                  lastDate: DateTime(2030, 12, 31),
                );
                if (picked != null) setState(() => _date = picked);
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _scoreField(_physics, 'Physics')),
                const SizedBox(width: 8),
                Expanded(child: _scoreField(_chemistry, 'Chemistry')),
                const SizedBox(width: 8),
                Expanded(child: _scoreField(_biology, 'Biology')),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notes,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () {
                final p = int.tryParse(_physics.text.trim()) ?? 0;
                final c = int.tryParse(_chemistry.text.trim()) ?? 0;
                final b = int.tryParse(_biology.text.trim()) ?? 0;
                Navigator.of(context).pop(
                  _TestDraft(
                    date: _date,
                    physics: p,
                    chemistry: c,
                    biology: b,
                    notes: _notes.text.trim().isEmpty
                        ? null
                        : _notes.text.trim(),
                  ),
                );
              },
              child: Text('SAVE TEST · $totalPoints pts'),
            ),
          ],
        ),
      ),
    );
  }

  int get totalPoints =>
      (int.tryParse(_physics.text.trim()) ?? 0) +
      (int.tryParse(_chemistry.text.trim()) ?? 0) +
      (int.tryParse(_biology.text.trim()) ?? 0);

  Widget _scoreField(TextEditingController c, String label) {
    return TextField(
      controller: c,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(labelText: label),
    );
  }
}

class _MistakeDraft {
  const _MistakeDraft({
    required this.subjectId,
    required this.category,
    required this.description,
  });

  final int? subjectId;
  final MistakeCategory category;
  final String description;
}

class _AddMistakeSheet extends ConsumerStatefulWidget {
  const _AddMistakeSheet({required this.test});

  final Test test;

  @override
  ConsumerState<_AddMistakeSheet> createState() => _AddMistakeSheetState();
}

class _AddMistakeSheetState extends ConsumerState<_AddMistakeSheet> {
  final _description = TextEditingController();
  MistakeCategory _category = MistakeCategory.silly;
  int? _subjectId;

  @override
  void dispose() {
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subjects = ref.watch(subjectsProvider).valueOrNull ?? const [];

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add Mistake', style: theme.textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              '${widget.test.name} · A mistake can become a revision task later.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Text('Category', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final cat in MistakeCategory.values)
                  ChoiceChip(
                    label: Text(cat.label),
                    selected: _category == cat,
                    onSelected: (_) => setState(() => _category = cat),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (subjects.isNotEmpty) ...[
              DropdownButtonFormField<int>(
                initialValue: _subjectId,
                decoration: const InputDecoration(labelText: 'Subject'),
                items: [
                  for (final s in subjects)
                    DropdownMenuItem(value: s.id, child: Text(s.name)),
                ],
                onChanged: (v) => setState(() => _subjectId = v),
              ),
              const SizedBox(height: 12),
            ],
            TextField(
              controller: _description,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'What went wrong?',
                hintText: 'e.g. Misapplied Lenz law sign',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () {
                final text = _description.text.trim();
                if (text.isEmpty) return;
                Navigator.of(context).pop(
                  _MistakeDraft(
                    subjectId: _subjectId,
                    category: _category,
                    description: text,
                  ),
                );
              },
              child: const Text('SAVE MISTAKE'),
            ),
          ],
        ),
      ),
    );
  }
}
