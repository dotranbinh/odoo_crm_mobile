import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/odoo_exception.dart';
import '../../auth/application/auth_session_service.dart';
import '../../lead/data/lead_repository.dart';
import '../domain/lead_quotation_context.dart';
import '../domain/order.dart';
import '../domain/order_line.dart';
import '../domain/quotation_input.dart';
import '../data/order_repository.dart';
import 'order_list_controller.dart';

class CreateQuotationState {
  const CreateQuotationState({
    this.isLoading = false,
    this.isSaving = false,
    this.error,
    this.leadContext,
    this.partnerId,
    this.partnerName,
    this.origin,
    this.dateOrder,
    this.validityDate,
    this.clientOrderRef = '',
    this.note = '',
    this.userId,
    this.teamId,
    this.pricelistId,
    this.paymentTermId,
    this.lines = const [],
    this.paymentTerms = const [],
    this.pricelists = const [],
    this.salespersons = const [],
    this.teams = const [],
    this.needsPartner = false,
  });

  final bool isLoading;
  final bool isSaving;
  final String? error;
  final LeadQuotationContext? leadContext;
  final int? partnerId;
  final String? partnerName;
  final String? origin;
  final DateTime? dateOrder;
  final DateTime? validityDate;
  final String clientOrderRef;
  final String note;
  final int? userId;
  final int? teamId;
  final int? pricelistId;
  final int? paymentTermId;
  final List<OrderLine> lines;
  final List<({int id, String name})> paymentTerms;
  final List<({int id, String name})> pricelists;
  final List<({int id, String name})> salespersons;
  final List<({int id, String name})> teams;
  final bool needsPartner;

  double get linesTotal =>
      lines.fold(0, (sum, line) => sum + line.quantity * line.priceUnit);

  CreateQuotationState copyWith({
    bool? isLoading,
    bool? isSaving,
    String? error,
    LeadQuotationContext? leadContext,
    int? partnerId,
    String? partnerName,
    String? origin,
    DateTime? dateOrder,
    DateTime? validityDate,
    String? clientOrderRef,
    String? note,
    int? userId,
    int? teamId,
    int? pricelistId,
    int? paymentTermId,
    List<OrderLine>? lines,
    List<({int id, String name})>? paymentTerms,
    List<({int id, String name})>? pricelists,
    List<({int id, String name})>? salespersons,
    List<({int id, String name})>? teams,
    bool? needsPartner,
    bool clearError = false,
    bool clearPartner = false,
  }) =>
      CreateQuotationState(
        isLoading: isLoading ?? this.isLoading,
        isSaving: isSaving ?? this.isSaving,
        error: clearError ? null : (error ?? this.error),
        leadContext: leadContext ?? this.leadContext,
        partnerId: clearPartner ? null : (partnerId ?? this.partnerId),
        partnerName: clearPartner ? null : (partnerName ?? this.partnerName),
        origin: origin ?? this.origin,
        dateOrder: dateOrder ?? this.dateOrder,
        validityDate: validityDate ?? this.validityDate,
        clientOrderRef: clientOrderRef ?? this.clientOrderRef,
        note: note ?? this.note,
        userId: userId ?? this.userId,
        teamId: teamId ?? this.teamId,
        pricelistId: pricelistId ?? this.pricelistId,
        paymentTermId: paymentTermId ?? this.paymentTermId,
        lines: lines ?? this.lines,
        paymentTerms: paymentTerms ?? this.paymentTerms,
        pricelists: pricelists ?? this.pricelists,
        salespersons: salespersons ?? this.salespersons,
        teams: teams ?? this.teams,
        needsPartner: needsPartner ?? this.needsPartner,
      );
}

class CreateQuotationController extends Notifier<CreateQuotationState> {
  int? _leadId;

  @override
  CreateQuotationState build() => CreateQuotationState(
        dateOrder: DateTime.now(),
      );

