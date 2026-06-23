import 'order_line.dart';
import '../../../core/odoo/odoo_write_format.dart';

/// User input for updating an existing quotation / sales order.
class OrderUpdateInput {
  const OrderUpdateInput({
    required this.orderId,
    this.partnerId,
    required this.dateOrder,
    this.validityDate,
    this.clientOrderRef,
    this.note,
    this.userId,
    this.teamId,
    this.pricelistId,
    this.paymentTermId,
    required this.lines,
    this.removedLineIds = const [],
  });

  final int orderId;
  final int? partnerId;
  final DateTime dateOrder;
  final DateTime? validityDate;
  final String? clientOrderRef;
  final String? note;
  final int? userId;
  final int? teamId;
  final int? pricelistId;
  final int? paymentTermId;
  final List<OrderLine> lines;
  final List<int> removedLineIds;

  Map<String, dynamic> toOdooWriteValues() {
    final values = <String, dynamic>{
      'date_order': OdooWriteFormat.dateTimeUtc(dateOrder),
      if (partnerId != null) 'partner_id': partnerId,
      if (validityDate != null) 'validity_date': OdooWriteFormat.date(validityDate!),
      if (clientOrderRef != null && clientOrderRef!.isNotEmpty)
        'client_order_ref': clientOrderRef,
      if (note != null) 'note': note,
      if (userId != null) 'user_id': userId,
      if (teamId != null) 'team_id': teamId,
      if (pricelistId != null) 'pricelist_id': pricelistId,
      if (paymentTermId != null) 'payment_term_id': paymentTermId,
    };

    final commands = <List<dynamic>>[
      for (final line in lines)
        if (line.id > 0)
          [
            1,
            line.id,
            {
              'product_id': line.productId,
              'product_uom_qty': line.quantity,
              if (line.priceUnit > 0) 'price_unit': line.priceUnit,
              if (line.description.isNotEmpty) 'name': line.description,
            },
          ]
        else
          [
            0,
            0,
            {
              'product_id': line.productId,
              'product_uom_qty': line.quantity,
              if (line.priceUnit > 0) 'price_unit': line.priceUnit,
              if (line.description.isNotEmpty) 'name': line.description,
            },
          ],
      for (final id in removedLineIds) [2, id],
    ];

    if (commands.isNotEmpty) {
      values['order_line'] = commands;
    }

    return values;
  }
}
