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
  bool _editMode = false;
  bool _editToday = false;

  static const _dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  bool get _isToday => _day == DateTime.now().weekday;

  void _selectDay(int day) {
    setState(() {
      _day = day;
      _editToday = false;
    });
  }

  Future<void> _editSlot(TimetableSlot slot) async {
    final repo = ref.read(timetableRepositoryProvider);
    final subjects = await ref.read(subjectsProvider.future);
    if (!mounted) return;
    final result = await showModalBottomSheet<_SlotResult>(
      context: context,
      isScrollControlled: true,
      builder: (_) =>
          _EditSlotSheet(initial: slot, subjects: subjects, allowDelete: true),
    );
    if (result == null) return;
    if (!mounted) return;
    if (result.delete) {
      final confirmed = await _confirm(
        context,
        'Delete this session?',
        'It will be removed from the schedule.',
      );
      if (confirmed) await repo.deleteSlot(slot.id);
    } else {
      await repo.updateSlot(
        id: slot.id,
        startMin: result.startMin,
        endMin: result.endMin,
        subjectId: result.subjectId,
        activityType: result.activityType,
        title: result.title,
        target: result.target,
      );
    }
    await syncNotifications(ref);
  }

  Future<void> _addSlot() async {
    final repo = ref.read(timetableRepositoryProvider);
    final subjects = await ref.read(subjectsProvider.future);
    if (!mounted) return;
    final result = await showModalBottomSheet<_SlotResult>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _EditSlotSheet(
        initial: null,
        subjects: subjects,
        allowDelete: false,
        defaultActivity: ActivityType.study,
      ),
    );
    if (result == null) return;
    if (_editToday) {
      await repo.addOneOff(
        date: DateTime.now(),
        startMin: result.startMin,
        endMin: result.endMin,
        subjectId: result.subjectId,
        activityType: result.activityType,
        title: result.title,
        target: result.target,
      );
    } else {
      await repo.addTemplateSlot(
        dayOfWeek: _day,
        startMin: result.startMin,
        endMin: result.endMin,
        subjectId: result.subjectId,
        activityType: result.activityType,
        title: result.title,
        target: result.target,
      );
    }
    await syncNotifications(ref);
  }

  Future<void> _editTodayOnly() async {
    if (!_isToday) return;
    await ref
        .read(timetableRepositoryProvider)
        .copyTemplateToDate(DateTime.now());
    if (mounted) setState(() => _editToday = true);
  }

  Future<void> _revertToday() async {
    final confirmed = await _confirm(
      context,
      'Revert today?',
      'Today returns to the weekly schedule.',
    );
    if (!confirmed) return;
    await ref
        .read(timetableRepositoryProvider)
        .clearDateOverrides(DateTime.now());
    if (mounted) setState(() => _editToday = false);
  }

  Future<void> _restoreDefault() async {
    final confirmed = await _confirm(
      context,
      'Restore default timetable?',
      'Your custom sessions will be replaced by the default NEET plan.',
    );
    if (!confirmed) return;
    await ref.read(databaseProvider).restoreDefaultTimetable();
    await syncNotifications(ref);
  }

  Future<bool> _confirm(BuildContext context, String title, String body) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Restore'),
          ),
        ],
      ),
    );
    return ok ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final template = ref.watch(templateByDayProvider);
    final today = ref.watch(daySlotsProvider(DateTime.now()));
    final isToday = _isToday;

    Widget? scopeError;
    if (_editToday) {
      scopeError = today.hasError ? Text('${today.error}') : null;
    } else {
      scopeError = template.hasError ? Text('${template.error}') : null;
    }

    final slots = _editToday
        ? (today.value ?? const <TimetableSlot>[])
        : (template.value?[_day] ?? const <TimetableSlot>[]);

    return Scaffold(
      body: SafeArea(
        child: template.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
          data: (_) => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Timetable',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: _editMode ? 'Done editing' : 'Edit timetable',
                    icon: Icon(_editMode ? Icons.check : Icons.edit_outlined),
                    onPressed: () => setState(() {
                      _editMode = !_editMode;
                      _editToday = false;
                    }),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) {
                      switch (value) {
                        case 'restore':
                          _restoreDefault();
                        case 'revertToday':
                          _revertToday();
                      }
                    },
                    itemBuilder: (context) => [
                      if (_editToday)
                        const PopupMenuItem(
                          value: 'revertToday',
                          child: Text('Revert today to weekly'),
                        )
                      else
                        const PopupMenuItem(
                          value: 'restore',
                          child: Text('Restore default timetable'),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'The timetable guides; it never forces.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 46,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: 7,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final day = i + 1;
                    final selected = _day == day;
                    final isToday = day == DateTime.now().weekday;
                    return _DayPill(
                      label: _dayNames[i],
                      selected: selected,
                      isToday: isToday,
                      onTap: () => _selectDay(day),
                    );
                  },
                ),
              ),
              if (_editMode) ...[
                const SizedBox(height: 12),
                Card(
                  margin: EdgeInsets.zero,
                  color: _editToday
                      ? theme.colorScheme.tertiaryContainer
                      : theme.colorScheme.secondaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Icon(
                          _editToday ? Icons.today : Icons.edit_calendar,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _editToday
                                ? 'Editing only today. The weekly schedule is untouched.'
                                : 'Editing the weekly schedule for ${_dayNames[_day - 1]}. Tap a session to change it.',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              if (_editMode && isToday && !_editToday) ...[
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: _editTodayOnly,
                  icon: const Icon(Icons.today_outlined),
                  label: const Text('Edit today only'),
                ),
              ],
              if (scopeError != null)
                Center(child: Text('$scopeError'))
              else ...[
                const SizedBox(height: 12),
                for (final s in slots)
                  _SlotTile(
                    slot: s,
                    editing: _editMode,
                    onTap: _editMode ? () => _editSlot(s) : null,
                  ),
                if (_editMode) ...[
                  const SizedBox(height: 4),
                  OutlinedButton.icon(
                    onPressed: _addSlot,
                    icon: const Icon(Icons.add),
                    label: Text(
                      _editToday ? 'Add a session today' : 'Add a session',
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DayPill extends StatelessWidget {
  const _DayPill({
    required this.label,
    required this.selected,
    required this.isToday,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool isToday;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final fg = selected ? scheme.onPrimary : scheme.onSurface;
    final bg = selected
        ? scheme.primary
        : isToday
        ? scheme.primaryContainer
        : scheme.surfaceContainerHigh;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: SizedBox(
          width: 48,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: fg,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: selected
                      ? scheme.onPrimary
                      : isToday
                      ? scheme.primary
                      : Colors.transparent,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SlotTile extends ConsumerWidget {
  const _SlotTile({required this.slot, this.editing = false, this.onTap});

  final TimetableSlot slot;
  final bool editing;
  final VoidCallback? onTap;

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
        trailing: editing
            ? const Icon(Icons.edit, size: 18)
            : slot.isOptional
            ? const Icon(Icons.lock_open, size: 16)
            : null,
        onTap: onTap,
      ),
    );
  }
}

class _SlotResult {
  const _SlotResult({
    required this.startMin,
    required this.endMin,
    required this.subjectId,
    required this.activityType,
    required this.title,
    this.target,
    this.delete = false,
  });

  final int startMin;
  final int endMin;
  final int? subjectId;
  final ActivityType activityType;
  final String title;
  final String? target;
  final bool delete;
}

class _EditSlotSheet extends StatefulWidget {
  const _EditSlotSheet({
    required this.initial,
    required this.subjects,
    required this.allowDelete,
    this.defaultActivity = ActivityType.study,
  });

  final TimetableSlot? initial;
  final List<Subject> subjects;
  final bool allowDelete;
  final ActivityType defaultActivity;

  @override
  State<_EditSlotSheet> createState() => _EditSlotSheetState();
}

class _EditSlotSheetState extends State<_EditSlotSheet> {
  late final TextEditingController _title;
  late final TextEditingController _target;
  late int _startMin;
  late int _endMin;
  late ActivityType _type;
  late int? _subjectId;

  static const _types = [
    ActivityType.study,
    ActivityType.recovery,
    ActivityType.wake,
    ActivityType.breakActivity,
    ActivityType.meal,
    ActivityType.college,
    ActivityType.reset,
    ActivityType.planning,
    ActivityType.free,
    ActivityType.sleep,
  ];

  @override
  void initState() {
    super.initState();
    final s = widget.initial;
    _title = TextEditingController(text: s?.title ?? '');
    _target = TextEditingController(text: s?.target ?? '');
    _startMin = s?.startMin ?? (3 * 60 + 30);
    _endMin = s?.endMin ?? (4 * 60 + 30);
    _type = s?.activityType ?? widget.defaultActivity;
    _subjectId = s?.subjectId;
  }

  @override
  void dispose() {
    _title.dispose();
    _target.dispose();
    super.dispose();
  }

  Future<void> _pickTime({required bool isEnd}) async {
    final initial = TimeOfDay(
      hour: (isEnd ? _endMin : _startMin) ~/ 60,
      minute: (isEnd ? _endMin : _startMin) % 60,
    );
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked == null) return;
    setState(() {
      final min = picked.hour * 60 + picked.minute;
      if (isEnd) {
        _endMin = min;
      } else {
        _startMin = min;
      }
      if (_endMin < _startMin) _endMin = _startMin + 30;
    });
  }

  bool get _studyLike =>
      _type == ActivityType.study || _type == ActivityType.recovery;

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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.initial == null ? 'Add session' : 'Edit session',
            style: theme.textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<ActivityType>(
            initialValue: _type,
            decoration: const InputDecoration(labelText: 'Activity'),
            items: [
              for (final t in _types)
                DropdownMenuItem(value: t, child: Text(t.label)),
            ],
            onChanged: (v) {
              if (v == null) return;
              setState(() {
                _type = v;
                if (!_studyLike) _subjectId = null;
              });
            },
          ),
          if (_studyLike) ...[
            const SizedBox(height: 12),
            DropdownButtonFormField<int?>(
              initialValue: _subjectId,
              decoration: const InputDecoration(labelText: 'Subject'),
              items: [
                for (final s in widget.subjects)
                  DropdownMenuItem(value: s.id, child: Text(s.name)),
              ],
              onChanged: (v) => setState(() => _subjectId = v),
            ),
          ],
          const SizedBox(height: 12),
          TextField(
            controller: _title,
            decoration: const InputDecoration(
              labelText: 'Title',
              hintText: 'e.g. Physics — New Concept',
            ),
          ),
          if (_studyLike) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _target,
              decoration: const InputDecoration(
                labelText: 'Target (optional)',
                hintText: 'e.g. Learn new concept',
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _pickTime(isEnd: false),
                  child: Text('Start ${timeOfDay(_startMin)}'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _pickTime(isEnd: true),
                  child: Text('End ${timeOfDay(_endMin)}'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              if (widget.allowDelete)
                IconButton(
                  tooltip: 'Delete',
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => Navigator.of(context).pop(
                    const _SlotResult(
                      startMin: 0,
                      endMin: 0,
                      subjectId: null,
                      activityType: ActivityType.study,
                      title: '',
                      delete: true,
                    ),
                  ),
                ),
              const Spacer(),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () {
                  if (_title.text.trim().isEmpty) return;
                  Navigator.of(context).pop(
                    _SlotResult(
                      startMin: _startMin,
                      endMin: _endMin,
                      subjectId: _subjectId,
                      activityType: _type,
                      title: _title.text.trim(),
                      target: _studyLike && _target.text.trim().isNotEmpty
                          ? _target.text.trim()
                          : null,
                    ),
                  );
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
