import 'lead.dart';

class LeadUpdateInput {
  const LeadUpdateInput({
    this.title,
    required this.customerName,
    required this.phone,
    this.email,
    this.mobile,
    this.website,
    this.jobPosition,
    this.companyName,
    this.street,
    this.city,
    this.source,
    this.note,
    this.stage,
    this.priority = LeadPriority.normal,
    this.expectedRevenue,
    this.probability,
    this.dateDeadline,
  });

  final String? title;
  final String customerName;
  final String phone;
  final String? email;
  final String? mobile;
  final String? website;
  final String? jobPosition;
  final String? companyName;
  final String? street;
  final String? city;
  final String? source;
  final String? note;
  final LeadStage? stage;
  final LeadPriority priority;
  final double? expectedRevenue;
  final double? probability;
  final DateTime? dateDeadline;
}
