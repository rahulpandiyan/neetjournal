import '../../core/db/tables.dart';

class SlotSpec {
  const SlotSpec({
    required this.startMin,
    required this.endMin,
    required this.type,
    this.subjectId,
    required this.title,
    this.target,
    this.isOptional = false,
  });

  final int startMin;
  final int endMin;
  final ActivityType type;
  final int? subjectId;
  final String title;
  final String? target;
  final bool isOptional;
}

/// Subject-rotation content injected into the five daily study slots.
typedef Rotation = ({int subjectId, String title, String target});

const _morningSlots = <int>[
  3 * 60 + 15,
  4 * 60 + 15,
  5 * 60 + 30,
  21 * 60,
  21 * 60 + 30,
];
const _morningDurations = <int>[60, 60, 60, 30, 30];

/// Rotation per weekday (index 0 = Monday). Values reference Physics/Chemistry/Biology.
List<List<Rotation>> _rotation(int p, int c, int b) => [
  // Monday
  [
    (subjectId: p, title: 'Physics — New Concept', target: 'Learn new concept'),
    (
      subjectId: c,
      title: 'Chemistry — New Concept',
      target: 'Learn new concept',
    ),
    (subjectId: b, title: 'Biology — NCERT', target: 'Read NCERT'),
    (subjectId: p, title: 'Physics — MCQs / PYQs', target: 'Solve MCQs & PYQs'),
    (
      subjectId: b,
      title: 'Biology — NCERT Recall',
      target: 'Recall from NCERT',
    ),
  ],
  // Tuesday
  [
    (subjectId: p, title: 'Physics — New Concept', target: 'Learn new concept'),
    (subjectId: c, title: 'Chemistry — Questions', target: 'Solve questions'),
    (subjectId: b, title: 'Biology — NCERT + MCQs', target: 'NCERT + MCQs'),
    (subjectId: c, title: 'Chemistry — PYQs', target: 'Solve PYQs'),
    (
      subjectId: b,
      title: 'Biology — Revision',
      target: 'Revise previous topics',
    ),
  ],
  // Wednesday
  [
    (
      subjectId: c,
      title: 'Chemistry — New Concept',
      target: 'Learn new concept',
    ),
    (subjectId: p, title: 'Physics — Questions', target: 'Solve questions'),
    (subjectId: b, title: 'Biology — NCERT', target: 'Read NCERT'),
    (subjectId: p, title: 'Physics — PYQs', target: 'Solve PYQs'),
    (
      subjectId: c,
      title: 'Chemistry — Formula / Reactions',
      target: 'Revise formulas & reactions',
    ),
  ],
  // Thursday
  [
    (subjectId: p, title: 'Physics — New Concept', target: 'Learn new concept'),
    (
      subjectId: c,
      title: 'Chemistry — New Concept',
      target: 'Learn new concept',
    ),
    (subjectId: b, title: 'Biology — NCERT + MCQs', target: 'NCERT + MCQs'),
    (
      subjectId: b,
      title: 'Biology — NCERT Recall',
      target: 'Recall from NCERT',
    ),
    (subjectId: p, title: 'Physics — Error Log', target: 'Update error log'),
  ],
  // Friday
  [
    (
      subjectId: c,
      title: 'Chemistry — New Concept',
      target: 'Learn new concept',
    ),
    (subjectId: p, title: 'Physics — Questions', target: 'Solve questions'),
    (subjectId: b, title: 'Biology — NCERT', target: 'Read NCERT'),
    (subjectId: c, title: 'Chemistry — PYQs', target: 'Solve PYQs'),
    (subjectId: b, title: 'Biology — MCQs', target: 'Solve MCQs'),
  ],
  // Saturday
  [
    (
      subjectId: p,
      title: 'Physics — Weekly Revision',
      target: 'Weekly revision',
    ),
    (
      subjectId: c,
      title: 'Chemistry — Weekly Revision',
      target: 'Weekly revision',
    ),
    (
      subjectId: b,
      title: 'Biology — Weekly NCERT',
      target: 'Weekly NCERT recap',
    ),
    (subjectId: p, title: 'Physics — Weekly PYQs', target: 'Weekly PYQs'),
    (subjectId: b, title: 'Weakest Area', target: 'Work on weakest area'),
  ],
];

