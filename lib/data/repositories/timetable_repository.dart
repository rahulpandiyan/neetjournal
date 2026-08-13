import 'package:drift/drift.dart';

import '../../core/db/database.dart';
import '../../core/db/tables.dart';
import '../../core/utils/dates.dart';

class TimetableRepository {
  TimetableRepository(this._db);

  final AppDatabase _db;

  Stream<List<TimetableSlot>> watchDay(DateTime day) {
    final dateStr = dateToStr(day);
    final dow = day.weekday;
    return (_db.select(_db.timetableSlots)..where(
          (t) =>
              (t.dayOfWeek.equals(dow) & t.isRecurring.equals(true)) |
              t.date.equals(dateStr),
        ))
        .watch()
        .map((rows) {
          final replaced = <int, TimetableSlot>{};
          final additions = <TimetableSlot>[];
          for (final o in rows.where((r) => r.date != null)) {
            final slot = o;
            if (slot.templateSlotId != null) {
              replaced[slot.templateSlotId!] = slot;
            } else {
              additions.add(slot);
            }
          }
          final template = rows.where((r) => r.date == null).toList();
          final merged = <TimetableSlot>[
            for (final s in template) replaced[s.id] ?? s,
            ...additions,
          ];
          merged.sort((a, b) {
            final byTime = a.startMin.compareTo(b.startMin);
            if (byTime != 0) return byTime;
            return a.endMin.compareTo(b.endMin);
          });
          return merged;
        });
  }

  Future<List<TimetableSlot>> slotsForDay(DateTime day) async {
    final dateStr = dateToStr(day);
    final dow = day.weekday;
    final rows =
        await (_db.select(_db.timetableSlots)..where(
              (t) =>
                  (t.dayOfWeek.equals(dow) & t.isRecurring.equals(true)) |
                  t.date.equals(dateStr),
            ))
            .get();
    final replaced = <int, TimetableSlot>{};
    final additions = <TimetableSlot>[];
    for (final o in rows.where((r) => r.date != null)) {
      if (o.templateSlotId != null) {
        replaced[o.templateSlotId!] = o;
      } else {
        additions.add(o);
      }
    }
    final template = rows.where((r) => r.date == null).toList();
    final merged = <TimetableSlot>[
      for (final s in template) replaced[s.id] ?? s,
      ...additions,
    ];
    merged.sort((a, b) {
      final byStart = a.startMin.compareTo(b.startMin);
      return byStart != 0 ? byStart : a.endMin.compareTo(b.endMin);
    });
    return merged;
  }

  /// Inserts a one-off slot (used by "Move Later", "Move to Tomorrow", etc.).
  Future<int> addOneOff({
    required DateTime date,
    required int startMin,
    required int endMin,
    int? subjectId,
    required ActivityType activityType,
    required String title,
    String? target,
    int? templateSlotId,
  }) {
    return _db
        .into(_db.timetableSlots)
        .insert(
          TimetableSlotsCompanion.insert(
            dayOfWeek: const Value(null),
            date: Value(dateToStr(date)),
            templateSlotId: Value(templateSlotId),
            startMin: startMin,
            endMin: endMin,
            subjectId: Value(subjectId),
            activityType: activityType,
            title: title,
            target: Value(target),
            isRecurring: false,
            isOptional: const Value(false),
          ),
        );
  }

  Future<void> deleteSlot(int id) {
    return (_db.delete(_db.timetableSlots)..where((t) => t.id.equals(id))).go();
  }

  /// Updates an existing slot (template or one-off) in place.
  Future<void> updateSlot({
    required int id,
    required int startMin,
    required int endMin,
    int? subjectId,
    required ActivityType activityType,
    required String title,
    String? target,
  }) {
    return (_db.update(
      _db.timetableSlots,
    )..where((t) => t.id.equals(id))).write(
      TimetableSlotsCompanion(
        startMin: Value(startMin),
        endMin: Value(endMin),
        subjectId: Value(subjectId),
        activityType: Value(activityType),
        title: Value(title),
        target: Value(target),
      ),
    );
  }

  /// Adds a recurring slot to the weekly template for [dayOfWeek].
  Future<int> addTemplateSlot({
    required int dayOfWeek,
    required int startMin,
    required int endMin,
    int? subjectId,
    required ActivityType activityType,
    required String title,
    String? target,
  }) {
    return _db
        .into(_db.timetableSlots)
        .insert(
          TimetableSlotsCompanion.insert(
            dayOfWeek: Value(dayOfWeek),
            date: const Value(null),
            templateSlotId: const Value(null),
            startMin: startMin,
            endMin: endMin,
            subjectId: Value(subjectId),
            activityType: activityType,
            title: title,
            target: Value(target),
            isRecurring: true,
            isOptional: const Value(false),
          ),
        );
  }

  /// Copies a day's weekly template into date-specific one-offs so today can
  /// be edited without touching the weekly schedule.
  Future<void> copyTemplateToDate(DateTime day) async {
    final dateStr = dateToStr(day);
    final existing = await (_db.select(
      _db.timetableSlots,
    )..where((t) => t.date.equals(dateStr))).get();
    final overridden = existing.map((r) => r.templateSlotId).toSet();
    final template = await templateForDay(day.weekday);
    await _db.batch((b) {
      for (final t in template) {
        if (overridden.contains(t.id)) continue;
        b.insert(
          _db.timetableSlots,
          TimetableSlotsCompanion.insert(
            dayOfWeek: const Value(null),
            date: Value(dateStr),
            templateSlotId: Value(t.id),
            startMin: t.startMin,
            endMin: t.endMin,
            subjectId: Value(t.subjectId),
            activityType: t.activityType,
            title: t.title,
            target: Value(t.target),
            isRecurring: false,
            isOptional: Value(t.isOptional),
          ),
        );
      }
    });
  }

  /// Removes all one-off overrides for [day], reverting to the weekly template.
  Future<void> clearDateOverrides(DateTime day) async {
    final dateStr = dateToStr(day);
    await (_db.delete(
      _db.timetableSlots,
    )..where((t) => t.date.equals(dateStr))).go();
  }

  Future<Map<int, Subject>> subjectsById() async {
    final rows = await _db.select(_db.subjects).get();
    return {for (final s in rows) s.id: s};
  }

  Future<List<Subject>> allSubjects() => _db.select(_db.subjects).get();

  /// The weekly template, grouped day by day (1=Monday..7=Sunday).
  Stream<List<TimetableSlot>> watchTemplate() {
    return (_db.select(_db.timetableSlots)
          ..where((t) => t.isRecurring.equals(true))
          ..orderBy([
            (t) => OrderingTerm.asc(t.dayOfWeek),
            (t) => OrderingTerm.asc(t.startMin),
          ]))
        .watch();
  }

  Future<List<TimetableSlot>> templateForDay(int dayOfWeek) async {
    return (_db.select(_db.timetableSlots)
          ..where(
            (t) => t.isRecurring.equals(true) & t.dayOfWeek.equals(dayOfWeek),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.startMin)]))
        .get();
  }
}
