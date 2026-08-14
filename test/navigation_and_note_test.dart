import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:studyn/ui/screens/settings/note_screen.dart';
import 'package:studyn/ui/widgets/widgets.dart';

void main() {
  testWidgets('pushed screens show a back button', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const NoteScreen())),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(find.text('A Note for You'), findsOneWidget);
    expect(find.byTooltip('Back'), findsOneWidget);

    await tester.tap(find.byTooltip('Back'));
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.text('open'), findsOneWidget);
  });

  testWidgets('root-level ScreenHeader has no back button', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ScreenHeader(title: 'Root', subtitle: 'no back'),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byTooltip('Back'), findsNothing);
  });

  testWidgets('NoteScreen renders the letter', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: NoteScreen()));
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(find.text('A Note for You'), findsOneWidget);
    expect(find.text('# For My Brother ❤️'), findsOneWidget);
    expect(find.text('Mom ❤️'), findsOneWidget);
    expect(find.text('Dad ❤️'), findsOneWidget);
    expect(find.text('— Rahul'), findsOneWidget);
    expect(find.text('Now go study.'), findsOneWidget);
  });
}
