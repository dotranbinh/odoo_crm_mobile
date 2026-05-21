import '../../../core/odoo/odoo_form_schema.dart';
import 'lead.dart';

class LeadDetailViewData {
  const LeadDetailViewData({
    required this.summary,
    required this.schema,
    required this.values,
  });

  final Lead summary;
  final OdooFormSchema schema;
  final Map<String, dynamic> values;
}
