import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/constants/app_config.dart';
import '../../../core/network/odoo_json_rpc_client.dart';
import '../../lead/data/lead_repository.dart';
import '../domain/lead_quotation_context.dart';
import '../domain/order.dart';
import '../domain/order_update_input.dart';
import '../domain/quotation_input.dart';

class OrderRepository {
  OrderRepository(this._rpc, this._leadRepository);

  final OdooJsonRpcClient _rpc;
  final LeadRepository _leadRepository;

  static const saleOrderModel = 'sale.order';
  static final _mockOrders = <Order>[];

  Future<List<Order>> fetchOrders({
    OrderStatus? status,
    String? query,
    int limit = 50,
  }) {
    if (AppConfig.useRealApi) {
      return _fetchRemote(status: status, query: query, limit: limit);
    }
    return _fetchMock(status: status, query: query);
  }

  Future<Order> fetchOrderById(int id) async {
    if (!AppConfig.useRealApi) {
      final found = _mockOrders.where((o) => o.id == id);
      if (found.isEmpty) {
        final seed = await _fetchMock();
        final fromSeed = seed.where((o) => o.id == id);
        if (fromSeed.isEmpty) throw StateError('Order not found');
        return fromSeed.first;
      }
      return found.first;
    }
    final rows = await _rpc.callKw(
      model: saleOrderModel,
      method: 'read',
      args: [
        [id],
      ],
      kwargs: {
        'fields': _orderFields,
      },
    );
    if (rows is! List || rows.isEmpty) {
      throw StateError('Order not found');
    }
    final orderJson = rows.first as Map<String, dynamic>;
    final lines = await _readOrderLines(orderJson['order_line']);
    return Order.fromOdoo({...orderJson, 'order_line': lines});
  }

  Future<List<Map<String, dynamic>>> _readOrderLines(dynamic lineIds) async {
    if (lineIds is! List || lineIds.isEmpty) return const [];
    final ids = lineIds.whereType<int>().toList();
    if (ids.isEmpty) return const [];

    final rows = await _rpc.callKw(
      model: 'sale.order.line',
      method: 'read',
      args: [ids],
      kwargs: {
        'fields': _lineFields,
      },
    );
    if (rows is! List) return const [];
    return [
      for (final row in rows)
        if (row is Map<String, dynamic>) row,
    ];
  }

  Future<Order> updateOrder(OrderUpdateInput input) async {
    if (!AppConfig.useRealApi) {
      return _updateMock(input);
    }

    if (input.lines.isEmpty) {
      throw StateError('At least one order line is required.');
    }

    await _rpc.callKw(
      model: saleOrderModel,
      method: 'write',
      args: [
        [input.orderId],
        input.toOdooWriteValues(),
      ],
    );

    return fetchOrderById(input.orderId);
  }

  Future<List<({int id, String name})>> searchProducts(String query) async {
    if (!AppConfig.useRealApi) {
      return [
        (id: 1, name: 'Consulting Service'),
        (id: 2, name: 'Software License'),
        (id: 3, name: 'Training Package'),
      ].where((p) => p.name.toLowerCase().contains(query.toLowerCase())).toList();
    }

    final rows = await _rpc.callKw(
      model: 'product.product',
      method: 'search_read',
      args: [
        [
          ['sale_ok', '=', true],
          ['name', 'ilike', query],
        ],
      ],
      kwargs: {
        'fields': ['id', 'name', 'list_price'],
        'limit': 20,
      },
    );
    if (rows is! List) return const [];
    return [
      for (final row in rows)
        if (row is Map<String, dynamic>)
          (
            id: row['id'] as int,
            name: row['name']?.toString() ?? '',
          ),
    ];
  }

  Future<double?> fetchProductListPrice(int productId) async {
    if (!AppConfig.useRealApi) return 100.0;
    final rows = await _rpc.callKw(
      model: 'product.product',
      method: 'read',
      args: [
        [productId],
      ],
      kwargs: {
        'fields': ['list_price'],
      },
    );
    if (rows is! List || rows.isEmpty) return null;
    final price = (rows.first as Map<String, dynamic>)['list_price'];
    return price is num ? price.toDouble() : null;
  }

