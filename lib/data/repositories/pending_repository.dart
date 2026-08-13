import 'package:drift/drift.dart';

import '../../core/db/database.dart';
import '../../core/db/tables.dart';
import '../../core/utils/dates.dart';

class PendingRepository {
  PendingRepository(this._db);

  final AppDatabase _db;

  /// Open (pending) tasks due on or before [day].
  Future<List<PendingTask>> openDueOnOrBefore(DateTime day) {
    return (_db.select(_db.pendingTasks)
          ..where(
            (t) =>
                t.status.equalsValue(PendingStatus.pending) &
                t.dueDate.isSmallerOrEqualValue(dateToStr(day)),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.dueDate)]))
        .get();
  }

  Stream<List<PendingTask>> watchOpenDueOnOrBefore(DateTime day) {
    return (_db.select(_db.pendingTasks)
          ..where(
            (t) =>
                t.status.equalsValue(PendingStatus.pending) &
                t.dueDate.isSmallerOrEqualValue(dateToStr(day)),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.dueDate)]))
        .watch();
  }

  Future<List<PendingTask>> allPending() {
    return (_db.select(_db.pendingTasks)
          ..where((t) => t.status.equalsValue(PendingStatus.pending))
          ..orderBy([(t) => OrderingTerm.asc(t.dueDate)]))
        .get();
  }

  Stream<List<PendingTask>> watchAllPending() {
    return (_db.select(_db.pendingTasks)
          ..where((t) => t.status.equalsValue(PendingStatus.pending))
          ..orderBy([(t) => OrderingTerm.asc(t.dueDate)]))
        .watch();
  }

  Future<int> add({
    int? subjectId,
    required String description,
    required DateTime dueDate,
    String source = 'manual',
  }) {
    return _db
        .into(_db.pendingTasks)
        .insert(
          PendingTasksCompanion.insert(
            subjectId: Value(subjectId),
            description: description,
            dueDate: dateToStr(dueDate),
            source: Value(source),
            status: PendingStatus.pending,
            createdAt: DateTime.now(),
          ),
        );
  }

  Future<void> setStatus(int id, PendingStatus status) async {
    await (_db.update(_db.pendingTasks)..where((t) => t.id.equals(id))).write(
      PendingTasksCompanion(
        status: Value(status),
        completedAt: status == PendingStatus.done
            ? Value(DateTime.now())
            : const Value(null),
      ),
    );
  }

  Future<void> moveTo(int id, DateTime newDate) async {
    await (_db.update(_db.pendingTasks)..where((t) => t.id.equals(id))).write(
      PendingTasksCompanion(dueDate: Value(dateToStr(newDate))),
    );
  }
}
