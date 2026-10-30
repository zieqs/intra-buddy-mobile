import 'package:flutter_test/flutter_test.dart';
import 'package:intra_buddy_mobile_v2/src/features/journey/domain/build_journey.dart';
import 'package:intra_buddy_mobile_v2/src/features/journey/domain/journey.dart';

import '../journey_fixtures.dart';

void main() {
  test('explicit phase wins', () {
    expect(
      phaseFor(
        journeyItem(phase: 'after'),
        DateTime(2026, 9, 27),
        DateTime(2027, 1, 31),
      ),
      JourneyChapterKind.after,
    );
    expect(
      phaseFor(
        journeyItem(phase: 'before', due: DateTime(2026, 11, 6)),
        DateTime(2026, 9, 27),
        DateTime(2027, 1, 31),
      ),
      JourneyChapterKind.before,
    );
  });

  test('infers before and after from the semester dates', () {
    expect(
      phaseFor(
        journeyItem(due: DateTime(2026, 9, 20)),
        DateTime(2026, 9, 27),
        DateTime(2027, 1, 31),
      ),
      JourneyChapterKind.before,
    );
    expect(
      phaseFor(
        journeyItem(due: DateTime(2027, 2, 2)),
        DateTime(2026, 9, 27),
        DateTime(2027, 1, 31),
      ),
      JourneyChapterKind.after,
    );
    expect(
      phaseFor(
        journeyItem(due: DateTime(2026, 11, 6)),
        DateTime(2026, 9, 27),
        DateTime(2027, 1, 31),
      ),
      JourneyChapterKind.during,
    );
  });

  test('no phase and no due date falls back to before', () {
    expect(phaseFor(journeyItem(), null, null), JourneyChapterKind.before);
  });
}