  Future<List<({int id, String name})>> fetchPaymentTerms() async {
    if (!AppConfig.useRealApi) {
      return [
        (id: 1, name: 'Immediate'),
        (id: 2, name: '15 Days'),
        (id: 3, name: '30 Days'),
      ];
    }
    final rows = await _rpc.callKw(
      model: 'account.payment.term',
      method: 'search_read',
      args: [[]],
      kwargs: {
        'fields': ['id', 'name'],
        'limit': 50,
      },
    );
    if (rows is! List) return const [];
    return [
      for (final row in rows)
        if (row is Map<String, dynamic>)
          (
            id: row['id'] as int,
            name: row['name']?.toString() ?? '',
          ),
    ];
  }

  Future<List<({int id, String name})>> fetchPricelists() async {
    if (!AppConfig.useRealApi) {
      return [
        (id: 1, name: 'Public Pricelist'),
      ];
    }
    final rows = await _rpc.callKw(
      model: 'product.pricelist',
      method: 'search_read',
      args: [[]],
      kwargs: {
        'fields': ['id', 'name'],
        'limit': 50,
      },
    );
    if (rows is! List) return const [];
    return [
      for (final row in rows)
        if (row is Map<String, dynamic>)
          (
            id: row['id'] as int,
            name: row['name']?.toString() ?? '',
          ),
    ];
  }

  Future<List<({int id, String name})>> searchPartners(String query) async {
    if (!AppConfig.useRealApi) {
      return [
        (id: 1, name: 'Demo Customer'),
      ];
    }
    final rows = await _rpc.callKw(
      model: 'res.partner',
      method: 'search_read',
      args: [
        [
          ['name', 'ilike', query],
        ],
      ],
      kwargs: {
        'fields': ['id', 'name'],
        'limit': 20,
      },
    );
    if (rows is! List) return const [];
    return [
      for (final row in rows)
        if (row is Map<String, dynamic>)
          (
            id: row['id'] as int,
            name: row['name']?.toString() ?? '',
          ),
    ];
  }

  Future<int> createPartnerFromLead(LeadQuotationContext lead) async {
    if (!AppConfig.useRealApi) {
      return 999;
    }
    final name = lead.partnerName?.isNotEmpty == true
        ? lead.partnerName!
        : (lead.contactName?.isNotEmpty == true
            ? lead.contactName!
            : lead.name);

    final partnerId = await _rpc.callKw(
      model: 'res.partner',
      method: 'create',
      args: [
        {
          'name': name,
          if (lead.email?.isNotEmpty == true) 'email': lead.email,
          if (lead.phone?.isNotEmpty == true) 'phone': lead.phone,
          if (lead.street?.isNotEmpty == true) 'street': lead.street,
          if (lead.city?.isNotEmpty == true) 'city': lead.city,
          if (lead.countryId != null) 'country_id': lead.countryId,
          'type': 'contact',
        },
      ],
    );

    final id = partnerId is int ? partnerId : int.tryParse(partnerId.toString());
    if (id == null) throw StateError('Failed to create partner');

    await _rpc.callKw(
      model: LeadRepository.crmLeadModel,
      method: 'write',
      args: [
        [lead.leadId],
        {'partner_id': id},
      ],
    );

    return id;
  }

