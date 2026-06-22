import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/mobile_ui/mobile_ui_schema.dart';
import '../../../core/network/odoo_exception.dart';
import '../../auth/application/auth_session_service.dart';
import '../data/lead_repository.dart';
import '../domain/lead.dart';
import '../domain/lead_list_item.dart';

enum LeadSortOption {
  createDateDesc('create_date desc'),
  createDateAsc('create_date asc'),
  nameAsc('name asc'),
  revenueDesc('expected_revenue desc'),
  priorityDesc('priority desc');

  const LeadSortOption(this.order);
  final String order;
}

class LeadListState {
  const LeadListState({
    this.items = const [],
    this.listLayout,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.selectedStage,
    this.selectedStageId,
    this.stageIdMap = const {},
    this.query = '',
    this.recordType = LeadType.lead,
    this.sort = LeadSortOption.createDateDesc,
    this.hasMore = true,
    this.offset = 0,
  });

  static const pageSize = 25;

  final List<LeadListItem> items;
  final MobileUiLayoutSchema? listLayout;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final LeadStage? selectedStage;
  final int? selectedStageId;
  final Map<LeadStage, int> stageIdMap;
  final String query;
  final LeadType recordType;
  final LeadSortOption sort;
  final bool hasMore;
  final int offset;

  LeadListState copyWith({
    List<LeadListItem>? items,
    MobileUiLayoutSchema? listLayout,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    LeadStage? selectedStage,
    int? selectedStageId,
    Map<LeadStage, int>? stageIdMap,
    String? query,
    LeadType? recordType,
    LeadSortOption? sort,
    bool? hasMore,
    int? offset,
    bool clearStage = false,
    bool clearError = false,
    bool clearStageId = false,
  }) =>
      LeadListState(
        items: items ?? this.items,
        listLayout: listLayout ?? this.listLayout,
        isLoading: isLoading ?? this.isLoading,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        error: clearError ? null : (error ?? this.error),
        selectedStage:
            clearStage ? null : (selectedStage ?? this.selectedStage),
        selectedStageId: clearStageId
            ? null
            : (selectedStageId ?? this.selectedStageId),
        stageIdMap: stageIdMap ?? this.stageIdMap,
        query: query ?? this.query,
        recordType: recordType ?? this.recordType,
        sort: sort ?? this.sort,
        hasMore: hasMore ?? this.hasMore,
        offset: offset ?? this.offset,
      );
}

class LeadListController extends Notifier<LeadListState> {
  Timer? _debounce;

  @override
  LeadListState build() {
    ref.onDispose(() => _debounce?.cancel());
    Future.microtask(load);
    return const LeadListState(isLoading: true);
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true, offset: 0);
    try {
      final repo = ref.read(leadRepositoryProvider);
      final layout = await repo.loadListLayout();
      final stageIdMap = await repo.buildStageIdMap();
      final stageId = state.selectedStage != null
          ? stageIdMap[state.selectedStage]
          : null;

      final items = await repo.fetchLeads(
        stageId: stageId,
        query: state.query.isEmpty ? null : state.query,
        recordType: state.recordType,
        offset: 0,
        limit: LeadListState.pageSize,
        order: state.sort.order,
      );

      state = state.copyWith(
        items: items,
        listLayout: layout.isConfigured ? layout : null,
        stageIdMap: stageIdMap,
        selectedStageId: stageId,
        isLoading: false,
        hasMore: items.length >= LeadListState.pageSize,
        offset: items.length,
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
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore || state.isLoading) return;

    state = state.copyWith(isLoadingMore: true);
    try {
      final repo = ref.read(leadRepositoryProvider);
      final stageId = state.selectedStage != null
          ? state.stageIdMap[state.selectedStage]
          : null;

      final more = await repo.fetchLeads(
        stageId: stageId,
        query: state.query.isEmpty ? null : state.query,
        recordType: state.recordType,
        offset: state.offset,
        limit: LeadListState.pageSize,
        order: state.sort.order,
      );

      state = state.copyWith(
        items: [...state.items, ...more],
        isLoadingMore: false,
        hasMore: more.length >= LeadListState.pageSize,
        offset: state.offset + more.length,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false, error: e.toString());
    }
  }

  void setStage(LeadStage? stage) {
    state = state.copyWith(
      selectedStage: stage,
      clearStage: stage == null,
      clearStageId: stage == null,
    );
    load();
  }

  void setQuery(String query) {
    state = state.copyWith(query: query);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), load);
  }

  void setRecordType(LeadType type) {
    if (state.recordType == type) return;
    state = state.copyWith(recordType: type);
    load();
  }

  void setSort(LeadSortOption sort) {
    if (state.sort == sort) return;
    state = state.copyWith(sort: sort);
    load();
  }

  Future<void> refresh() => load();
}

final leadListControllerProvider =
    NotifierProvider<LeadListController, LeadListState>(
  LeadListController.new,
);
