import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/odoo_exception.dart';
import '../../auth/application/auth_session_service.dart';
import '../data/lead_activity_repository.dart';
import '../domain/scheduled_activity.dart';

class LeadScheduledActivitiesState {
  const LeadScheduledActivitiesState({
    this.activities = const [],
    this.isLoading = false,
    this.error,
  });

  final List<ScheduledActivity> activities;
  final bool isLoading;
  final String? error;

  LeadScheduledActivitiesState copyWith({
    List<ScheduledActivity>? activities,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) =>
      LeadScheduledActivitiesState(
        activities: activities ?? this.activities,
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
      );
}

class LeadScheduledActivitiesController
    extends FamilyNotifier<LeadScheduledActivitiesState, int> {
  @override
  LeadScheduledActivitiesState build(int arg) {
    Future.microtask(() => load(arg));
    return const LeadScheduledActivitiesState(isLoading: true);
  }

  Future<void> load(int leadId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final activities =
          await ref.read(leadActivityRepositoryProvider).fetchActivities(leadId);
      state = state.copyWith(activities: activities, isLoading: false);
    } on OdooException catch (e) {
      if (e.isSessionExpired) {
        await ref.read(authSessionServiceProvider).expire();
      }
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() => load(arg);

  Future<bool> schedule({
    required int activityTypeId,
    required String summary,
    required DateTime dateDeadline,
    int? userId,
  }) async {
    try {
      await ref.read(leadActivityRepositoryProvider).scheduleActivity(
            leadId: arg,
            activityTypeId: activityTypeId,
            summary: summary,
            dateDeadline: dateDeadline,
            userId: userId,
          );
      await load(arg);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> markDone(int activityId, {String? feedback}) async {
    try {
      await ref.read(leadActivityRepositoryProvider).markActivityDone(
            activityId: activityId,
            feedback: feedback,
          );
      await load(arg);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }
}

final leadScheduledActivitiesControllerProvider = NotifierProviderFamily<
    LeadScheduledActivitiesController,
    LeadScheduledActivitiesState,
    int>(LeadScheduledActivitiesController.new);
