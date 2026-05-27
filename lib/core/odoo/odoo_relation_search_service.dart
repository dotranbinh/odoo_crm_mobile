import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/constants/app_config.dart';
import '../network/odoo_json_rpc_client.dart';
import '../widgets/searchable_many2one_field.dart';

/// Generic Odoo many2one lookup via `name_search` (fallback `search_read`).
class OdooRelationSearchService {
  OdooRelationSearchService(this._rpc);

  final OdooJsonRpcClient _rpc;

  static const _mockByModel = <String, List<Many2oneOption>>{
    'res.country': [
      (id: 243, name: 'Vietnam'),
      (id: 233, name: 'United States'),
      (id: 75, name: 'France'),
    ],
    'crm.stage': [
      (id: 1, name: 'New'),
      (id: 2, name: 'Qualified'),
      (id: 3, name: 'Proposition'),
    ],
    'utm.source': [
      (id: 1, name: 'Search engine'),
      (id: 2, name: 'Website'),
    ],
    'utm.medium': [
      (id: 1, name: 'Website'),
      (id: 2, name: 'Email'),
    ],
    'utm.campaign': [
      (id: 1, name: 'Summer Promo'),
      (id: 2, name: 'Launch'),
    ],
  };

  Future<List<Many2oneOption>> search({
    required String relation,
    String query = '',
    List<dynamic> domain = const [],
    int limit = 50,
  }) async {
    if (relation.isEmpty) return const [];

    if (!AppConfig.useRealApi) {
      return _mockSearch(relation: relation, query: query, limit: limit);
    }

    final trimmed = query.trim();
    final nameSearchArgs = <dynamic>[
      trimmed,
      if (domain.isNotEmpty) domain else <dynamic>[],
    ];

    try {
      final rows = await _rpc.callKw(
        model: relation,
        method: 'name_search',
        args: nameSearchArgs,
        kwargs: {'limit': limit},
      );
      final fromNameSearch = _parseNameSearch(rows);
      if (fromNameSearch.isNotEmpty || trimmed.isNotEmpty) {
        return fromNameSearch;
      }
    } catch (_) {
      // Fall through to search_read for models without name_search.
    }

    final readDomain = <dynamic>[...domain];
    if (trimmed.isNotEmpty) {
      readDomain.add(['name', 'ilike', trimmed]);
    }

    final rows = await _rpc.callKw(
      model: relation,
      method: 'search_read',
      args: [readDomain],
      kwargs: {
        'fields': ['id', 'name', 'display_name'],
        'order': 'name asc',
        'limit': limit,
      },
    );
    return _parseSearchRead(rows);
  }

  List<Many2oneOption> _mockSearch({
    required String relation,
    required String query,
    required int limit,
  }) {
    final items = _mockByModel[relation] ?? const <Many2oneOption>[];
    final q = query.trim().toLowerCase();
    final filtered = q.isEmpty
        ? items
        : items.where((item) => item.name.toLowerCase().contains(q));
    return filtered.take(limit).toList();
  }

  List<Many2oneOption> _parseNameSearch(dynamic rows) {
    if (rows is! List) return const [];
    return [
      for (final row in rows)
        if (row is List && row.length >= 2 && row[0] is int)
          (id: row[0] as int, name: row[1]?.toString() ?? ''),
    ];
  }

  List<Many2oneOption> _parseSearchRead(dynamic rows) {
    if (rows is! List) return const [];
    return [
      for (final row in rows)
        if (row is Map<String, dynamic>)
          (
            id: row['id'] as int,
            name: row['display_name']?.toString() ??
                row['name']?.toString() ??
                '',
          ),
    ];
  }
}

final odooRelationSearchServiceProvider = Provider<OdooRelationSearchService>(
  (ref) => OdooRelationSearchService(ref.watch(odooJsonRpcClientProvider)),
);
