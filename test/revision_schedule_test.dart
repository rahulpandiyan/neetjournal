import 'package:flutter_test/flutter_test.dart';

import 'package:studyn/data/repositories/progress_repository.dart';

void main() {
  test('revision schedule follows the Day 1/3/7/14/30 cycle', () {
    expect(revisionSchedule.keys.toList(), [1, 3, 7, 14, 30]);
    expect(revisionSchedule[1], 'Quick Revision');
    expect(revisionSchedule[3], 'Questions + PYQs');
    expect(revisionSchedule[7], 'Weekly Revision');
    expect(revisionSchedule[14], 'Second Revision');
    expect(revisionSchedule[30], 'Monthly Revision');
  });
}
