import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/constants/app_config.dart';
import '../../../core/mobile_ui/mobile_ui_config_service.dart';
import '../../../core/mobile_ui/mobile_ui_debug_log.dart';
import '../../../core/mobile_ui/mobile_ui_schema.dart';
import '../../../core/mobile_ui/mobile_ui_schema_mapper.dart';
import '../../../core/mobile_ui/mobile_ui_write_coercer.dart';
import '../../../core/network/odoo_json_rpc_client.dart';
import '../../../core/network/odoo_session.dart';
import '../../../core/odoo/odoo_form_schema.dart';
import '../../../core/odoo/odoo_form_schema_service.dart';
import '../../../core/odoo/odoo_mock_schema_loader.dart';
import '../../../core/odoo/odoo_record_reader.dart';
import '../domain/lead.dart';
import '../domain/lead_detail_view_data.dart';
import '../domain/lead_list_item.dart';
import '../domain/lead_update_input.dart';

class LeadRepository {
  LeadRepository(
    this._rpc,
    this._schemaService,
    this._recordReader,
    this._mockLoader,
    this._mobileUiConfig,
    this._sessionStore,
  );

  final OdooJsonRpcClient _rpc;
  final OdooFormSchemaService _schemaService;
  final OdooRecordReader _recordReader;
  final OdooMockSchemaLoader _mockLoader;
  final MobileUiConfigService _mobileUiConfig;
  final OdooSessionStore _sessionStore;

  static const crmLeadModel = 'crm.lead';

  /// Persists mock edits in memory for the current session.
  static final _mockOverrides = <int, Lead>{};

  static const _listFields = <String>[
    'id',
    'name',
    'partner_name',
    'contact_name',
    'phone',
    'email_from',
    'user_id',
    'stage_id',
    'source_id',
    'create_date',
  ];

  Future<List<LeadListItem>> fetchLeads({
    LeadStage? stage,
    String? query,
  }) {
    if (AppConfig.useRealApi) {
      return _fetchRemote(stage: stage, query: query);
    }
    return _fetchMock(stage: stage, query: query);
  }

  Future<MobileUiLayoutSchema> loadListLayout() => _loadMobileLayout('list');

  Future<MobileUiLayoutSchema> loadFormLayout() => _loadMobileLayout('form');

  Future<Lead> fetchLeadById(int id) async {
    final view = await fetchLeadDetailViewData(id);
    return view.summary;
  }

  Future<LeadDetailViewData> fetchLeadDetailViewData(
    int id, {
    String otherInfoTitle = 'Other Information',
  }) async {
    if (AppConfig.useRealApi) {
      return _fetchDetailViewRemote(id, otherInfoTitle: otherInfoTitle);
    }
    return _fetchDetailViewMock(id, otherInfoTitle: otherInfoTitle);
  }

  /// Edit screen: read Odoo values using **form** layout fields (not detail).
  Future<LeadDetailViewData> fetchLeadEditViewData(
    int id, {
    String otherInfoTitle = 'Other Information',
  }) async {
    if (AppConfig.useRealApi) {
      return _fetchEditViewRemote(id, otherInfoTitle: otherInfoTitle);
    }
    return _fetchEditViewMock(id, otherInfoTitle: otherInfoTitle);
  }

  Future<LeadDetailViewData> _fetchEditViewRemote(
    int id, {
    required String otherInfoTitle,
  }) async {
    final formLayout = await loadFormLayout();
    final fieldNames = formLayout.isConfigured
        ? formLayout.fieldNames
        : (await _resolveDetailSchema(
            fallbackOtherInfoTitle: otherInfoTitle,
          ))
            .readableFieldNames;
    final values = await _recordReader.read(
      model: crmLeadModel,
      id: id,
      fieldNames: fieldNames,
    );
    MobileUiDebugLog.detailValues(
      leadId: id,
      values: values,
      expectedFields: fieldNames,
    );
    final schema = formLayout.isConfigured
        ? MobileUiSchemaMapper.toOdooFormSchema(formLayout)
        : await _resolveDetailSchema(fallbackOtherInfoTitle: otherInfoTitle);
    return LeadDetailViewData(
      summary: Lead.fromOdoo(values),
      schema: schema,
      values: values,
    );
  }

