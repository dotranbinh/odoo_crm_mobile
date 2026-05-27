import '../widgets/searchable_many2one_field.dart';
import 'mobile_ui_schema.dart';

/// Dependencies for rendering dynamic mobile UI form fields.
class MobileUiFormContext {
  const MobileUiFormContext({
    required this.searchMany2one,
    this.staticMany2oneOptions = const {},
  });

  /// Async lookup for any many2one field that declares a [MobileUiFieldSchema.relation].
  final Future<List<Many2oneOption>> Function(
    MobileUiFieldSchema field,
    String query,
  ) searchMany2one;

  /// Preloaded many2one options keyed by field name (e.g. stage_id with custom order).
  final Map<String, List<Many2oneOption>> staticMany2oneOptions;
}