  Future<void> load({int? leadId}) async {
    _leadId = leadId;
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final orderRepo = ref.read(orderRepositoryProvider);
      final leadRepo = ref.read(leadRepositoryProvider);

      final results = await Future.wait([
        orderRepo.fetchPaymentTerms(),
        orderRepo.fetchPricelists(),
        leadRepo.fetchSalespersons(),
        orderRepo.fetchSalesTeams(),
        if (leadId != null) leadRepo.fetchLeadForQuotation(leadId),
      ]);

      final paymentTerms = results[0] as List<({int id, String name})>;
      final pricelists = results[1] as List<({int id, String name})>;
      final salespersons = results[2] as List<({int id, String name})>;
      final teams = results[3] as List<({int id, String name})>;
      LeadQuotationContext? leadContext;
      if (leadId != null) {
        leadContext = results[4] as LeadQuotationContext;
      }

      state = state.copyWith(
        isLoading: false,
        paymentTerms: paymentTerms,
        pricelists: pricelists,
        salespersons: salespersons,
        teams: teams,
        leadContext: leadContext,
        partnerId: leadContext?.partnerId,
        partnerName: leadContext?.displayCustomer,
        origin: leadContext?.name,
        userId: leadContext?.userId,
        teamId: leadContext?.teamId,
        pricelistId: pricelists.isNotEmpty ? pricelists.first.id : null,
        needsPartner: leadContext != null && leadContext.partnerId == null,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void setPartner(int id, String name) {
    state = state.copyWith(
      partnerId: id,
      partnerName: name,
      needsPartner: false,
    );
  }

  void setValidityDate(DateTime? date) {
    state = state.copyWith(validityDate: date);
  }

  void setClientOrderRef(String value) {
    state = state.copyWith(clientOrderRef: value);
  }

  void setNote(String value) {
    state = state.copyWith(note: value);
  }

  void setUserId(int? id) {
    state = state.copyWith(userId: id);
  }

  void setTeamId(int? id) {
    state = state.copyWith(teamId: id);
  }

  void setPricelistId(int? id) {
    state = state.copyWith(pricelistId: id);
  }

  void setPaymentTermId(int? id) {
    state = state.copyWith(paymentTermId: id);
  }

  void setLines(List<OrderLine> lines) {
    state = state.copyWith(lines: lines);
  }

  Future<void> createPartnerFromLead() async {
    final lead = state.leadContext;
    if (lead == null) return;

    state = state.copyWith(isSaving: true, clearError: true);
    try {
      final partnerId =
          await ref.read(orderRepositoryProvider).createPartnerFromLead(lead);
      final updated = await ref
          .read(leadRepositoryProvider)
          .fetchLeadForQuotation(lead.leadId);
      state = state.copyWith(
        isSaving: false,
        partnerId: partnerId,
        partnerName: updated.displayCustomer,
        leadContext: updated,
        needsPartner: false,
      );
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
    }
  }

  Future<Order?> submit() async {
    if (state.partnerId == null && state.leadContext == null) {
      state = state.copyWith(error: 'Customer is required.');
      return null;
    }
    if (state.lines.isEmpty) {
      state = state.copyWith(error: 'At least one order line is required.');
      return null;
    }

    state = state.copyWith(isSaving: true, clearError: true);
    try {
      final lead = state.leadContext;
      final input = QuotationInput(
        partnerId: state.partnerId,
        opportunityId: lead?.leadId,
        origin: state.origin,
        dateOrder: state.dateOrder ?? DateTime.now(),
        validityDate: state.validityDate,
        clientOrderRef: state.clientOrderRef.trim(),
        note: state.note.trim(),
        userId: state.userId,
        teamId: state.teamId,
        pricelistId: state.pricelistId,
        paymentTermId: state.paymentTermId,
        companyId: lead?.companyId,
        sourceId: lead?.sourceId,
        mediumId: lead?.mediumId,
        campaignId: lead?.campaignId,
        tagIds: lead?.tagIds ?? const [],
        lines: state.lines,
      );

      final order = await ref.read(orderRepositoryProvider).createQuotation(
            input: input,
            leadId: _leadId,
          );

      await ref.read(orderListControllerProvider.notifier).refresh();
      state = state.copyWith(isSaving: false);
      return order;
    } on OdooException catch (e) {
      if (e.isSessionExpired) {
        await ref.read(authSessionServiceProvider).expire();
      }
      state = state.copyWith(
        isSaving: false,
        error: e.isSessionExpired
            ? 'Session expired. Please sign in again.'
            : e.message,
      );
      return null;
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
      return null;
    }
  }
}

final createQuotationControllerProvider =
    NotifierProvider<CreateQuotationController, CreateQuotationState>(
  CreateQuotationController.new,
);
