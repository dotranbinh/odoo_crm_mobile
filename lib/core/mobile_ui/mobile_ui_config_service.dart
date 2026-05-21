import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/constants/app_config.dart';
import '../network/odoo_json_rpc_client.dart';
import '../network/odoo_session.dart';
import 'mobile_ui_debug_log.dart';
import 'mobile_ui_schema.dart';

class MobileUiConfigService {
  MobileUiConfigService(this._rpc);

  final OdooJsonRpcClient _rpc;

  final _cache = <String, MobileUiLayoutSchema>{};

  Future<MobileUiLayoutSchema> loadLayout({
    required String model,
    required String screen,
    int? companyId,
  }) async {
    if (!AppConfig.useRealApi) {
      return _loadMock(model: model, screen: screen);
    }

    final cacheKey = '$model|$screen|${companyId ?? 0}';

    final result = await _rpc.callKw(
      model: 'mobile.ui.layout',
      method: 'get_mobile_layout',
      args: [model, screen],
      kwargs: {
        'company_id': ?companyId,
      },
    );

    final schema = _parseResult(result, model: model, screen: screen);
    final cached = _cache[cacheKey];
    if (cached != null && cached.version == schema.version) {
      _logLayout(
        model: model,
        screen: screen,
        companyId: companyId,
        fromCache: true,
        schema: cached,
      );
      return cached;
    }

    _cache[cacheKey] = schema;
    _logLayout(
      model: model,
      screen: screen,
      companyId: companyId,
      fromCache: false,
      schema: schema,
    );
    return schema;
  }

  MobileUiLayoutSchema _parseResult(
    dynamic result, {
    required String model,
    required String screen,
  }) {
    if (result is Map) {
      return MobileUiLayoutSchema.fromJson(Map<String, dynamic>.from(result));
    }
    return MobileUiLayoutSchema(
      version: 0,
      model: model,
      screen: screen,
      sections: const [],
    );
  }

  Future<MobileUiLayoutSchema> _loadMock({
    required String model,
    required String screen,
  }) async {
    final path = 'assets/mock/mobile_ui_${model.replaceAll('.', '_')}_$screen.json';
    try {
      final raw = await rootBundle.loadString(path);
      final schema = MobileUiLayoutSchema.fromJson(
        Map<String, dynamic>.from(jsonDecode(raw) as Map),
      );
      _logLayout(
        model: model,
        screen: screen,
        companyId: null,
        fromCache: false,
        schema: schema,
        mockPath: path,
      );
      return schema;
    } catch (e) {
      MobileUiDebugLog.layoutLoaded(
        model: model,
        screen: screen,
        companyId: null,
        fromCache: false,
        useRealApi: false,
        summary: const MobileUiLayoutSummary(
          version: 0,
          isConfigured: false,
          sectionCount: 0,
          fieldCount: 0,
          sections: [],
        ),
      );
      debugPrint('[MobileUI] mock load failed path=$path error=$e');
      return MobileUiLayoutSchema(
        version: 0,
        model: model,
        screen: screen,
        sections: const [],
      );
    }
  }

  void clearCache() {
    _cache.clear();
    MobileUiDebugLog.cacheCleared(reason: 'clearCache()');
  }

  void _logLayout({
    required String model,
    required String screen,
    required int? companyId,
    required bool fromCache,
    required MobileUiLayoutSchema schema,
    String? mockPath,
  }) {
    if (mockPath != null) {
      debugPrint('[MobileUI] mock asset: $mockPath');
    }
    MobileUiDebugLog.layoutLoaded(
      model: model,
      screen: screen,
      companyId: companyId,
      fromCache: fromCache,
      useRealApi: AppConfig.useRealApi,
      summary: _summary(schema),
    );
  }

  MobileUiLayoutSummary _summary(MobileUiLayoutSchema schema) {
    final sections = <MobileUiSectionSummary>[];
    var fieldCount = 0;
    for (final s in schema.sections) {
      final names = s.fields.map((f) => f.name).toList();
      fieldCount += names.length;
      sections.add(
        MobileUiSectionSummary(
          key: s.key,
          title: s.title,
          fieldNames: names,
        ),
      );
    }
    return MobileUiLayoutSummary(
      version: schema.version,
      isConfigured: schema.isConfigured,
      sectionCount: schema.sections.length,
      fieldCount: fieldCount,
      sections: sections,
    );
  }
}

final mobileUiConfigServiceProvider = Provider<MobileUiConfigService>((ref) {
  return MobileUiConfigService(ref.watch(odooJsonRpcClientProvider));
});

/// Cached layout per model + screen.
final mobileUiLayoutProvider = FutureProvider.family<MobileUiLayoutSchema, (
  String model,
  String screen,
)>(
  (ref, params) async {
    final session = ref.watch(odooSessionStoreProvider).current;
    return ref.read(mobileUiConfigServiceProvider).loadLayout(
          model: params.$1,
          screen: params.$2,
          companyId: session.companyId,
        );
  },
);
