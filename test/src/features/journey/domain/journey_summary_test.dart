import 'package:flutter_test/flutter_test.dart';
import 'package:intra_buddy_mobile_v2/src/features/journey/domain/build_journey.dart';
import 'package:intra_buddy_mobile_v2/src/features/journey/domain/journey.dart';
import 'package:intra_buddy_mobile_v2/src/features/journey/domain/journey_copy.dart';
import 'package:intra_buddy_mobile_v2/src/features/logbook/domain/entities/logbook_week.dart';

import '../journey_fixtures.dart';

List<LogbookWeek> _weeks12({int submittedThrough = 0}) {
  return List.generate(12, (index) {
    final number = index + 1;
    final end = DateTime(2026, 9, 18).add(Duration(days: 7 * number));
    final submitted = number <= submittedThrough;
    return journeyWeek(
      number,
      end,
      submitted: submitted,
      submittedAt: submitted ? end : null,
    );
  });
}

void main() {
  test('prefers a due-soon milestone over the current week', () {
    final journey = buildJourney(
      checklist: [
        journeyItem(
          id: 9,
          title: 'Supervisor form',
          phase: 'during',
          due: DateTime(2026, 10, 29),
        ),
      ],
      weeks: _weeks12(submittedThrough: 6),
      semesterStart: DateTime(2026, 9, 18),
      semesterEnd: DateTime(2027, 1, 31),
      now: DateTime(2026, 10, 31),
    );

    expect(journey.nextAction!.title, 'Supervisor form');
  });

  test('falls back to the current week', () {
    final journey = buildJourney(
      checklist: const [],
      weeks: _weeks12(submittedThrough: 6),
      semesterStart: DateTime(2026, 9, 18),
      semesterEnd: DateTime(2027, 1, 31),
      now: DateTime(2026, 10, 31),
    );

    expect(journey.nextAction!.title, 'Week 7');
  });

  test('falls back to the first incomplete node', () {
    final journey = buildJourney(
      checklist: [
        journeyItem(id: 1, title: 'University forms', phase: 'before'),
      ],
      weeks: _weeks12(submittedThrough: 7),
      semesterStart: DateTime(2026, 9, 18),
      semesterEnd: DateTime(2027, 1, 31),
      now: DateTime(2026, 10, 31),
    );

    expect(journey.nextAction!.title, 'University forms');
  });

  test('streak counts on-time consecutive weeks', () {
    final weeks = _weeks12(submittedThrough: 3);
    expect(streakFor(weeks, DateTime(2026, 10, 10)), 3);
  });

  test('a missed week resets the streak', () {
    final weeks = [
      journeyWeek(1, DateTime(2026, 9, 25), submitted: true, submittedAt: DateTime(2026, 9, 25)),
      journeyWeek(2, DateTime(2026, 10, 2), submitted: true, submittedAt: DateTime(2026, 10, 2)),
      journeyWeek(3, DateTime(2026, 10, 9)),
    ];
    expect(streakFor(weeks, DateTime(2026, 10, 20)), 0);
  });

  test('a late submission breaks the streak', () {
    final weeks = [
      journeyWeek(1, DateTime(2026, 9, 25), submitted: true, submittedAt: DateTime(2026, 9, 25)),
      journeyWeek(2, DateTime(2026, 10, 2), submitted: true, submittedAt: DateTime(2026, 10, 5)),
    ];
    expect(streakFor(weeks, DateTime(2026, 10, 20)), 0);
  });

  test('the in-progress week does not break the streak', () {
    final weeks = [
      journeyWeek(1, DateTime(2026, 9, 25), submitted: true, submittedAt: DateTime(2026, 9, 25)),
      journeyWeek(2, DateTime(2026, 10, 2), submitted: true, submittedAt: DateTime(2026, 10, 2)),
      journeyWeek(3, DateTime(2026, 10, 9)),
    ];
    expect(streakFor(weeks, DateTime(2026, 10, 5)), 2);
  });

  test('legacy submitted with null submittedAt counts', () {
    final weeks = [
      journeyWeek(1, DateTime(2026, 9, 25), submitted: true),
    ];
    expect(streakFor(weeks, DateTime(2026, 10, 1)), 1);
  });

  test('headline and subline follow the anchor', () {
    final empty = buildJourney(
      checklist: const [],
      weeks: const [],
      semesterStart: null,
      semesterEnd: null,
      now: DateTime(2026, 10, 31),
    );
    expect(homeHeadline(empty), 'Your journey starts here.');
    expect(homeSubline(empty), contains('coordinator'));

    final before = buildJourney(
      checklist: [journeyItem(phase: 'before')],
      weeks: const [],
      semesterStart: DateTime(2026, 9, 18),
      semesterEnd: DateTime(2027, 1, 31),
      now: DateTime(2026, 9, 1),
    );
    expect(homeHeadline(before), "Let's get you ready.");
    expect(homeSubline(before), '1 milestone left');

    final during = buildJourney(
      checklist: const [],
      weeks: _weeks12(submittedThrough: 6),
      semesterStart: DateTime(2026, 9, 18),
      semesterEnd: DateTime(2027, 1, 31),
      now: DateTime(2026, 10, 31),
    );
    expect(homeHeadline(during), 'Halfway there!');
    expect(homeSubline(during), contains('5 weeks to go'));
    expect(during.streak, 6);

    final after = buildJourney(
      checklist: [journeyItem(phase: 'after', done: true)],
      weeks: const [],
      semesterStart: DateTime(2026, 9, 18),
      semesterEnd: DateTime(2027, 1, 31),
      now: DateTime(2027, 2, 10),
    );
    expect(homeHeadline(after), 'You did it.');
  });

  test('invites a first streak when none exists', () {
    final journey = buildJourney(
      checklist: const [],
      weeks: _weeks12(),
      semesterStart: DateTime(2026, 9, 18),
      semesterEnd: DateTime(2027, 1, 31),
      now: DateTime(2026, 10, 31),
    );
    expect(homeSubline(journey), contains('start a streak'));
  });

  test('points to Week 1 before the internship starts', () {
    final journey = buildJourney(
      checklist: const [],
      weeks: _weeks12(),
      semesterStart: DateTime(2026, 11, 1),
      semesterEnd: DateTime(2027, 2, 7),
      now: DateTime(2026, 10, 30),
    );

    expect(journey.anchorKind, JourneyChapterKind.before);
    expect(journey.currentWeek, isNull);
    expect(homeStreakText(journey), 'Streak starts with Week 1 Submission');
    expect(
      homeSubline(journey),
      endsWith('Streak starts with Week 1 Submission'),
    );
  });
}