  Future<Order> createQuotation({
    required QuotationInput input,
    int? leadId,
  }) async {
    if (!AppConfig.useRealApi) {
      return _createMock(input);
    }

    var partnerId = input.partnerId;
    LeadQuotationContext? leadContext;

    if (leadId != null) {
      leadContext = await _leadRepository.fetchLeadForQuotation(leadId);

      if (!leadContext.isOpportunity) {
        await _leadRepository.convertToOpportunity(leadId);
        leadContext = await _leadRepository.fetchLeadForQuotation(leadId);
      }

      if (partnerId == null && leadContext.partnerId != null) {
        partnerId = leadContext.partnerId;
      }

      partnerId ??= await createPartnerFromLead(leadContext);
    }

    if (partnerId == null) {
      throw StateError('Customer is required to create a quotation.');
    }

    if (input.lines.isEmpty) {
      throw StateError('At least one order line is required.');
    }

    final values = input.toOdooCreateValues();
    values['partner_id'] = partnerId;
    if (leadId != null) {
      values['opportunity_id'] = leadId;
    }

    final orderId = await _rpc.callKw(
      model: saleOrderModel,
      method: 'create',
      args: [values],
    );

    final id = orderId is int ? orderId : int.tryParse(orderId.toString());
    if (id == null) throw StateError('Invalid create response');

    return fetchOrderById(id);
  }

  Future<List<({int id, String name})>> fetchSalesTeams() async {
    if (!AppConfig.useRealApi) {
      return [
        (id: 1, name: 'Sales'),
      ];
    }
    final rows = await _rpc.callKw(
      model: 'crm.team',
      method: 'search_read',
      args: [[]],
      kwargs: {
        'fields': ['id', 'name'],
        'limit': 50,
      },
    );
    if (rows is! List) return const [];
    return [
      for (final row in rows)
        if (row is Map<String, dynamic>)
          (
            id: row['id'] as int,
            name: row['name']?.toString() ?? '',
          ),
    ];
  }

  Future<List<Order>> fetchOrdersForLead(int leadId) async {
    if (!AppConfig.useRealApi) return const [];

    final rows = await _rpc.callKw(
      model: saleOrderModel,
      method: 'search_read',
      args: [
        [
          ['opportunity_id', '=', leadId],
        ],
      ],
      kwargs: {
        'fields': _listFields,
        'order': 'date_order desc',
        'limit': 20,
      },
    );

    if (rows is! List) return const [];
    return [
      for (final row in rows)
        if (row is Map<String, dynamic>) Order.fromOdoo(row),
    ];
  }

  Future<List<Order>> _fetchRemote({
    OrderStatus? status,
    String? query,
    int limit = 50,
  }) async {
    final domain = <dynamic>[];
    final odooState = orderStatusOdooState(status);
    if (odooState != null) {
      domain.add(['state', '=', odooState]);
    }
    if (query != null && query.isNotEmpty) {
      domain.addAll([
        '|',
        ['name', 'ilike', query],
        ['partner_id.name', 'ilike', query],
      ]);
    }

    final rows = await _rpc.callKw(
      model: saleOrderModel,
      method: 'search_read',
      args: [domain],
      kwargs: {
        'fields': _listFields,
        'limit': limit,
        'order': 'date_order desc',
      },
    );

    if (rows is! List) return const [];
    return [
      for (final row in rows)
        if (row is Map<String, dynamic>) Order.fromOdoo(row),
    ];
  }

  Future<List<Order>> _fetchMock({
    OrderStatus? status,
    String? query,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));

