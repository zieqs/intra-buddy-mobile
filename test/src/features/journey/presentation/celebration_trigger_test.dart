import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intra_buddy_mobile_v2/src/app/theme/app_theme.dart';
import 'package:intra_buddy_mobile_v2/src/features/journey/domain/journey.dart';
import 'package:intra_buddy_mobile_v2/src/features/journey/presentation/celebration_controller.dart';
import 'package:intra_buddy_mobile_v2/src/features/journey/presentation/celebration_feedback.dart';

const _node = JourneyNode(
  id: 'milestone-1',
  kind: JourneyNodeKind.milestone,
  title: 'Submit INTRA forms',
  chapter: JourneyChapterKind.before,
  state: JourneyNodeState.done,
  isCompleted: true,
);

const _journey = Journey(
  chapters: [
    JourneyChapter(kind: JourneyChapterKind.before, nodes: [_node]),
  ],
  totalNodes: 1,
  completedNodes: 1,
);

void main() {
  testWidgets('chimes as the milestone celebration appears', (tester) async {
    var plays = 0;
    var haptics = 0;
    final feedback = CelebrationFeedback(
      playSound: () async => plays++,
      haptic: () async => haptics++,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () {
                  celebrate(
                    context: context,
                    node: _node,
                    journey: _journey,
                    feedback: feedback,
                    soundEnabled: true,
                  );
                },
                child: const Text('Mark done'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Mark done'));
    await tester.pumpAndSettle();

    expect(plays, 1);
    expect(haptics, 1);
    expect(find.text('Milestone done!'), findsOneWidget);
  });

  testWidgets('does not chime when sounds are switched off', (tester) async {
    var plays = 0;
    var haptics = 0;
    final feedback = CelebrationFeedback(
      playSound: () async => plays++,
      haptic: () async => haptics++,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () {
                  celebrate(
                    context: context,
                    node: _node,
                    journey: _journey,
                    feedback: feedback,
                    soundEnabled: false,
                  );
                },
                child: const Text('Mark done'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Mark done'));
    await tester.pumpAndSettle();

    expect(plays, 0);
    expect(haptics, 1);
    expect(find.text('Milestone done!'), findsOneWidget);
  });
}
