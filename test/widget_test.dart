import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:neet_journal/ui/widgets/countdown_card.dart';

void main() {
  testWidgets('CountdownCard shows remaining days', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: CountdownCard(daysLeft: 287))),
    );

    expect(find.text('287'), findsOneWidget);
    expect(find.text('DAYS LEFT'), findsOneWidget);
    expect(find.text('NEET 2027'), findsOneWidget);
  });

  testWidgets('CountdownCard never shows negative days', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: CountdownCard(daysLeft: -3))),
    );

    expect(find.text('0'), findsOneWidget);
  });
}