    final seed = [
      if (_mockOrders.isNotEmpty) ..._mockOrders,
      Order(
        id: 1,
        number: 'SO-2024-001',
        customer: 'Nguyen Van A',
        amount: 12500,
        currency: 'USD',
        status: OrderStatus.draft,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Order(
        id: 2,
        number: 'SO-2024-002',
        customer: 'Tran Thi B',
        amount: 28750,
        currency: 'USD',
        status: OrderStatus.sale,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      Order(
        id: 3,
        number: 'SO-2024-003',
        customer: 'Le Van C',
        amount: 54200,
        currency: 'USD',
        status: OrderStatus.sent,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ];

    var filtered = seed;
    if (status != null) {
      filtered = filtered.where((o) => o.status == status).toList();
    }
    if (query != null && query.isNotEmpty) {
      final q = query.toLowerCase();
      filtered = filtered
          .where(
            (o) =>
                o.number.toLowerCase().contains(q) ||
                o.customer.toLowerCase().contains(q),
          )
          .toList();
    }
    return filtered;
  }

  Order _createMock(QuotationInput input) {
    final nextId = _mockOrders.fold<int>(
      0,
      (max, o) => o.id > max ? o.id : max,
    ) + 1;

    final total = input.lines.fold<double>(
      0,
      (sum, line) => sum + line.quantity * line.priceUnit,
    );

    final order = Order(
      id: nextId,
      number: 'SO-MOCK-$nextId',
      customer: 'Mock Customer',
      amount: total,
      currency: 'USD',
      status: OrderStatus.draft,
      createdAt: input.dateOrder,
      partnerId: input.partnerId ?? 1,
      opportunityId: input.opportunityId,
      origin: input.origin,
      validityDate: input.validityDate,
      note: input.note,
      lines: input.lines,
    );
    _mockOrders.insert(0, order);
    return order;
  }

  Order _updateMock(OrderUpdateInput input) {
    var index = _mockOrders.indexWhere((o) => o.id == input.orderId);
    late Order base;

    if (index >= 0) {
      base = _mockOrders[index];
    } else {
      base = Order(
        id: input.orderId,
        number: 'SO-MOCK-${input.orderId}',
        customer: 'Mock Customer',
        amount: 0,
        currency: 'USD',
        status: OrderStatus.draft,
        createdAt: input.dateOrder,
        partnerId: input.partnerId ?? 1,
      );
      for (final seed in [
        Order(
          id: 1,
          number: 'SO-2024-001',
          customer: 'Nguyen Van A',
          amount: 12500,
          currency: 'USD',
          status: OrderStatus.draft,
          createdAt: DateTime.now(),
        ),
        Order(
          id: 2,
          number: 'SO-2024-002',
          customer: 'Tran Thi B',
          amount: 28750,
          currency: 'USD',
          status: OrderStatus.sale,
          createdAt: DateTime.now(),
        ),
        Order(
          id: 3,
          number: 'SO-2024-003',
          customer: 'Le Van C',
          amount: 54200,
          currency: 'USD',
          status: OrderStatus.sent,
          createdAt: DateTime.now(),
        ),
      ]) {
        if (seed.id == input.orderId) {
          base = seed;
          break;
        }
      }
      _mockOrders.add(base);
      index = _mockOrders.length - 1;
    }

    final total = input.lines.fold<double>(
      0,
      (sum, line) => sum + line.quantity * line.priceUnit,
    );

    final updated = base.copyWith(
      amount: total,
      createdAt: input.dateOrder,
      validityDate: input.validityDate,
      note: input.note,
      clientOrderRef: input.clientOrderRef,
      userId: input.userId,
      teamId: input.teamId,
      pricelistId: input.pricelistId,
      paymentTermId: input.paymentTermId,
      partnerId: input.partnerId ?? base.partnerId,
      lines: input.lines,
    );

    _mockOrders[index] = updated;
    return updated;
  }

  static const _lineFields = [
    'id',
    'product_id',
    'name',
    'product_uom_qty',
    'product_uom',
    'price_unit',
    'discount',
    'price_subtotal',
    'tax_id',
  ];

  static const _listFields = [
    'id',
    'name',
    'partner_id',
    'amount_total',
    'currency_id',
    'state',
    'date_order',
    'opportunity_id',
    'origin',
  ];

  static const _orderFields = [
    'id',
    'name',
    'partner_id',
    'amount_total',
    'currency_id',
    'state',
    'date_order',
    'validity_date',
    'origin',
    'note',
    'client_order_ref',
    'user_id',
    'team_id',
    'pricelist_id',
    'payment_term_id',
    'opportunity_id',
    'order_line',
  ];
}

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepository(
    ref.watch(odooJsonRpcClientProvider),
    ref.watch(leadRepositoryProvider),
  );
});
