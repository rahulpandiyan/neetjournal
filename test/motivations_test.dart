import 'package:flutter_test/flutter_test.dart';
import 'package:studyn/core/data/motivations.dart';

void main() {
  group('Motivations', () {
    test('has a non-empty curated list', () {
      expect(Motivations.all, isNotEmpty);
      for (final m in Motivations.all) {
        expect(m.text.trim(), isNotEmpty);
        expect(m.author.trim(), isNotEmpty);
      }
    });

    test('daily rotates with the calendar day', () {
      final day1 = DateTime(2026, 8, 15, 9);
      final day2 = day1.add(const Duration(days: 1));
      final day3 = day1.add(const Duration(days: 2));

      expect(Motivations.daily(day1), isNot(Motivations.daily(day2)));
      expect(Motivations.daily(day1), isNot(Motivations.daily(day3)));
      expect(Motivations.daily(day2), isNot(Motivations.daily(day3)));
    });

    test('daily is stable within the same day', () {
      final morning = DateTime(2026, 8, 15, 6);
      final evening = DateTime(2026, 8, 15, 22);
      expect(Motivations.daily(morning).text, Motivations.daily(evening).text);
    });

    test('nextForSession advances each call', () {
      final a = Motivations.nextForSession();
      final b = Motivations.nextForSession();
      expect(a.text, isNot(b.text));
    });
  });
}
