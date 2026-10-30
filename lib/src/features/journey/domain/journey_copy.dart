import 'journey.dart';

String homeHeadline(Journey journey) {
  if (journey.isEmpty) return 'Your journey starts here.';

  switch (journey.anchorKind) {
    case JourneyChapterKind.before:
      return "Let's get you ready.";
    case JourneyChapterKind.after:
      return journey.progress >= 1 ? 'You did it.' : 'The final stretch.';
    case JourneyChapterKind.during:
      final weeks = journey
          .chapterFor(JourneyChapterKind.during)
          ?.nodes
          .where((node) => node.isWeek)
          .length ??
          0;
      if (weeks == 0 || journey.currentWeek == null) return 'The final stretch.';
      final ratio = journey.currentWeek!.weekNumber! / weeks;
      if (ratio < 0.34) return 'Early days.';
      if (ratio < 0.67) return 'Halfway there!';
      return 'The final stretch.';
  }
}

String homeSubline(Journey journey) {
  if (journey.isEmpty) {
    return 'Ask your coordinator to add the first milestone.';
  }

  if (journey.anchorKind == JourneyChapterKind.after) {
    final left = journey.totalNodes - journey.completedNodes;
    if (left == 0) return 'Every milestone done.';
    return '$left ${left == 1 ? 'milestone' : 'milestones'} left to wrap up.';
  }

  final weeks = journey
      .chapterFor(JourneyChapterKind.during)
      ?.nodes
      .where((node) => node.isWeek)
      .length ??
      0;
  final current = journey.currentWeek;
  if (weeks > 0 && current != null) {
    final left = weeks - current.weekNumber!;
    if (left <= 0) return 'Final week';
    return '$left weeks to go · keep the streak alive';
  }

  final left = journey.totalNodes - journey.completedNodes;
  return '$left ${left == 1 ? 'milestone' : 'milestones'} left';
}
