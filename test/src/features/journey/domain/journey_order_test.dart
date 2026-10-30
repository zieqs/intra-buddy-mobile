import 'package:flutter_test/flutter_test.dart';
import 'package:intra_buddy_mobile_v2/src/features/journey/domain/build_journey.dart';
import 'package:intra_buddy_mobile_v2/src/features/journey/domain/journey.dart';

import '../journey_fixtures.dart';

void main() {
  test('orders before -> weeks -> during milestone -> after', () {
    final journey = buildJourney(
      checklist: [
        journeyItem(
          id: 1,
          title: 'Offer letter',
          phase: 'before',
          due: DateTime(2026, 9, 20),
        ),
        journeyItem(
          id: 2,
          title: 'Final report',
          phase: 'after',
          due: DateTime(2027, 1, 20),
        ),
        journeyItem(
          id: 3,
          title: 'Mid-term report',
          phase: 'during',
          due: DateTime(2026, 11, 6),
        ),
      ],
      weeks: [
        journeyWeek(1, DateTime(2026, 10, 4), submitted: true),
        journeyWeek(2, DateTime(2026, 10, 11)),
      ],
      semesterStart: DateTime(2026, 9, 27),
      semesterEnd: DateTime(2027, 1, 31),
      now: DateTime(2026, 10, 30),
    );

    expect(
      journey.chapterFor(JourneyChapterKind.before)!.nodes.map((n) => n.title),
      ['Offer letter'],
    );
    expect(
      journey.chapterFor(JourneyChapterKind.during)!.nodes.map((n) => n.title),
      ['Week 1', 'Week 2', 'Mid-term report'],
    );
    expect(
      journey.chapterFor(JourneyChapterKind.after)!.nodes.map((n) => n.title),
      ['Final report'],
    );
  });

  test('drops empty chapters', () {
    final journey = buildJourney(
      checklist: const [],
      weeks: const [],
      semesterStart: null,
      semesterEnd: null,
      now: DateTime(2026, 10, 30),
    );

    expect(journey.chapters, isEmpty);
    expect(journey.isEmpty, isTrue);
  });

  test('marks submitted, missed, current and future weeks', () {
    final journey = buildJourney(
      checklist: const [],
      weeks: [
        journeyWeek(1, DateTime(2026, 10, 4), submitted: true),
        journeyWeek(2, DateTime(2026, 10, 11)),
        journeyWeek(3, DateTime(2026, 11, 6)),
        journeyWeek(4, DateTime(2026, 11, 13)),
      ],
      semesterStart: DateTime(2026, 9, 27),
      semesterEnd: DateTime(2027, 1, 31),
      now: DateTime(2026, 10, 30),
    );

    final states = journey
        .chapterFor(JourneyChapterKind.during)!
        .nodes
        .map((n) => n.state)
        .toList();
    expect(states, [
      JourneyNodeState.done,
      JourneyNodeState.missed,
      JourneyNodeState.current,
      JourneyNodeState.open,
    ]);
  });

  test('before placement anchors to getting ready; after anchors to wrapping up', () {
    final before = buildJourney(
      checklist: [journeyItem(phase: 'before')],
      weeks: const [],
      semesterStart: DateTime(2026, 9, 27),
      semesterEnd: DateTime(2027, 1, 31),
      now: DateTime(2026, 9, 1),
    );
    expect(before.anchorKind, JourneyChapterKind.before);

    final after = buildJourney(
      checklist: [journeyItem(phase: 'after')],
      weeks: const [],
      semesterStart: DateTime(2026, 9, 27),
      semesterEnd: DateTime(2027, 1, 31),
      now: DateTime(2027, 2, 10),
    );
    expect(after.anchorKind, JourneyChapterKind.after);
  });

  test('no current week before placement starts', () {
    final journey = buildJourney(
      checklist: const [],
      weeks: [journeyWeek(1, DateTime(2026, 10, 4))],
      semesterStart: DateTime(2026, 10, 1),
      semesterEnd: DateTime(2027, 1, 31),
      now: DateTime(2026, 9, 1),
    );
    expect(journey.currentWeek, isNull);
    expect(journey.anchorKind, JourneyChapterKind.before);
  });

  test('anchors to wrapping up when the last week has ended', () {
    final journey = buildJourney(
      checklist: const [],
      weeks: [
        journeyWeek(1, DateTime(2026, 9, 25)),
        journeyWeek(2, DateTime(2026, 10, 2)),
      ],
      semesterStart: DateTime(2026, 9, 1),
      semesterEnd: DateTime(2027, 1, 31),
      now: DateTime(2026, 10, 10),
    );
    expect(journey.currentWeek, isNull);
    expect(journey.anchorKind, JourneyChapterKind.after);
  });

  test('no weeks anchors to getting ready mid-semester', () {
    final journey = buildJourney(
      checklist: [journeyItem(phase: 'before')],
      weeks: const [],
      semesterStart: DateTime(2026, 9, 1),
      semesterEnd: DateTime(2027, 1, 31),
      now: DateTime(2026, 10, 10),
    );
    expect(journey.anchorKind, JourneyChapterKind.before);
  });

  test('only eligible nodes are completable', () {
    expect(journeyNode(state: JourneyNodeState.current).canComplete, isTrue);
    expect(journeyNode(state: JourneyNodeState.missed).canComplete, isTrue);
    expect(journeyNode(state: JourneyNodeState.open).canComplete, isFalse);
    expect(journeyNode(state: JourneyNodeState.done).canComplete, isFalse);
    expect(
      journeyNode(
        kind: JourneyNodeKind.milestone,
        weekNumber: null,
        state: JourneyNodeState.open,
      ).canComplete,
      isTrue,
    );
    expect(
      journeyNode(
        kind: JourneyNodeKind.milestone,
        weekNumber: null,
        state: JourneyNodeState.locked,
      ).canComplete,
      isFalse,
    );
  });
}
