import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/tables.dart';
import '../../state/focus_controller.dart';
import '../../state/providers.dart';

class SessionCompleteSheet extends ConsumerStatefulWidget {
  const SessionCompleteSheet({super.key, required this.state});

  final FocusState state;

  @override
  ConsumerState<SessionCompleteSheet> createState() =>
      _SessionCompleteSheetState();
}

class _SessionCompleteSheetState extends ConsumerState<SessionCompleteSheet> {
  SessionStatus _status = SessionStatus.completed;
  final _learned = TextEditingController();
  final _pending = TextEditingController();
  final _questions = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _learned.dispose();
    _pending.dispose();
    _questions.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    _saving = true;
    setState(() {});
    final s = widget.state;
    final now = DateTime.now();
    final started = s.startedAt;
    final focusMinutes = started == null
        ? s.focusDuration.inMinutes
        : (now.difference(started).inMinutes).clamp(0, 24 * 60).toInt();
    final questions = int.tryParse(_questions.text.trim()) ?? 0;

    await ref
        .read(sessionRepositoryProvider)
        .record(
          slotId: s.slotId,
          subjectId: s.subjectId,
          activityType: ActivityType.study,
          title: s.title,
          startedAt: s.startedAt ?? now,
          endedAt: now,
          status: _status,
          learned: _learned.text.trim().isEmpty ? null : _learned.text.trim(),
          pendingNote: _pending.text.trim().isEmpty
              ? null
              : _pending.text.trim(),
          questionsSolved: questions,
          focusMinutes: focusMinutes,
        );

    final pendingText = _pending.text.trim();
    if (pendingText.isNotEmpty) {
      await ref
          .read(pendingRepositoryProvider)
          .add(
            subjectId: s.subjectId,
            description: pendingText,
            dueDate: now,
            source: 'session',
          );
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
            Text('Session Complete ✓', style: theme.textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              widget.state.title,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Did you complete your target?',
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _statusChip(SessionStatus.completed, 'Completed'),
                _statusChip(SessionStatus.partial, 'Partially Completed'),
                _statusChip(SessionStatus.notCompleted, 'Not Completed'),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _learned,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'What did you learn?',
                hintText: 'Write something...',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _pending,
              decoration: const InputDecoration(
                labelText: 'Anything pending?',
                hintText: 'e.g. 10 PYQs',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _questions,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Questions solved',
                hintText: 'Optional count',
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('SAVE'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusChip(SessionStatus status, String label) {
    final selected = _status == status;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => _status = status),
    );
  }
}
