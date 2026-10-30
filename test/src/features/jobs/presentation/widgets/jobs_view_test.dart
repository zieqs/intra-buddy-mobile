import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intra_buddy_mobile_v2/src/app/theme/app_theme.dart';
import 'package:intra_buddy_mobile_v2/src/app/ui/buddy_top_bar.dart';
import 'package:intra_buddy_mobile_v2/src/features/jobs/domain/entities/job_application.dart';
import 'package:intra_buddy_mobile_v2/src/features/jobs/presentation/widgets/jobs_view.dart';

List<JobApplication> _items() => [
  JobApplication(
    id: 1,
    companyName: 'Petronas',
    position: 'Process Engineer Intern',
    applicationDate: DateTime(2026, 10, 12),
    status: 'Interview',
  ),
  JobApplication(
    id: 2,
    companyName: 'Shell',
    position: 'HSE Intern',
    applicationDate: DateTime(2026, 10, 14),
    status: 'Pending',
  ),
  JobApplication(
    id: 3,
    companyName: 'Top Glove',
    position: 'Operations Intern',
    applicationDate: DateTime(2026, 10, 16),
    status: 'Offer',
  ),
  JobApplication(
    id: 4,
    companyName: 'Gamuda',
    position: 'Site Engineer Intern',
    applicationDate: DateTime(2026, 10, 18),
    status: 'Rejected',
  ),
];

Widget _harness({required Widget child}) => MaterialApp(
  theme: AppTheme.light,
  home: MediaQuery(
    data: const MediaQueryData(padding: EdgeInsets.only(top: 40)),
    child: child,
  ),
);

void main() {
  testWidgets('shows the pipeline and application rows', (tester) async {
    await tester.pumpWidget(
      _harness(
        child: JobsView(
          items: _items(),
          streak: 6,
          userName: 'Aisyah',
          bell: const SizedBox(),
          onProfile: () {},
          onAdd: () {},
          onEdit: (_) {},
          onDelete: (_) {},
          onRefresh: () async {},
        ),
      ),
    );

    expect(find.text('3 in play.'), findsOneWidget);
    expect(find.text('Petronas'), findsOneWidget);
    expect(find.text('Interview'), findsOneWidget);
    expect(find.text('APPLIED'), findsOneWidget);
  });

  testWidgets('starts below the status bar / camera cutout', (tester) async {
    await tester.pumpWidget(
      _harness(
        child: JobsView(
          items: _items(),
          streak: 6,
          userName: 'Aisyah',
          bell: const SizedBox(),
          onProfile: () {},
          onAdd: () {},
          onEdit: (_) {},
          onDelete: (_) {},
          onRefresh: () async {},
        ),
      ),
    );

    final topBar = tester.getRect(find.byType(BuddyTopBar));
    expect(topBar.top, greaterThanOrEqualTo(40));
  });

  testWidgets('adds from the primary action', (tester) async {
    var added = 0;
    await tester.pumpWidget(
      _harness(
        child: JobsView(
          items: _items(),
          streak: 6,
          userName: 'Aisyah',
          bell: const SizedBox(),
          onProfile: () {},
          onAdd: () => added++,
          onEdit: (_) {},
          onDelete: (_) {},
          onRefresh: () async {},
        ),
      ),
    );

    await tester.tap(find.text('Add application'));
    expect(added, 1);
  });
}
