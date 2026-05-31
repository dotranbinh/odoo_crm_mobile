import '../network/odoo_json_rpc_client.dart';
import '../mobile_ui/mobile_ui_schema.dart';

/// Resolves many2many IDs from `read` into `[[id, name], ...]` for mobile UI.
class OdooMany2manyEnricher {
  OdooMany2manyEnricher(this._rpc);

  final OdooJsonRpcClient _rpc;

  Future<Map<String, dynamic>> enrich(
    Map<String, dynamic> values,
    Iterable<MobileUiFieldSchema> fields,
  ) async {
    final enriched = Map<String, dynamic>.from(values);

    for (final field in fields) {
      if (!_needsEnrich(field)) continue;
      final relation = field.relation;
      if (relation == null || relation.isEmpty) continue;

      final raw = enriched[field.name];
      if (Many2manyValueHelper.isEnriched(raw)) continue;

      final ids = Many2manyValueHelper.parseIds(raw);
      if (ids.isEmpty) {
        enriched[field.name] = <List<dynamic>>[];
        continue;
      }

      enriched[field.name] = await _fetchPairs(relation, ids);
    }

    return enriched;
  }

  bool _needsEnrich(MobileUiFieldSchema field) =>
      field.type == 'many2many' || field.widget == 'tags';

  Future<List<List<dynamic>>> _fetchPairs(String relation, List<int> ids) async {
    final rows = await _rpc.callKw(
      model: relation,
      method: 'search_read',
      args: [
        [
          ['id', 'in', ids],
        ],
      ],
      kwargs: {
        'fields': ['id', 'name', 'display_name'],
        'order': 'name asc',
      },
    );

    if (rows is! List) return [];

    final byId = <int, String>{};
    for (final row in rows) {
      if (row is! Map) continue;
      final map = Map<String, dynamic>.from(row);
      final id = map['id'] as int?;
      if (id == null) continue;
      final name = map['display_name']?.toString() ??
          map['name']?.toString() ??
          '#$id';
      byId[id] = name;
    }

    return [
      for (final id in ids)
        if (byId.containsKey(id)) [id, byId[id]],
    ];
  }
}

abstract final class Many2manyValueHelper {
  static bool isEnriched(dynamic value) {
    if (value is! List || value.isEmpty) return false;
    final first = value.first;
    return first is List && first.isNotEmpty;
  }

  static List<int> parseIds(dynamic value) {
    if (value is! List) return const [];
    final ids = <int>[];
    for (final item in value) {
      if (item is int) {
        ids.add(item);
      } else if (item is List && item.isNotEmpty) {
        final id = item.first;
        if (id is int) ids.add(id);
      }
    }
    return ids;
  }

  static List<String> labels(dynamic value) {
    if (value is! List) return const [];
    final labels = <String>[];
    for (final item in value) {
      if (item is List && item.length > 1) {
        labels.add(item[1].toString());
      } else if (item is String && item.isNotEmpty) {
        labels.add(item);
      }
    }
    return labels;
  }
}
