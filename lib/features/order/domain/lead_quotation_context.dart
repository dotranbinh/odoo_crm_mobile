/// Raw Odoo lead data needed to prefill a quotation form.
class LeadQuotationContext {
  const LeadQuotationContext({
    required this.leadId,
    required this.type,
    required this.name,
    this.partnerId,
    this.partnerName,
    this.contactName,
    this.email,
    this.phone,
    this.street,
    this.city,
    this.countryId,
    this.userId,
    this.teamId,
    this.companyId,
    this.sourceId,
    this.mediumId,
    this.campaignId,
    this.tagIds = const [],
  });

  final int leadId;
  final String type;
  final String name;
  final int? partnerId;
  final String? partnerName;
  final String? contactName;
  final String? email;
  final String? phone;
  final String? street;
  final String? city;
  final int? countryId;
  final int? userId;
  final int? teamId;
  final int? companyId;
  final int? sourceId;
  final int? mediumId;
  final int? campaignId;
  final List<int> tagIds;

  bool get isOpportunity => type == 'opportunity';

  String get displayCustomer =>
      partnerName?.isNotEmpty == true
          ? partnerName!
          : (contactName?.isNotEmpty == true ? contactName! : name);

  factory LeadQuotationContext.fromOdoo(Map<String, dynamic> json) {
    return LeadQuotationContext(
      leadId: json['id'] as int? ?? 0,
      type: json['type']?.toString() ?? 'lead',
      name: json['name']?.toString() ?? '',
      partnerId: _many2oneId(json['partner_id']),
      partnerName: json['partner_name']?.toString(),
      contactName: json['contact_name']?.toString(),
      email: json['email_from']?.toString(),
      phone: json['phone']?.toString(),
      street: json['street']?.toString(),
      city: json['city']?.toString(),
      countryId: _many2oneId(json['country_id']),
      userId: _many2oneId(json['user_id']),
      teamId: _many2oneId(json['team_id']),
      companyId: _many2oneId(json['company_id']),
      sourceId: _many2oneId(json['source_id']),
      mediumId: _many2oneId(json['medium_id']),
      campaignId: _many2oneId(json['campaign_id']),
      tagIds: _tagIds(json['tag_ids']),
    );
  }
}

int? _many2oneId(dynamic value) {
  if (value is List && value.isNotEmpty) return value.first as int?;
  if (value is bool && !value) return null;
  return null;
}

List<int> _tagIds(dynamic value) {
  if (value is! List) return const [];
  return value.whereType<int>().toList();
}
