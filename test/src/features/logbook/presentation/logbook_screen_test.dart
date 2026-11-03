import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intra_buddy_mobile_v2/src/app/theme/app_theme.dart';
import 'package:intra_buddy_mobile_v2/src/core/errors/failures.dart';
import 'package:intra_buddy_mobile_v2/src/core/providers/auth_state_provider.dart';
import 'package:intra_buddy_mobile_v2/src/core/services/auth_service.dart';
import 'package:intra_buddy_mobile_v2/src/features/journey/domain/journey.dart';
import 'package:intra_buddy_mobile_v2/src/features/journey/presentation/providers/journey_provider.dart';
import 'package:intra_buddy_mobile_v2/src/features/logbook/domain/entities/logbook_week.dart';
import 'package:intra_buddy_mobile_v2/src/features/logbook/domain/repositories/logbook_repository.dart';
import 'package:intra_buddy_mobile_v2/src/features/logbook/presentation/providers/logbook_controller.dart';
import 'package:intra_buddy_mobile_v2/src/features/logbook/presentation/screens/logbook_screen.dart';
import 'package:intra_buddy_mobile_v2/src/features/notifications/presentation/providers/notification_controller.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockAuthService extends Mock implements AuthService {}

class _FakeLogbookRepository implements LogbookRepository {
  _FakeLogbookRepository(this.weeks);

  final List<LogbookWeek> weeks;
  int? toggledId;
  bool? toggledValue;

  @override
  Future<Result<List<LogbookWeek>>> loadWeeks() async => Right(weeks);

  @override
  Future<Result<List<LogbookWeek>>> loadExistingWeeks() async => Right(weeks);

  @override
  Future<Result<LogbookWeek>> toggleSubmitted(int id, bool submitted) async {
    toggledId = id;
    toggledValue = submitted;
    return Right(
      LogbookWeek(
        id: id,
        weekNumber: 1,
        weekEndDate: weeks.first.weekEndDate,
        isSubmitted: submitted,
      ),
    );
  }
}

void main() {
  testWidgets('undoes a submitted week from the current-week card', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    final week = LogbookWeek(
      id: 1,
      weekNumber: 1,
      weekEndDate: DateTime(2099, 1, 11),
      isSubmitted: true,
      submittedAt: DateTime(2099, 1, 4),
    );
    final repository = _FakeLogbookRepository([week]);

    final auth = _MockAuthService();
    when(() => auth.currentUser).thenReturn(null);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authServiceProvider.overrideWithValue(auth),
          logbookRepositoryProvider.overrideWithValue(repository),
          unreadNotificationCountProvider.overrideWithValue(0),
          journeyProvider.overrideWith(
            (ref) async => Journey(
              semesterStart: DateTime(2000, 1, 1),
              totalNodes: 1,
            ),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const LogbookScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Undo submission'));
    await tester.pumpAndSettle();

    expect(find.text('Undo Week 1 submission?'), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: find.byType(BottomSheet),
        matching: find.text('Undo submission'),
      ),
    );
    await tester.pumpAndSettle();

    expect(repository.toggledId, 1);
    expect(repository.toggledValue, isFalse);
  });
}
