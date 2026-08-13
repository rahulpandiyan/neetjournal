import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../core/db/tables.dart';
import '../../state/focus_controller.dart';
import '../../state/providers.dart';
import 'focus_palette.dart';

/// Final wrap-up sheet shown when a focus session ends — naturally or early.
/// The default status pill reflects how the session actually ended, so an
/// early exit is never marked "Completed" by default.
class SessionCompleteSheet extends ConsumerStatefulWidget {
  const SessionCompleteSheet({super.key, required this.state});

  final FocusState state;

  @override
  ConsumerState<SessionCompleteSheet> createState() =>
      _SessionCompleteSheetState();
}

class _SessionCompleteSheetState extends ConsumerState<SessionCompleteSheet> {
  late final SessionStatus _status;
  final _learned = TextEditingController();
  final _pending = TextEditingController();
  final _questions = TextEditingController();
  bool _saving = false;

  bool get _earlyExit => widget.state.phase == FocusPhase.finished;

  @override
  void initState() {
    super.initState();
    _status = _earlyExit ? SessionStatus.partial : SessionStatus.completed;
  }

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
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _header(),
            const SizedBox(height: 20),
            Text(
              'How did it actually go?',
              style: const TextStyle(
                color: FocusPalette.textSoft,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 10),
            _statusSelector(),
            const SizedBox(height: 24),
            TextField(
              controller: _learned,
              minLines: 2,
              maxLines: 4,
              style: const TextStyle(color: FocusPalette.text),
              cursorColor: FocusPalette.leaf,
              decoration: _inputDecoration(
                'What did you learn?',
                'Write something...',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _pending,
              style: const TextStyle(color: FocusPalette.text),
              cursorColor: FocusPalette.leaf,
              decoration: _inputDecoration('Anything pending?', 'e.g. 10 PYQs'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _questions,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: FocusPalette.text),
              cursorColor: FocusPalette.leaf,
              decoration: _inputDecoration(
                'Questions solved',
                'Optional count',
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: FocusPalette.leaf,
                foregroundColor: FocusPalette.ink,
              ),
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: FocusPalette.ink,
                      ),
                    )
                  : const HugeIcon(
                      icon: HugeIcons.strokeRoundedCheckmarkCircle01,
                      size: 20,
                    ),
              label: Text(_saving ? 'SAVING...' : 'SAVE SESSION'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    final title = _earlyExit ? 'Session ended early' : 'Session complete';
    final message = _earlyExit
        ? 'You stopped before the timer ran out — that is okay. '
              'Be honest about how it went so your stats stay truthful.'
        : 'Nice stretch of focus. Wrap it up below.';
    final icon = _earlyExit ? FocusPalette.amber : FocusPalette.leaf;
    final iconData = _earlyExit
        ? HugeIcons.strokeRoundedFlag01
        : HugeIcons.strokeRoundedCheckmarkCircle01;

    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: _earlyExit
                ? const Color(0xFF3A3020)
                : FocusPalette.greenSoft,
            shape: BoxShape.circle,
          ),
          child: HugeIcon(icon: iconData, color: icon, size: 32),
        ),
        const SizedBox(height: 14),
        Text(
          title.toUpperCase(),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: FocusPalette.text,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: FocusPalette.textSoft,
            fontSize: 13.5,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _statusSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _statusRow(SessionStatus.completed, 'Completed'),
          const SizedBox(height: 4),
          _statusRow(SessionStatus.partial, 'Partially Completed'),
          const SizedBox(height: 4),
          _statusRow(SessionStatus.notCompleted, 'Not Completed'),
        ],
      ),
    );
  }

  Widget _statusRow(SessionStatus status, String label) {
    final selected = _status == status;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _status = status),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? FocusPalette.leaf : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            HugeIcon(
              icon: _statusIcon(status),
              size: 17,
              color: selected ? FocusPalette.ink : FocusPalette.textDim,
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: selected ? FocusPalette.ink : FocusPalette.textSoft,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<List<dynamic>> _statusIcon(SessionStatus status) {
    switch (status) {
      case SessionStatus.completed:
        return HugeIcons.strokeRoundedCheckmarkCircle01;
      case SessionStatus.partial:
        return HugeIcons.strokeRoundedProgress01;
      case SessionStatus.notCompleted:
        return HugeIcons.strokeRoundedCancelCircle;
    }
  }

  InputDecoration _inputDecoration(String label, String hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(color: FocusPalette.textDim),
      hintStyle: const TextStyle(color: FocusPalette.textDim),
      filled: true,
      fillColor: Colors.white10,
      alignLabelWithHint: label == 'What did you learn?',
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: FocusPalette.leaf, width: 1.5),
      ),
    );
  }
}
