import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/odoo_exception.dart';
import '../../auth/application/auth_session_service.dart';
import '../../lead/data/lead_repository.dart';
import '../data/order_repository.dart';
import '../domain/order.dart';
import '../domain/order_line.dart';
import '../domain/order_update_input.dart';
import 'order_detail_controller.dart';
import 'order_list_controller.dart';

class EditOrderState {
  const EditOrderState({
    this.isLoading = false,
    this.isSaving = false,
    this.error,
    this.order,
    this.partnerId,
    this.partnerName,
    this.dateOrder,
    this.validityDate,
    this.clientOrderRef = '',
    this.note = '',
    this.userId,
    this.teamId,
    this.pricelistId,
    this.paymentTermId,
    this.lines = const [],
    this.removedLineIds = const [],
    this.paymentTerms = const [],
    this.pricelists = const [],
    this.salespersons = const [],
    this.teams = const [],
  });

  final bool isLoading;
  final bool isSaving;
  final String? error;
  final Order? order;
  final int? partnerId;
  final String? partnerName;
  final DateTime? dateOrder;
  final DateTime? validityDate;
  final String clientOrderRef;
  final String note;
  final int? userId;
  final int? teamId;
  final int? pricelistId;
  final int? paymentTermId;
  final List<OrderLine> lines;
  final List<int> removedLineIds;
  final List<({int id, String name})> paymentTerms;
  final List<({int id, String name})> pricelists;
  final List<({int id, String name})> salespersons;
  final List<({int id, String name})> teams;

  double get linesTotal =>
      lines.fold(0, (sum, line) => sum + line.quantity * line.priceUnit);

  EditOrderState copyWith({
    bool? isLoading,
    bool? isSaving,
    String? error,
    Order? order,
    int? partnerId,
    String? partnerName,
    DateTime? dateOrder,
    DateTime? validityDate,
    String? clientOrderRef,
    String? note,
    int? userId,
    int? teamId,
    int? pricelistId,
    int? paymentTermId,
    List<OrderLine>? lines,
    List<int>? removedLineIds,
    List<({int id, String name})>? paymentTerms,
    List<({int id, String name})>? pricelists,
    List<({int id, String name})>? salespersons,
    List<({int id, String name})>? teams,
    bool clearError = false,
  }) =>
      EditOrderState(
        isLoading: isLoading ?? this.isLoading,
        isSaving: isSaving ?? this.isSaving,
        error: clearError ? null : (error ?? this.error),
        order: order ?? this.order,
        partnerId: partnerId ?? this.partnerId,
        partnerName: partnerName ?? this.partnerName,
        dateOrder: dateOrder ?? this.dateOrder,
        validityDate: validityDate ?? this.validityDate,
        clientOrderRef: clientOrderRef ?? this.clientOrderRef,
        note: note ?? this.note,
        userId: userId ?? this.userId,
        teamId: teamId ?? this.teamId,
        pricelistId: pricelistId ?? this.pricelistId,
        paymentTermId: paymentTermId ?? this.paymentTermId,
        lines: lines ?? this.lines,
        removedLineIds: removedLineIds ?? this.removedLineIds,
        paymentTerms: paymentTerms ?? this.paymentTerms,
        pricelists: pricelists ?? this.pricelists,
        salespersons: salespersons ?? this.salespersons,
        teams: teams ?? this.teams,
      );
}

class EditOrderController extends Notifier<EditOrderState> {
  int? _orderId;
  List<int> _originalLineIds = const [];

  @override
  EditOrderState build() => const EditOrderState();

  Future<void> load(int orderId) async {
    _orderId = orderId;
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final orderRepo = ref.read(orderRepositoryProvider);
      final leadRepo = ref.read(leadRepositoryProvider);

      final results = await Future.wait([
        orderRepo.fetchOrderById(orderId),
        orderRepo.fetchPaymentTerms(),
        orderRepo.fetchPricelists(),
        leadRepo.fetchSalespersons(),
        orderRepo.fetchSalesTeams(),
      ]);

      final order = results[0] as Order;
      if (!order.isEditable) {
        throw StateError('This order cannot be edited.');
      }

      _originalLineIds = order.lines.map((l) => l.id).where((id) => id > 0).toList();

      state = state.copyWith(
        isLoading: false,
        order: order,
        partnerId: order.partnerId,
        partnerName: order.customer,
        dateOrder: order.createdAt,
        validityDate: order.validityDate,
        clientOrderRef: order.clientOrderRef ?? '',
        note: order.note ?? '',
        userId: order.userId,
        teamId: order.teamId,
        pricelistId: order.pricelistId,
        paymentTermId: order.paymentTermId,
        lines: order.lines,
        paymentTerms: results[1] as List<({int id, String name})>,
        pricelists: results[2] as List<({int id, String name})>,
        salespersons: results[3] as List<({int id, String name})>,
        teams: results[4] as List<({int id, String name})>,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void setPartner(int id, String name) {
    state = state.copyWith(partnerId: id, partnerName: name);
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
    final currentIds = lines.map((l) => l.id).where((id) => id > 0).toSet();
    final removed = <int>{
      for (final id in _originalLineIds)
        if (!currentIds.contains(id)) id,
      ...state.removedLineIds,
    }.toList();

    state = state.copyWith(lines: lines, removedLineIds: removed);
  }

  Future<Order?> submit() async {
    final orderId = _orderId;
    if (orderId == null) return null;

    if (state.partnerId == null) {
      state = state.copyWith(error: 'Customer is required.');
      return null;
    }
    if (state.lines.isEmpty) {
      state = state.copyWith(error: 'At least one order line is required.');
      return null;
    }

    state = state.copyWith(isSaving: true, clearError: true);
    try {
      final input = OrderUpdateInput(
        orderId: orderId,
        partnerId: state.partnerId,
        dateOrder: state.dateOrder ?? DateTime.now(),
        validityDate: state.validityDate,
        clientOrderRef: state.clientOrderRef.trim(),
        note: state.note.trim(),
        userId: state.userId,
        teamId: state.teamId,
        pricelistId: state.pricelistId,
        paymentTermId: state.paymentTermId,
        lines: state.lines,
        removedLineIds: state.removedLineIds,
      );

      final order = await ref.read(orderRepositoryProvider).updateOrder(input);
      ref.invalidate(orderDetailControllerProvider(orderId));
      await ref.read(orderListControllerProvider.notifier).refresh();
      state = state.copyWith(isSaving: false, order: order);
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

final editOrderControllerProvider =
    NotifierProvider<EditOrderController, EditOrderState>(
  EditOrderController.new,
);
