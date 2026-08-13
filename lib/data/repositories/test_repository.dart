import 'package:drift/drift.dart';

import '../../core/db/database.dart';
import '../../core/db/tables.dart';
import '../../core/utils/dates.dart';

class TestRepository {
  TestRepository(this._db);

  final AppDatabase _db;

  /// Next test number, e.g. 3 → "NEET TEST #03".
  Future<int> nextTestNumber() async {
    final count = await (_db.select(_db.tests)).get().then((l) => l.length);
    return count + 1;
  }

  Future<int> addTest({
    required DateTime date,
    required int physicsScore,
    required int chemistryScore,
    required int biologyScore,
    String? notes,
  }) async {
    final total = physicsScore + chemistryScore + biologyScore;
    final number = (await nextTestNumber()).toString().padLeft(2, '0');
    return _db
        .into(_db.tests)
        .insert(
          TestsCompanion.insert(
            name: 'NEET TEST #$number',
            date: dateToStr(date),
            physicsScore: physicsScore,
            chemistryScore: chemistryScore,
            biologyScore: biologyScore,
            totalScore: total,
            notes: Value(notes),
          ),
        );
  }

  Stream<List<Test>> watchTests() {
    return (_db.select(
      _db.tests,
    )..orderBy([(t) => OrderingTerm.desc(t.date)])).watch();
  }

  Future<Test?> getTest(int id) async {
    return (_db.select(
      _db.tests,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<void> deleteTest(int id) async {
    await (_db.delete(
      _db.testMistakes,
    )..where((t) => t.testId.equals(id))).go();
    await (_db.delete(_db.tests)..where((t) => t.id.equals(id))).go();
  }

  Stream<List<TestMistake>> watchMistakes(int testId) {
    return (_db.select(_db.testMistakes)
          ..where((t) => t.testId.equals(testId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }

  Future<int> addMistake({
    required int testId,
    int? subjectId,
    required MistakeCategory category,
    required String description,
  }) {
    return _db
        .into(_db.testMistakes)
        .insert(
          TestMistakesCompanion.insert(
            testId: testId,
            subjectId: Value(subjectId),
            category: category,
            description: description,
            isRevisioned: const Value(false),
            createdAt: DateTime.now(),
          ),
        );
  }

  Future<void> deleteMistake(int id) async {
    await (_db.delete(_db.testMistakes)..where((t) => t.id.equals(id))).go();
  }

  /// Turns a recorded mistake into a revision pending task (source 'mistake').
  /// Safe to call more than once: the current DB state is checked first.
  Future<void> convertMistakeToRevision(TestMistake mistake) async {
    final fresh = await (_db.select(
      _db.testMistakes,
    )..where((t) => t.id.equals(mistake.id))).getSingleOrNull();
    if (fresh == null || fresh.isRevisioned) return;
    await (_db.update(_db.testMistakes)..where((t) => t.id.equals(mistake.id)))
        .write(TestMistakesCompanion(isRevisioned: const Value(true)));
    await _db
        .into(_db.pendingTasks)
        .insert(
          PendingTasksCompanion.insert(
            subjectId: Value(fresh.subjectId),
            description:
                'Revise — ${fresh.description} (${fresh.category.label})',
            dueDate: dateToStr(DateTime.now()),
            source: Value('mistake'),
            status: PendingStatus.pending,
            createdAt: DateTime.now(),
          ),
        );
  }
}
