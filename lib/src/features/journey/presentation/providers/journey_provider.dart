import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/auth_state_provider.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/providers/dashboard_refresh_provider.dart';
import '../../../checklist/presentation/providers/checklist_controller.dart';
import '../../../enrollment/domain/entities/enrollment.dart';
import '../../../enrollment/domain/repositories/enrollment_repository.dart';
import '../../../enrollment/presentation/providers/enrollment_provider.dart';
import '../../../logbook/presentation/logbook_reminder_sync.dart';
import '../../../logbook/presentation/providers/logbook_controller.dart';
import '../../domain/build_journey.dart';
import '../../domain/journey.dart';

class SemesterInfo {
  const SemesterInfo({this.name, this.start, this.end});

  final String? name;
  final DateTime? start;
  final DateTime? end;
}

final journeyProvider = FutureProvider<Journey>((ref) async {
  ref.watch(authUserIdProvider);
  ref.watch(dashboardRefreshProvider);

  final auth = ref.watch(authServiceProvider);
  final userId = auth.currentUser?.id;
  if (userId == null) return Journey.empty();

  final checklistRepo = ref.watch(checklistRepositoryProvider);
  final logbookRepo = ref.watch(logbookRepositoryProvider);
  final enrollmentRepo = ref.watch(enrollmentRepositoryProvider);

  final semester = await _loadSemester(enrollmentRepo, userId);
  final checklistResult = await checklistRepo.loadChecklist();
  final weeksResult = await logbookRepo.loadExistingWeeks();

  final checklist = checklistResult.fold((failure) => throw failure, (v) => v);
  final weeks = weeksResult.fold((failure) => throw failure, (v) => v);

  final journey = buildJourney(
    checklist: checklist,
    weeks: weeks,
    semesterStart: semester.start,
    semesterEnd: semester.end,
    semesterName: semester.name,
    now: DateTime.now(),
  );

  // Refresh the weekly reminders whenever the journey reloads, including after
  // a week is marked submitted.
  unawaited(
    syncLogbookReminders(
      journey,
      ref.read(logbookReminderSchedulerProvider),
    ).catchError((Object _) {
      // Reminders are best-effort; never fail the journey load.
    }),
  );

  return journey;
});

Future<SemesterInfo> _loadSemester(
  EnrollmentRepository repository,
  String userId,
) async {
  final result = await repository.currentFor(userId);
  return result.fold((failure) {
    AppLogger.warning(
      'Could not load semester info for the journey',
      error: failure,
    );
    return const SemesterInfo();
  }, _toSemesterInfo);
}

SemesterInfo _toSemesterInfo(Enrollment? enrollment) {
  if (enrollment == null) return const SemesterInfo();
  return SemesterInfo(
    name: enrollment.name,
    start: enrollment.startDate,
    end: enrollment.endDate,
  );
}
