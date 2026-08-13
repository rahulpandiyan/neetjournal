import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neet_journal/state/focus_controller.dart';

void main() {
  late ProviderContainer container;
  late FocusController controller;

  setUp(() {
    container = ProviderContainer();
    controller = container.read(focusControllerProvider.notifier);
  });

  tearDown(() => container.dispose());

  FocusPhase phase() => container.read(focusControllerProvider).phase;
  FocusState st() => container.read(focusControllerProvider);

  test('startFocus enters focusing with configured durations', () {
    controller.startFocus(
      slotId: 1,
      subjectId: 2,
      subjectName: 'Physics',
      title: 'Current Electricity',
      focusMinutes: 50,
      breakMinutes: 10,
    );

    expect(phase(), FocusPhase.focusing);
    expect(st().subjectName, 'Physics');
    expect(st().focusDuration, const Duration(minutes: 50));
    expect(st().breakDuration, const Duration(minutes: 10));
    expect(st().slotId, 1);
  });

  test('finish transitions to sessionComplete', () {
    controller.startFocus(
      subjectName: 'Physics',
      title: 'x',
      focusMinutes: 50,
      breakMinutes: 10,
    );
    controller.finish();
    expect(phase(), FocusPhase.sessionComplete);
  });

  test('break flow: start -> skip -> breakComplete -> nextSession resets', () {
    controller.startFocus(
      subjectName: 'Physics',
      title: 'x',
      focusMinutes: 50,
      breakMinutes: 10,
    );
    controller.finish();
    controller.startBreak();
    expect(phase(), FocusPhase.breaking);
    controller.skipBreak();
    expect(phase(), FocusPhase.breakComplete);
    controller.nextSession();
    expect(phase(), FocusPhase.idle);
  });

  test('pause and resume preserve focus phase', () {
    controller.startFocus(
      subjectName: 'Chemistry',
      title: 'y',
      focusMinutes: 25,
      breakMinutes: 5,
    );
    controller.pause();
    expect(phase(), FocusPhase.paused);
    controller.resume();
    expect(phase(), FocusPhase.focusing);
  });

  test('I am tired: 10 min break goes straight to breaking', () {
    controller.startFocus(
      subjectName: 'Biology',
      title: 'z',
      focusMinutes: 50,
      breakMinutes: 10,
    );
    controller.tiredBreak(10);
    expect(phase(), FocusPhase.breaking);
    expect(st().breakDuration, const Duration(minutes: 10));
  });

  test('I am tired: end session finishes', () {
    controller.startFocus(
      subjectName: 'Biology',
      title: 'z',
      focusMinutes: 50,
      breakMinutes: 10,
    );
    controller.endTired();
    expect(phase(), FocusPhase.finished);
  });

  test('timer counts down toward the end time', () {
    controller.startFocus(
      subjectName: 'Physics',
      title: 'x',
      focusMinutes: 1,
      breakMinutes: 10,
    );
    final before = st().remaining();
    expect(before, greaterThan(const Duration(seconds: 58)));
    expect(st().endTime, isNotNull);
  });
}