  Future<LeadDetailViewData> _fetchEditViewMock(
    int id, {
    required String otherInfoTitle,
  }) async {
    final formLayout = await loadFormLayout();
    final schema = formLayout.isConfigured
        ? MobileUiSchemaMapper.toOdooFormSchema(formLayout)
        : await _resolveDetailSchema(fallbackOtherInfoTitle: otherInfoTitle);
    final values = await _mockLoader.loadRecordValues(id: id);
    final merged = {...values};
    final override = _mockOverrides[id];
    if (override != null) {
      merged.addAll(_leadToOdooMap(override));
    }
    return LeadDetailViewData(
      summary: Lead.fromOdoo(merged),
      schema: schema,
      values: merged,
    );
  }

  Future<LeadDetailViewData> _fetchDetailViewRemote(
    int id, {
    required String otherInfoTitle,
  }) async {
    final schema = await _resolveDetailSchema(
      fallbackOtherInfoTitle: otherInfoTitle,
    );
    final fieldNames = schema.readableFieldNames;
    final values = await _recordReader.read(
      model: crmLeadModel,
      id: id,
      fieldNames: fieldNames,
    );
    MobileUiDebugLog.detailValues(
      leadId: id,
      values: values,
      expectedFields: fieldNames,
    );
    return LeadDetailViewData(
      summary: Lead.fromOdoo(values),
      schema: schema,
      values: values,
    );
  }

  /// Detail screen schema: Odoo `crm_mobile_ui` layout, else `get_views` XML.
  Future<OdooFormSchema> _resolveDetailSchema({
    String fallbackOtherInfoTitle = 'Other Information',
  }) async {
    final layout = await _loadMobileLayout('detail');
    if (AppConfig.useMobileUiConfig && layout.isConfigured) {
      final schema = MobileUiSchemaMapper.toOdooFormSchema(layout);
      _logResolvedSchema('detail', 'mobile_ui_config', schema);
      return schema;
    }
    if (AppConfig.useMobileUiConfig &&
        !AppConfig.mobileUiFallbackToFormXml) {
      final schema = MobileUiSchemaMapper.toOdooFormSchema(layout);
      _logResolvedSchema('detail', 'mobile_ui_config(empty)', schema);
      return schema;
    }
    final schema = await _schemaService.loadFormSchema(
      model: crmLeadModel,
      otherInfoTitle: layout.otherInfoTitle.isNotEmpty
          ? layout.otherInfoTitle
          : fallbackOtherInfoTitle,
    );
    _logResolvedSchema('detail', 'get_views_xml_fallback', schema);
    return schema;
  }

  void _logResolvedSchema(String screen, String source, OdooFormSchema schema) {
    MobileUiDebugLog.schemaResolved(
      screen: screen,
      source: source,
      fieldNames: schema.readableFieldNames,
      groupTitles: schema.displayGroups.map((g) => g.title).toList(),
    );
  }

  Future<MobileUiLayoutSchema> _loadMobileLayout(String screen) {
    return _mobileUiConfig.loadLayout(
      model: crmLeadModel,
      screen: screen,
      companyId: _sessionStore.current.companyId,
    );
  }

  Future<LeadDetailViewData> _fetchDetailViewMock(
    int id, {
    required String otherInfoTitle,
  }) async {
    final schema = await _resolveDetailSchema(
      fallbackOtherInfoTitle: otherInfoTitle,
    );
    final values = await _mockLoader.loadRecordValues(id: id);
    final merged = {...values};
    final override = _mockOverrides[id];
    if (override != null) {
      merged.addAll(_leadToOdooMap(override));
    }
    return LeadDetailViewData(
      summary: Lead.fromOdoo(merged),
      schema: schema,
      values: merged,
    );
  }

