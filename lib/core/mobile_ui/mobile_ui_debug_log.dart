import 'package:flutter/foundation.dart';

/// Debug logging for mobile UI layout loading (console / DevTools).
abstract final class MobileUiDebugLog {
  static const _tag = '[MobileUI]';

  static void layoutLoaded({
    required String model,
    required String screen,
    required int? companyId,
    required bool fromCache,
    required bool useRealApi,
    required MobileUiLayoutSummary summary,
  }) {
    if (!kDebugMode) return;
    final src = fromCache ? 'CACHE' : (useRealApi ? 'ODOO_RPC' : 'ASSET_MOCK');
    debugPrint(
      '$_tag loadLayout model=$model screen=$screen companyId=$companyId '
      'source=$src version=${summary.version} configured=${summary.isConfigured} '
      'sections=${summary.sectionCount} fields=${summary.fieldCount}',
    );
    for (final s in summary.sections) {
      debugPrint('$_tag   section "${s.title}" (${s.key}): ${s.fieldNames.join(", ")}');
    }
    if (!summary.isConfigured) {
      debugPrint(
        '$_tag   WARN: layout not configured (version=0 or no sections) — '
        'app may fall back to get_views XML',
      );
    }
  }

  static void schemaResolved({
    required String screen,
    required String source,
    required List<String> fieldNames,
    required List<String> groupTitles,
  }) {
    if (!kDebugMode) return;
    debugPrint(
      '$_tag schemaResolved screen=$screen source=$source '
      'groups=${groupTitles.length} readableFields=${fieldNames.length}',
    );
    debugPrint('$_tag   groups: ${groupTitles.join(" | ")}');
    debugPrint('$_tag   fields: ${fieldNames.join(", ")}');
  }

  static void detailValues({
    required int leadId,
    required Map<String, dynamic> values,
    required List<String> expectedFields,
  }) {
    if (!kDebugMode) return;
    debugPrint('$_tag detailValues leadId=$leadId keys=${values.keys.length}');
    for (final name in expectedFields) {
      if (!values.containsKey(name)) {
        debugPrint('$_tag   MISSING read key: $name');
        continue;
      }
      final v = values[name];
      if (_isEmpty(v)) {
        debugPrint('$_tag   $name = (empty)');
      } else {
        debugPrint('$_tag   $name = $v');
      }
    }
  }

  static void cacheCleared({required String reason}) {
    if (!kDebugMode) return;
    debugPrint('$_tag cacheCleared reason=$reason');
  }

  static bool _isEmpty(dynamic value) {
    if (value == null) return true;
    if (value is bool && !value) return true;
    if (value is String && value.trim().isEmpty) return true;
    if (value is List && value.isEmpty) return true;
    return false;
  }
}

class MobileUiLayoutSummary {
  const MobileUiLayoutSummary({
    required this.version,
    required this.isConfigured,
    required this.sectionCount,
    required this.fieldCount,
    required this.sections,
  });

  final int version;
  final bool isConfigured;
  final int sectionCount;
  final int fieldCount;
  final List<MobileUiSectionSummary> sections;
}

class MobileUiSectionSummary {
  const MobileUiSectionSummary({
    required this.key,
    required this.title,
    required this.fieldNames,
  });

  final String key;
  final String title;
  final List<String> fieldNames;
}
