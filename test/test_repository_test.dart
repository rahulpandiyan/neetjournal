import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:studyn/core/db/database.dart';
import 'package:studyn/core/db/tables.dart';
import 'package:studyn/data/repositories/test_repository.dart';

void main() {
  late AppDatabase db;
  late TestRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = TestRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('addTest computes total and auto-names sequentially', () async {
    final id1 = await repo.addTest(
      date: DateTime(2026, 8, 1),
      physicsScore: 110,
      chemistryScore: 132,
      biologyScore: 298,
    );
    final id2 = await repo.addTest(
      date: DateTime(2026, 8, 8),
      physicsScore: 100,
      chemistryScore: 120,
      biologyScore: 280,
    );

    final tests = (await db.select(db.tests).get())
      ..sort((a, b) => a.id.compareTo(b.id));
    expect(tests, hasLength(2));
    expect(tests[0].name, 'NEET TEST #01');
    expect(tests[0].totalScore, 540);
    expect(tests[1].name, 'NEET TEST #02');
    expect(tests[1].totalScore, 500);
    expect(id1, isNot(id2));
  });

  test(
    'convertMistakeToRevision creates a revision pending task once',
    () async {
      final testId = await repo.addTest(
        date: DateTime(2026, 8, 1),
        physicsScore: 100,
        chemistryScore: 100,
        biologyScore: 200,
      );
      await repo.addMistake(
        testId: testId,
        category: MistakeCategory.silly,
        description: 'Misread unit',
      );

      final mistake = (await repo.watchMistakes(testId).first).first;
      expect(mistake.isRevisioned, isFalse);

      await repo.convertMistakeToRevision(mistake);
      await repo.convertMistakeToRevision(mistake);

      final updated = (await repo.watchMistakes(testId).first).first;
      expect(updated.isRevisioned, isTrue);

      final pending = await (db.select(
        db.pendingTasks,
      )..where((t) => t.source.equals('mistake'))).get();
      expect(pending, hasLength(1));
      expect(pending.first.description, contains('Misread unit'));
      expect(pending.first.description, contains('Silly mistake'));
    },
  );

  test('deleteTest removes its mistakes', () async {
    final testId = await repo.addTest(
      date: DateTime(2026, 8, 1),
      physicsScore: 100,
      chemistryScore: 100,
      biologyScore: 200,
    );
    await repo.addMistake(
      testId: testId,
      category: MistakeCategory.guess,
      description: 'Guessed',
    );

    await repo.deleteTest(testId);

    expect((await db.select(db.tests).get()), isEmpty);
    expect((await db.select(db.testMistakes).get()), isEmpty);
  });
}