  Map<String, dynamic> _leadToOdooMap(Lead lead) => {
        'id': lead.id,
        'name': lead.title ?? lead.customerName,
        'partner_name': lead.customerName,
        'phone': lead.phone,
        'email_from': lead.email,
        'user_id': lead.salesperson.isEmpty ? false : [0, lead.salesperson],
        'stage_id': [0, _stageOdooName(lead.stage)],
        'source_id': lead.source.isEmpty ? false : [0, lead.source],
        'description': lead.note ?? false,
        'mobile': lead.mobile ?? false,
        'website': lead.website ?? false,
        'function': lead.jobPosition ?? false,
        'street': lead.street ?? false,
        'city': lead.city ?? false,
        'expected_revenue': lead.expectedRevenue ?? 0.0,
        'probability': lead.probability ?? 0.0,
        'priority': _priorityToOdoo(lead.priority),
        'date_deadline': lead.dateDeadline?.toIso8601String().split('T').first,
      };

  String _priorityToOdoo(LeadPriority priority) => switch (priority) {
        LeadPriority.low => '0',
        LeadPriority.normal => '1',
        LeadPriority.high => '2',
        LeadPriority.veryHigh => '3',
      };

  Future<Lead> updateLead({
    required int id,
    required LeadUpdateInput input,
  }) {
    if (AppConfig.useRealApi) {
      return _updateRemote(id: id, input: input);
    }
    return _updateMock(id: id, input: input);
  }

  Future<Lead> updateLeadFromValues({
    required int id,
    required Map<String, dynamic> formValues,
  }) async {
    if (AppConfig.useRealApi) {
      final values = await buildWriteValuesFromMap(formValues);
      await _rpc.callKw(
        model: crmLeadModel,
        method: 'write',
        args: [
          [id],
          values,
        ],
      );
      final view = await fetchLeadDetailViewData(id);
      return view.summary;
    }
    return _updateMockFromValues(id: id, formValues: formValues);
  }

  Future<List<({int id, String name})>> fetchLeadStages() async {
    if (!AppConfig.useRealApi) {
      return [
        (id: 1, name: 'New'),
        (id: 2, name: 'Qualified'),
        (id: 3, name: 'Proposition'),
        (id: 4, name: 'Won'),
        (id: 5, name: 'Lost'),
      ];
    }
    final rows = await _rpc.callKw(
      model: 'crm.stage',
      method: 'search_read',
      args: [[]],
      kwargs: {
        'fields': ['id', 'name'],
        'order': 'sequence asc, id asc',
      },
    );
    if (rows is! List) return [];
    return [
      for (final row in rows)
        if (row is Map<String, dynamic>)
          (
            id: row['id'] as int,
            name: row['name']?.toString() ?? '',
          ),
    ];
  }

  Future<List<LeadListItem>> _fetchRemote({
    LeadStage? stage,
    String? query,
  }) async {
    final domain = <dynamic>[];
    if (query != null && query.isNotEmpty) {
      domain.addAll([
        '|',
        ['name', 'ilike', query],
        ['partner_name', 'ilike', query],
      ]);
    }
    if (stage != null) {
      domain.add(['stage_id.name', 'ilike', _stageOdooName(stage)]);
    }

    final listLayout = await _loadMobileLayout('list');
    final fields = listLayout.isConfigured
        ? listLayout.fieldNames
        : _listFields;
    MobileUiDebugLog.schemaResolved(
      screen: 'list',
      source: listLayout.isConfigured ? 'mobile_ui_config' : 'hardcoded_list_fields',
      fieldNames: fields,
      groupTitles: listLayout.sections.map((s) => s.title).toList(),
    );

    final rows = await _rpc.callKw(
      model: 'crm.lead',
      method: 'search_read',
      args: [domain],
      kwargs: {
        'fields': fields,
        'limit': 100,
        'order': 'create_date desc',
      },
    );

    if (rows is! List) return [];

    return rows.map((e) {
      final map = Map<String, dynamic>.from(e as Map);
      return LeadListItem(lead: Lead.fromOdoo(map), values: map);
    }).toList();
  }

  String _stageOdooName(LeadStage stage) => switch (stage) {
        LeadStage.newLead => 'New',
        LeadStage.qualified => 'Qualified',
        LeadStage.proposition => 'Proposition',
        LeadStage.won => 'Won',
        LeadStage.lost => 'Lost',
      };

