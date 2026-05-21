import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/odoo_json_rpc_client.dart';
import 'odoo_form_schema.dart';
import 'odoo_form_schema_parser.dart';

class OdooFormSchemaService {
  OdooFormSchemaService(this._rpc);

  final OdooJsonRpcClient _rpc;

  final _cache = <String, OdooFormSchema>{};

  Future<OdooFormSchema> loadFormSchema({
    required String model,
    String otherInfoTitle = 'Other Information',
  }) async {
    final cacheKey = '$model|$otherInfoTitle';
    final cached = _cache[cacheKey];
    if (cached != null) return cached;

    // get_views(views, options=None) — views must be the first positional arg,
    // e.g. [[false, 'form']]. Passing [[], {views: ...}] leaves views empty.
    final result = await _rpc.callKw(
      model: model,
      method: 'get_views',
      args: [
        [
          [false, 'form'],
        ],
      ],
    );

    if (result is! Map) {
      throw StateError('Invalid get_views response for $model');
    }

    final resultMap = Map<String, dynamic>.from(result);
    final arch = _extractFormArch(resultMap);
    var modelFields = _extractModelFields(resultMap, model);
    if (modelFields.isEmpty) {
      modelFields = await _fetchFieldsGet(model);
    }

    final schema = OdooFormSchemaParser(otherInfoTitle: otherInfoTitle).parse(
      model: model,
      archXml: arch,
      modelFieldsJson: modelFields,
    );

    _cache[cacheKey] = schema;
    return schema;
  }

  void clearCache() => _cache.clear();

  String _extractFormArch(Map<String, dynamic> result) {
    final fromViews = _archFromViewsMap(result['views']);
    if (fromViews != null) return fromViews;

    final fromFieldsViews = _archFromViewsMap(result['fields_views']);
    if (fromFieldsViews != null) return fromFieldsViews;

    final deep = _findArchDeep(result);
    if (deep != null) return deep;

    if (kDebugMode) {
      debugPrint(
        '[OdooFormSchema] get_views keys: ${result.keys.toList()}',
      );
      final views = result['views'];
      if (views is Map) {
        debugPrint('[OdooFormSchema] views keys: ${views.keys.toList()}');
      }
    }

    throw StateError('Form arch not found in get_views response');
  }

  String? _archFromViewsMap(dynamic views) {
    if (views is! Map) return null;

    final form = views['form'];
    if (form is Map) {
      final arch = form['arch'];
      if (arch is String && arch.isNotEmpty) return arch;
    }

    // Some responses nest by view id string key.
    for (final entry in views.entries) {
      final value = entry.value;
      if (value is Map) {
        final arch = value['arch'];
        if (arch is String &&
            arch.contains('<form') &&
            arch.isNotEmpty) {
          return arch;
        }
      }
    }
    return null;
  }

  String? _findArchDeep(dynamic node) {
    if (node is Map) {
      final arch = node['arch'];
      if (arch is String && arch.contains('<form')) return arch;
      for (final value in node.values) {
        final found = _findArchDeep(value);
        if (found != null) return found;
      }
    } else if (node is List) {
      for (final item in node) {
        final found = _findArchDeep(item);
        if (found != null) return found;
      }
    }
    return null;
  }

  Map<String, dynamic> _extractModelFields(
    Map<String, dynamic> result,
    String model,
  ) {
    final models = result['models'];
    if (models is Map) {
      final modelEntry = models[model];
      if (modelEntry is Map) {
        final fields = modelEntry['fields'];
        if (fields is Map) {
          return Map<String, dynamic>.from(fields);
        }
        return Map<String, dynamic>.from(modelEntry);
      }
    }

    final views = result['views'];
    if (views is Map) {
      final form = views['form'];
      if (form is Map && form['fields'] is Map) {
        return Map<String, dynamic>.from(form['fields'] as Map);
      }
    }

    return {};
  }

  Future<Map<String, dynamic>> _fetchFieldsGet(String model) async {
    final result = await _rpc.callKw(
      model: model,
      method: 'fields_get',
      args: [],
      kwargs: {
        'attributes': ['string', 'type', 'selection', 'relation', 'readonly', 'required'],
      },
    );
    if (result is Map) {
      return Map<String, dynamic>.from(result);
    }
    throw StateError('Model fields not found in get_views response');
  }
}

final odooFormSchemaServiceProvider = Provider<OdooFormSchemaService>((ref) {
  return OdooFormSchemaService(ref.watch(odooJsonRpcClientProvider));
});

final odooFormSchemaProvider = FutureProvider.family<OdooFormSchema, String>(
  (ref, model) async {
    return ref.read(odooFormSchemaServiceProvider).loadFormSchema(model: model);
  },
);
