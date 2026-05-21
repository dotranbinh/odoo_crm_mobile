import 'lead.dart';

class LeadListItem {
  const LeadListItem({
    required this.lead,
    required this.values,
  });

  final Lead lead;
  final Map<String, dynamic> values;
}