  Future<Lead> _updateRemote({
    required int id,
    required LeadUpdateInput input,
  }) async {
    final values = await buildWriteValuesFromInput(input);

    await _rpc.callKw(
      model: 'crm.lead',
      method: 'write',
      args: [
        [id],
        values,
      ],
    );

    final view = await fetchLeadDetailViewData(id);
    return view.summary;
  }

  /// Build Odoo write dict from form layout + dynamic form values.
  Future<Map<String, dynamic>> buildWriteValuesFromMap(
    Map<String, dynamic> formValues,
  ) async {
    if (AppConfig.useMobileUiConfig) {
      final layout = await _loadMobileLayout('form');
      if (layout.isConfigured) {
        return _writeValuesFromMobileMap(layout, formValues);
      }
    }
    return Map<String, dynamic>.from(formValues);
  }

  /// Build Odoo write dict from form layout + submitted values.
  Future<Map<String, dynamic>> buildWriteValuesFromInput(
    LeadUpdateInput input,
  ) async {
    if (AppConfig.useMobileUiConfig) {
      final layout = await _loadMobileLayout('form');
      if (layout.isConfigured) {
        return _writeValuesFromMobileInput(layout, input);
      }
    }
    return _writeValuesFromLegacyInput(input);
  }

  Map<String, dynamic> _writeValuesFromMobileInput(
    MobileUiLayoutSchema layout,
    LeadUpdateInput input,
  ) =>
      _writeValuesFromMobileMap(layout, _flattenInput(input));

  Map<String, dynamic> _writeValuesFromMobileMap(
    MobileUiLayoutSchema layout,
    Map<String, dynamic> formValues,
  ) {
    final values = <String, dynamic>{};

    for (final section in layout.sections) {
      for (final field in section.fields) {
        if (field.readonly) continue;
        if (field.type == 'many2many' || field.type == 'one2many') continue;
        if (!formValues.containsKey(field.name)) continue;
        values[field.name] =
            MobileUiWriteCoercer.coerce(field, formValues[field.name]);
      }
    }
    return values;
  }

  Map<String, dynamic> _flattenInput(LeadUpdateInput input) => {
        'name': input.title,
        'partner_name': input.customerName,
        'phone': input.phone,
        'email_from': input.email,
        'mobile': input.mobile,
        'website': input.website,
        'function': input.jobPosition,
        'street': input.street,
        'city': input.city,
        'description': input.note,
        'expected_revenue': input.expectedRevenue,
        'probability': input.probability,
        'priority': _priorityOdooValue(input.priority),
        'date_deadline': input.dateDeadline?.toIso8601String().split('T').first,
      };

  Future<Map<String, dynamic>> _writeValuesFromLegacyInput(
    LeadUpdateInput input,
  ) async {
    final values = <String, dynamic>{
      'partner_name': input.customerName,
      'phone': input.phone,
      'email_from': input.email ?? false,
      'mobile': input.mobile ?? false,
      'website': input.website ?? false,
      'function': input.jobPosition ?? false,
      'street': input.street ?? false,
      'city': input.city ?? false,
      'description': input.note ?? false,
      'expected_revenue': input.expectedRevenue ?? 0.0,
      'probability': input.probability ?? 0.0,
      'priority': _priorityOdooValue(input.priority),
    };

    if (input.title != null && input.title!.trim().isNotEmpty) {
      values['name'] = input.title!.trim();
    }

    if (input.dateDeadline != null) {
      values['date_deadline'] =
          input.dateDeadline!.toIso8601String().split('T').first;
    } else {
      values['date_deadline'] = false;
    }

    if (input.stage != null) {
      final stageId = await _resolveStageId(input.stage!);
      if (stageId != null) {
        values['stage_id'] = stageId;
      }
    }
    return values;
  }

