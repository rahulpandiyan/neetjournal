import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:neet_journal/ui/widgets/countdown_card.dart';
import 'package:neet_journal/ui/widgets/widgets.dart';

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

  testWidgets('HoldToConfirmButton does not fire on a short press', (
    tester,
  ) async {
    var confirmed = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: HoldToConfirmButton(
              label: 'HOLD',
              duration: const Duration(seconds: 1),
              onConfirmed: () => confirmed++,
            ),
          ),
        ),
      ),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.text('HOLD')),
    );
    await tester.pump(const Duration(milliseconds: 400));
    await gesture.up();
    await tester.pumpAndSettle();

    expect(confirmed, 0);
  });

  testWidgets('HoldToConfirmButton fires after holding the full duration', (
    tester,
  ) async {
    var confirmed = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: HoldToConfirmButton(
              label: 'HOLD',
              duration: const Duration(seconds: 1),
              onConfirmed: () => confirmed++,
            ),
          ),
        ),
      ),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.text('HOLD')),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(confirmed, 0);
    await tester.pump(const Duration(milliseconds: 700));
    expect(confirmed, 1);
    await gesture.up();
    await tester.pumpAndSettle();
  });
}
