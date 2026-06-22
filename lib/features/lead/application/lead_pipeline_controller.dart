import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/odoo_exception.dart';
import '../../auth/application/auth_session_service.dart';
import '../data/lead_repository.dart';
import '../domain/lead.dart';
import '../domain/lead_list_item.dart';

class PipelineColumn {
  const PipelineColumn({
    required this.stageId,
    required this.stageName,
    required this.items,
    required this.totalRevenue,
  });

  final int stageId;
  final String stageName;
  final List<LeadListItem> items;
  final double totalRevenue;
}

class LeadPipelineState {
  const LeadPipelineState({
    this.columns = const [],
    this.isLoading = false,
    this.error,
    this.recordType = LeadType.lead,
  });

  final List<PipelineColumn> columns;
  final bool isLoading;
  final String? error;
  final LeadType recordType;

  LeadPipelineState copyWith({
    List<PipelineColumn>? columns,
    bool? isLoading,
    String? error,
    LeadType? recordType,
    bool clearError = false,
  }) =>
      LeadPipelineState(
        columns: columns ?? this.columns,
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
        recordType: recordType ?? this.recordType,
      );
}

class LeadPipelineController extends Notifier<LeadPipelineState> {
  @override
  LeadPipelineState build() {
    Future.microtask(load);
    return const LeadPipelineState(isLoading: true);
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final repo = ref.read(leadRepositoryProvider);
      final stages = await repo.fetchPipelineStages();
      final items = await repo.fetchLeads(
        recordType: state.recordType,
        limit: 200,
      );

      final grouped = <int, List<LeadListItem>>{};
      for (final stage in stages) {
        grouped[stage.id] = [];
      }
      for (final item in items) {
        final stageId = item.lead.stageOdooId;
        if (stageId != null && grouped.containsKey(stageId)) {
          grouped[stageId]!.add(item);
        }
      }

      final columns = [
        for (final stage in stages)
          PipelineColumn(
            stageId: stage.id,
            stageName: stage.name,
            items: grouped[stage.id] ?? const [],
            totalRevenue: (grouped[stage.id] ?? const [])
                .fold<double>(
                  0,
                  (sum, item) => sum + (item.lead.expectedRevenue ?? 0),
                ),
          ),
      ];

      state = state.copyWith(columns: columns, isLoading: false);
    } on OdooException catch (e) {
      if (e.isSessionExpired) {
        await ref.read(authSessionServiceProvider).expire();
      }
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> moveLeadToStage(int leadId, int stageId) async {
    await ref.read(leadRepositoryProvider).changeStage(leadId, stageId);
    await load();
  }

  void setRecordType(LeadType type) {
    if (state.recordType == type) return;
    state = state.copyWith(recordType: type);
    load();
  }

  Future<void> refresh() => load();
}

final leadPipelineControllerProvider =
    NotifierProvider<LeadPipelineController, LeadPipelineState>(
  LeadPipelineController.new,
);