  Future<Lead> _updateMockFromValues({
    required int id,
    required Map<String, dynamic> formValues,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final current = await fetchLeadById(id);
    final updated = Lead.fromOdoo({
      ..._leadToOdooMap(current),
      ...formValues,
      'id': id,
    });
    _mockOverrides[id] = updated;
    return updated;
  }

  Future<Lead> _updateMock({
    required int id,
    required LeadUpdateInput input,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final current = await fetchLeadById(id);
    final updated = current.copyWith(
      title: input.title?.trim().isNotEmpty == true
          ? input.title!.trim()
          : current.title,
      customerName: input.customerName,
      phone: input.phone,
      email: input.email ?? '',
      mobile: input.mobile,
      website: input.website,
      jobPosition: input.jobPosition,
      companyName: input.companyName,
      street: input.street,
      city: input.city,
      source: input.source ?? current.source,
      note: input.note,
      stage: input.stage ?? current.stage,
      priority: input.priority,
      expectedRevenue: input.expectedRevenue,
      probability: input.probability,
      dateDeadline: input.dateDeadline,
      lastUpdated: DateTime.now(),
    );
    _mockOverrides[id] = updated;
    return updated;
  }

  Future<int?> _resolveStageId(LeadStage stage) async {
    final rows = await _rpc.callKw(
      model: 'crm.stage',
      method: 'search_read',
      args: [
        [
          ['name', 'ilike', _stageOdooName(stage)],
        ],
      ],
      kwargs: {
        'fields': ['id'],
        'limit': 1,
      },
    );
    if (rows is! List || rows.isEmpty) return null;
    return (rows.first as Map<String, dynamic>)['id'] as int?;
  }

  String _priorityOdooValue(LeadPriority priority) => switch (priority) {
        LeadPriority.low => '0',
        LeadPriority.normal => '1',
        LeadPriority.high => '2',
        LeadPriority.veryHigh => '3',
      };

  Future<List<LeadListItem>> _fetchMock({
    LeadStage? stage,
    String? query,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));

    final all = [
      Lead(
        id: 1,
        customerName: 'Nguyen Van A',
        phone: '+84 901 234 567',
        email: 'nguyenvana@email.com',
        salesperson: 'John Smith',
        stage: LeadStage.newLead,
        source: 'Website',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Lead(
        id: 2,
        customerName: 'Tran Thi B',
        phone: '+84 902 345 678',
        email: 'tranthib@email.com',
        salesperson: 'Jane Doe',
        stage: LeadStage.qualified,
        source: 'Referral',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      Lead(
        id: 3,
        customerName: 'Le Van C',
        phone: '+84 903 456 789',
        email: 'levanc@email.com',
        salesperson: 'John Smith',
        stage: LeadStage.proposition,
        source: 'Trade Show',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Lead(
        id: 4,
        customerName: 'Pham Thi D',
        phone: '+84 904 567 890',
        email: 'phamthid@email.com',
        salesperson: 'Jane Doe',
        stage: LeadStage.won,
        source: 'Cold Call',
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
      Lead(
        id: 5,
        customerName: 'Hoang Van E',
        phone: '+84 905 678 901',
        email: 'hoangvane@email.com',
        salesperson: 'John Smith',
        stage: LeadStage.lost,
        source: 'Social Media',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      Lead(
        id: 6,
        customerName: 'Vo Thi F',
        phone: '+84 906 789 012',
        email: 'vothif@email.com',
        salesperson: 'Jane Doe',
        stage: LeadStage.newLead,
        source: 'Website',
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
      ),
    ];

    var filtered = all;
    if (stage != null) {
      filtered = filtered.where((l) => l.stage == stage).toList();
    }
    if (query != null && query.isNotEmpty) {
      final q = query.toLowerCase();
      filtered = filtered
          .where(
            (l) =>
                l.customerName.toLowerCase().contains(q) ||
                l.phone.contains(q) ||
                l.salesperson.toLowerCase().contains(q),
          )
          .toList();
    }
    return filtered.map((l) {
      final lead = _mockOverrides[l.id] ?? l;
      return LeadListItem(lead: lead, values: _leadToOdooMap(lead));
    }).toList();
  }
}

final leadRepositoryProvider = Provider<LeadRepository>((ref) {
  final rpc = ref.watch(odooJsonRpcClientProvider);
  return LeadRepository(
    rpc,
    ref.watch(odooFormSchemaServiceProvider),
    OdooRecordReader(rpc),
    ref.watch(odooMockSchemaLoaderProvider),
    ref.watch(mobileUiConfigServiceProvider),
    ref.watch(odooSessionStoreProvider),
  );
});
