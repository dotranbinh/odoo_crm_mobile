import 'order_line.dart';
import '../../../core/odoo/odoo_write_format.dart';

/// User input for creating a quotation (header + lines).
class QuotationInput {
  const QuotationInput({
    this.partnerId,
    this.opportunityId,
    this.origin,
    required this.dateOrder,
    this.validityDate,
    this.clientOrderRef,
    this.note,
    this.userId,
    this.teamId,
    this.pricelistId,
    this.paymentTermId,
    this.companyId,
    this.sourceId,
    this.mediumId,
    this.campaignId,
    this.tagIds = const [],
    required this.lines,
  });

  final int? partnerId;
  final int? opportunityId;
  final String? origin;
  final DateTime dateOrder;
  final DateTime? validityDate;
  final String? clientOrderRef;
  final String? note;
  final int? userId;
  final int? teamId;
  final int? pricelistId;
  final int? paymentTermId;
  final int? companyId;
  final int? sourceId;
  final int? mediumId;
  final int? campaignId;
  final List<int> tagIds;
  final List<OrderLine> lines;

  Map<String, dynamic> toOdooCreateValues() {
    final values = <String, dynamic>{
      'date_order': OdooWriteFormat.dateTimeUtc(dateOrder),
      if (partnerId != null) 'partner_id': partnerId,
      if (opportunityId != null) 'opportunity_id': opportunityId,
      if (origin != null && origin!.isNotEmpty) 'origin': origin,
      if (validityDate != null) 'validity_date': OdooWriteFormat.date(validityDate!),
      if (clientOrderRef != null && clientOrderRef!.isNotEmpty)
        'client_order_ref': clientOrderRef,
      if (note != null && note!.isNotEmpty) 'note': note,
      if (userId != null) 'user_id': userId,
      if (teamId != null) 'team_id': teamId,
      if (pricelistId != null) 'pricelist_id': pricelistId,
      if (paymentTermId != null) 'payment_term_id': paymentTermId,
      if (companyId != null) 'company_id': companyId,
      if (sourceId != null) 'source_id': sourceId,
      if (mediumId != null) 'medium_id': mediumId,
      if (campaignId != null) 'campaign_id': campaignId,
      if (tagIds.isNotEmpty) 'tag_ids': [
        [6, 0, tagIds],
      ],
      'order_line': [
        for (final line in lines)
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
      ],
    };
    return values;
  }
}