/// Monday–Saturday weekly template.
List<SlotSpec> buildWeekdaySlots({
  required int physicsId,
  required int chemistryId,
  required int biologyId,
}) {
  final rotation = _rotation(physicsId, chemistryId, biologyId);

  final slots = <SlotSpec>[];
  for (var day = 0; day < 6; day++) {
    // Non-study skeleton (same shape every weekday).
    final wake = SlotSpec(
      startMin: 3 * 60,
      endMin: 3 * 60 + 15,
      type: ActivityType.wake,
      title: 'Wake up',
    );
    slots.add(wake);

    // Study blocks from the rotation.
    final rot = rotation[day];
    for (var i = 0; i < rot.length; i++) {
      slots.add(
        SlotSpec(
          startMin: _morningSlots[i],
          endMin: _morningSlots[i] + _morningDurations[i],
          type: ActivityType.study,
          subjectId: rot[i].subjectId,
          title: rot[i].title,
          target: rot[i].target,
        ),
      );
      // Insert the 5:15–5:30 break after the third study block.
      if (i == 2) {
        slots.add(
          SlotSpec(
            startMin: 5 * 60 + 15,
            endMin: 5 * 60 + 30,
            type: ActivityType.breakActivity,
            title: 'Break',
          ),
        );
      }
    }

    slots.addAll([
      SlotSpec(
        startMin: 6 * 60 + 30,
        endMin: 7 * 60 + 15,
        type: ActivityType.meal,
        title: 'Breakfast + Get Ready',
      ),
      SlotSpec(
        startMin: 7 * 60 + 30,
        endMin: 7 * 60 + 30,
        type: ActivityType.college,
        title: 'Leave for College',
      ),
      SlotSpec(
        startMin: 7 * 60 + 30,
        endMin: 20 * 60,
        type: ActivityType.college,
        title: 'College + Travel',
      ),
      SlotSpec(
        startMin: 20 * 60,
        endMin: 20 * 60 + 45,
        type: ActivityType.meal,
        title: 'Dinner + Freshen Up',
      ),
      SlotSpec(
        startMin: 20 * 60 + 45,
        endMin: 21 * 60,
        type: ActivityType.reset,
        title: 'Reset',
      ),
      SlotSpec(
        startMin: 22 * 60,
        endMin: 22 * 60,
        type: ActivityType.sleep,
        title: 'Sleep',
      ),
    ]);
  }
  return slots;
}

/// Sunday recovery template — everything study-like is optional.
List<SlotSpec> buildSundaySlots({
  required int physicsId,
  required int chemistryId,
  required int biologyId,
}) {
  return [
    SlotSpec(
      startMin: 4 * 60 + 30,
      endMin: 4 * 60 + 45,
      type: ActivityType.wake,
      title: 'Wake Up',
    ),
    SlotSpec(
      startMin: 4 * 60 + 45,
      endMin: 5 * 60 + 30,
      type: ActivityType.recovery,
      subjectId: biologyId,
      title: 'Light Biology / NCERT Revision',
      target: 'Optional light revision',
      isOptional: true,
    ),
    SlotSpec(
      startMin: 5 * 60 + 30,
      endMin: 6 * 60,
      type: ActivityType.breakActivity,
      title: 'Break',
    ),
    SlotSpec(
      startMin: 6 * 60,
      endMin: 6 * 60 + 45,
      type: ActivityType.recovery,
      subjectId: physicsId,
      title: 'Light Physics / Chemistry Revision',
      target: 'Optional light revision',
      isOptional: true,
    ),
    SlotSpec(
      startMin: 7 * 60 + 30,
      endMin: 10 * 60,
      type: ActivityType.meal,
      title: 'Breakfast + Rest',
      isOptional: true,
    ),
    SlotSpec(
      startMin: 10 * 60,
      endMin: 17 * 60,
      type: ActivityType.free,
      title: 'Free / Recovery',
      isOptional: true,
    ),
    SlotSpec(
      startMin: 18 * 60,
      endMin: 18 * 60 + 45,
      type: ActivityType.recovery,
      title: 'Optional Weak Topic Revision',
      target: '30–45 min, only if you feel like it',
      isOptional: true,
    ),
    SlotSpec(
      startMin: 21 * 60,
      endMin: 22 * 60,
      type: ActivityType.planning,
      title: 'Weekly Journal + Next Week Planning',
      isOptional: false,
    ),
    SlotSpec(
      startMin: 22 * 60,
      endMin: 22 * 60,
      type: ActivityType.sleep,
      title: 'Sleep',
    ),
  ];
}
