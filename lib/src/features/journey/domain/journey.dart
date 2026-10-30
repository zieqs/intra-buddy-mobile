enum JourneyNodeKind { week, milestone }

enum JourneyNodeState { done, current, open, missed, locked }

enum JourneyChapterKind { before, during, after }

class JourneyNode {
  const JourneyNode({
    required this.id,
    required this.kind,
    required this.title,
    required this.chapter,
    required this.state,
    this.dueDate,
    this.weekNumber,
    this.sourceId,
    this.isCompleted = false,
    this.submittedAt,
    this.displayOrder = 0,
  });

  final String id;
  final JourneyNodeKind kind;
  final String title;
  final JourneyChapterKind chapter;
  final JourneyNodeState state;
  final DateTime? dueDate;
  final int? weekNumber;
  final int? sourceId;
  final bool isCompleted;
  final DateTime? submittedAt;
  final int displayOrder;

  bool get isWeek => kind == JourneyNodeKind.week;

  bool get canComplete {
    if (isWeek) {
      return state == JourneyNodeState.current ||
          state == JourneyNodeState.missed;
    }
    return state == JourneyNodeState.open ||
        state == JourneyNodeState.missed;
  }
}

class JourneyChapter {
  const JourneyChapter({required this.kind, required this.nodes});

  final JourneyChapterKind kind;
  final List<JourneyNode> nodes;

  int get total => nodes.length;
  int get completed => nodes.where((node) => node.isCompleted).length;
  double get progress => total == 0 ? 0 : completed / total;

  String get title => switch (kind) {
    JourneyChapterKind.before => 'Getting ready',
    JourneyChapterKind.during => 'The internship',
    JourneyChapterKind.after => 'Wrapping up',
  };
}

class Journey {
  const Journey({
    this.chapters = const [],
    this.currentWeek,
    this.nextAction,
    this.streak = 0,
    this.totalNodes = 0,
    this.completedNodes = 0,
    this.semesterStart,
    this.semesterEnd,
    this.semesterName,
    this.anchorKind = JourneyChapterKind.before,
  });

  factory Journey.empty() => const Journey();

  final List<JourneyChapter> chapters;
  final JourneyNode? currentWeek;
  final JourneyNode? nextAction;
  final int streak;
  final int totalNodes;
  final int completedNodes;
  final DateTime? semesterStart;
  final DateTime? semesterEnd;
  final String? semesterName;
  final JourneyChapterKind anchorKind;

  bool get isEmpty => totalNodes == 0;
  double get progress => totalNodes == 0 ? 0 : completedNodes / totalNodes;

  JourneyChapter? chapterFor(JourneyChapterKind kind) {
    for (final chapter in chapters) {
      if (chapter.kind == kind) return chapter;
    }
    return null;
  }
}
