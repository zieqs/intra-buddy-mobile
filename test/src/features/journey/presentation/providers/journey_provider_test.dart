import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intra_buddy_mobile_v2/src/core/errors/failures.dart';
import 'package:intra_buddy_mobile_v2/src/core/network/supabase_client_provider.dart';
import 'package:intra_buddy_mobile_v2/src/core/providers/auth_state_provider.dart';
import 'package:intra_buddy_mobile_v2/src/core/services/auth_service.dart';
import 'package:intra_buddy_mobile_v2/src/features/checklist/domain/entities/checklist_item.dart';
import 'package:intra_buddy_mobile_v2/src/features/checklist/domain/repositories/checklist_repository.dart';
import 'package:intra_buddy_mobile_v2/src/features/checklist/presentation/providers/checklist_controller.dart';
import 'package:intra_buddy_mobile_v2/src/features/journey/presentation/providers/journey_provider.dart';
import 'package:intra_buddy_mobile_v2/src/features/logbook/domain/entities/logbook_week.dart';
import 'package:intra_buddy_mobile_v2/src/features/logbook/domain/repositories/logbook_repository.dart';
import 'package:intra_buddy_mobile_v2/src/features/logbook/presentation/logbook_reminder_planner.dart';
import 'package:intra_buddy_mobile_v2/src/features/logbook/presentation/logbook_reminder_sync.dart';
import 'package:intra_buddy_mobile_v2/src/features/logbook/presentation/providers/logbook_controller.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _MockAuthService extends Mock implements AuthService {}

class _MockUser extends Mock implements User {}

class _MockSupabaseClient extends Mock implements SupabaseClient {}

class _FakeChecklistRepository implements ChecklistRepository {
  @override
  Future<Result<List<ChecklistItem>>> loadChecklist() async => const Right([]);

  @override
  Future<Result<ChecklistItem>> toggleItem(
    int checklistId,
    bool completed,
  ) async => throw UnimplementedError();
}

class _FakeLogbookRepository implements LogbookRepository {
  @override
  Future<Result<List<LogbookWeek>>> loadExistingWeeks() async => Right([
    LogbookWeek(
      id: 1,
      weekNumber: 1,
      weekEndDate: DateTime(2026, 11, 8),
      isSubmitted: false,
    ),
  ]);

  @override
  Future<Result<List<LogbookWeek>>> loadWeeks() async =>
      throw UnimplementedError();

  @override
  Future<Result<LogbookWeek>> toggleSubmitted(int id, bool submitted) async =>
      throw UnimplementedError();
}

class _FakeScheduler implements LogbookReminderScheduler {
  List<ReminderWeek>? weeks;

  @override
  Future<void> reschedule(List<ReminderWeek> weeks) async {
    this.weeks = weeks;
  }
}

class _UserAwareLogbookRepository implements LogbookRepository {
  _UserAwareLogbookRepository(this.auth);

  final AuthService auth;
  int calls = 0;

  @override
  Future<Result<List<LogbookWeek>>> loadExistingWeeks() async {
    calls++;
    final isB = auth.currentUser?.id == 'student-b';
    return Right([
      LogbookWeek(
        id: isB ? 2 : 1,
        weekNumber: isB ? 2 : 1,
        weekEndDate: DateTime(2026, 11, isB ? 15 : 8),
        isSubmitted: false,
      ),
    ]);
  }

  @override
  Future<Result<List<LogbookWeek>>> loadWeeks() async =>
      throw UnimplementedError();

  @override
  Future<Result<LogbookWeek>> toggleSubmitted(int id, bool submitted) async =>
      throw UnimplementedError();
}

void main() {
  test('loading the journey reschedules the weekly reminders', () async {
    final auth = _MockAuthService();
    final user = _MockUser();
    when(() => user.id).thenReturn('student-1');
    when(() => auth.currentUser).thenReturn(user);

    final supabase = _MockSupabaseClient();
    when(() => supabase.from(any())).thenThrow(Exception('offline'));

    final scheduler = _FakeScheduler();
    final container = ProviderContainer(
      overrides: [
        authServiceProvider.overrideWithValue(auth),
        supabaseClientProvider.overrideWithValue(supabase),
        checklistRepositoryProvider.overrideWithValue(
          _FakeChecklistRepository(),
        ),
        logbookRepositoryProvider.overrideWithValue(_FakeLogbookRepository()),
        logbookReminderSchedulerProvider.overrideWithValue(scheduler),
      ],
    );
    addTearDown(container.dispose);

    await container.read(journeyProvider.future);
    await Future<void>.delayed(Duration.zero);

    expect(scheduler.weeks, hasLength(1));
    expect(scheduler.weeks!.single.weekNumber, 1);
    expect(scheduler.weeks!.single.endDate, DateTime(2026, 11, 8));
    expect(scheduler.weeks!.single.isSubmitted, isFalse);
  });

  test('reloads the journey when the signed-in account changes', () async {
    final events = StreamController<AuthState>.broadcast();
    addTearDown(events.close);

    final auth = _MockAuthService();
    final userA = _MockUser();
    final userB = _MockUser();
    when(() => userA.id).thenReturn('student-a');
    when(() => userB.id).thenReturn('student-b');
    when(() => auth.currentUser).thenReturn(userA);
    when(() => auth.authStateChanges).thenAnswer((_) => events.stream);

    final repository = _UserAwareLogbookRepository(auth);
    final scheduler = _FakeScheduler();
    final container = ProviderContainer(
      overrides: [
        authServiceProvider.overrideWithValue(auth),
        authStateProvider.overrideWith((ref) => events.stream),
        supabaseClientProvider.overrideWithValue(_MockSupabaseClient()),
        checklistRepositoryProvider.overrideWithValue(
          _FakeChecklistRepository(),
        ),
        logbookRepositoryProvider.overrideWithValue(repository),
        logbookReminderSchedulerProvider.overrideWithValue(scheduler),
      ],
    );
    addTearDown(container.dispose);

    await container.read(journeyProvider.future);
    await Future<void>.delayed(Duration.zero);
    expect(repository.calls, 1);
    expect(scheduler.weeks!.single.weekNumber, 1);

    when(() => auth.currentUser).thenReturn(userB);
    expect(auth.currentUser?.id, 'student-b');
    container.listen(authStateProvider, (_, _) {});
    events.add(const AuthState(AuthChangeEvent.signedIn, null));
    await Future<void>.delayed(const Duration(milliseconds: 10));
    await container.pump();
    expect(
      container.read(authStateProvider).value?.event,
      AuthChangeEvent.signedIn,
    );
    expect(container.read(authUserIdProvider), 'student-b');
    await container.read(journeyProvider.future);
    await Future<void>.delayed(Duration.zero);

    expect(repository.calls, 2);
    expect(scheduler.weeks!.single.weekNumber, 2);
  });
}
