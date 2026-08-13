import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/db/database.dart';
import '../core/utils/dates.dart';
import 'providers.dart';

class TodayData {
  const TodayData({
    required this.now,
    required this.slots,
    required this.completedSlotIds,
    required this.pending,
    required this.daysLeft,
    required this.examDate,
    required this.badDay,
  });

  final DateTime now;
  final List<TimetableSlot> slots;
  final Set<int> completedSlotIds;
  final List<PendingTask> pending;
  final int daysLeft;
  final DateTime examDate;

  /// "I'm having a bad day" — today's workload is reduced to minimums.
  final bool badDay;
}

final todayProvider = StreamProvider<TodayData>((ref) {
  final db = ref.watch(databaseProvider);
  final timetable = ref.watch(timetableRepositoryProvider);
  final sessions = ref.watch(sessionRepositoryProvider);
  final pending = ref.watch(pendingRepositoryProvider);
  final settings = ref.watch(settingsRepositoryProvider);

  final changes = dbTickStream(db);

  return changes.asyncMap((_) async {
    final now = DateTime.now();
    final slots = await timetable.slotsForDay(now);
    final done = await sessions.sessionsForDayBySlot(now);
    final openPending = await pending.openDueOnOrBefore(now);
    final exam = await settings.examDate();
    final badDay = await settings.badDay(now);
    return TodayData(
      now: now,
      slots: slots,
      completedSlotIds: done.keys.toSet(),
      pending: openPending,
      daysLeft: daysUntil(now, exam),
      examDate: exam,
      badDay: badDay,
    );
  });
});
