import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/mobile_ui/mobile_ui_schema.dart';
import '../../../core/network/odoo_exception.dart';
import '../../auth/application/auth_session_service.dart';
import '../data/lead_repository.dart';
import '../domain/lead.dart';
import '../domain/lead_list_item.dart';

class LeadListState {
  const LeadListState({
    this.items = const [],
    this.listLayout,
    this.isLoading = false,
    this.error,
    this.selectedStage,
    this.query = '',
  });

  final List<LeadListItem> items;
  final MobileUiLayoutSchema? listLayout;
  final bool isLoading;
  final String? error;
  final LeadStage? selectedStage;
  final String query;

  LeadListState copyWith({
    List<LeadListItem>? items,
    MobileUiLayoutSchema? listLayout,
    bool? isLoading,
    String? error,
    LeadStage? selectedStage,
    String? query,
    bool clearStage = false,
    bool clearError = false,
  }) =>
      LeadListState(
        items: items ?? this.items,
        listLayout: listLayout ?? this.listLayout,
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
        selectedStage:
            clearStage ? null : (selectedStage ?? this.selectedStage),
        query: query ?? this.query,
      );
}

class LeadListController extends Notifier<LeadListState> {
  @override
  LeadListState build() {
    Future.microtask(load);
    return const LeadListState(isLoading: true);
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final repo = ref.read(leadRepositoryProvider);
      final layout = await repo.loadListLayout();
      final items = await repo.fetchLeads(
        stage: state.selectedStage,
        query: state.query.isEmpty ? null : state.query,
      );
      state = state.copyWith(
        items: items,
        listLayout: layout.isConfigured ? layout : null,
        isLoading: false,
      );
    } on OdooException catch (e) {
      if (e.isSessionExpired) {
        await ref.read(authSessionServiceProvider).expire();
      }
      state = state.copyWith(
        isLoading: false,
        error: e.isSessionExpired
            ? 'Session expired. Please sign in again.'
            : e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void setStage(LeadStage? stage) {
    state = state.copyWith(selectedStage: stage, clearStage: stage == null);
    load();
  }

  void setQuery(String query) {
    state = state.copyWith(query: query);
    load();
  }

  Future<void> refresh() => load();
}

final leadListControllerProvider =
    NotifierProvider<LeadListController, LeadListState>(
  LeadListController.new,
);
