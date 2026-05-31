import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/constants/app_config.dart';
import '../../../app/constants/app_sizes.dart';
import '../../../core/mobile_ui/mobile_ui_debug_log.dart';
import '../../../core/mobile_ui/mobile_ui_form_builder.dart';
import '../../../core/mobile_ui/mobile_ui_form_context.dart';
import '../../../core/mobile_ui/mobile_ui_schema.dart';
import '../../../core/odoo/odoo_relation_search_service.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../l10n/app_localizations.dart';
import '../../lead/data/lead_repository.dart';
import '../application/create_lead_controller.dart';

class CreateLeadScreen extends ConsumerStatefulWidget {
  const CreateLeadScreen({super.key});

  @override
  ConsumerState<CreateLeadScreen> createState() => _CreateLeadScreenState();
}

class _CreateLeadScreenState extends ConsumerState<CreateLeadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _controllers = <String, TextEditingController>{};

  MobileUiLayoutSchema? _createLayout;
  final Map<String, dynamic> _formValues = {};
  List<({int id, String name})> _stageOptions = [];
  List<({int id, String name})> _tagOptions = [];
  bool _layoutReady = false;
  bool _useMobileForm = false;
  bool _defaultsApplied = false;

  // Legacy fallback
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _noteController = TextEditingController();
  String _source = 'Website';

  static const _sources = [
    'Website',
    'Referral',
    'Trade Show',
    'Cold Call',
    'Social Media',
  ];

  @override
  void initState() {
    super.initState();
    _loadCreateLayout();
  }

  Future<void> _loadCreateLayout() async {
    final repo = ref.read(leadRepositoryProvider);
    final layout = await repo.loadCreateLayout();
    final sections = layout.sections
        .map(
          (s) => MobileUiSectionSummary(
            key: s.key,
            title: s.title,
            fieldNames: s.fields.map((f) => f.name).toList(),
          ),
        )
        .toList();
    var fieldCount = 0;
    for (final s in sections) {
      fieldCount += s.fieldNames.length;
    }
    MobileUiDebugLog.layoutLoaded(
      model: 'crm.lead',
      screen: 'create',
      companyId: null,
      fromCache: false,
      useRealApi: AppConfig.useRealApi,
      summary: MobileUiLayoutSummary(
        version: layout.version,
        isConfigured: layout.isConfigured,
        sectionCount: layout.sections.length,
        fieldCount: fieldCount,
        sections: sections,
      ),
    );
    final stages = await repo.fetchLeadStages();
    final tags = await repo.fetchCrmTags();
    if (!mounted) return;
    setState(() {
      _createLayout = layout.isConfigured ? layout : null;
      _useMobileForm = layout.isConfigured;
      _stageOptions = stages;
      _tagOptions = tags;
      _layoutReady = true;
    });
  }

  void _applyCreateDefaults(MobileUiLayoutSchema layout) {
    if (_defaultsApplied) return;
    _defaultsApplied = true;

    if (layout.hasField('priority') && !_formValues.containsKey('priority')) {
      _formValues['priority'] = '1';
    }
    if (layout.hasField('type') && !_formValues.containsKey('type')) {
      _formValues['type'] = 'lead';
    }
    if (layout.hasField('stage_id') &&
        !_formValues.containsKey('stage_id') &&
        _stageOptions.isNotEmpty) {
      final first = _stageOptions.first;
      _formValues['stage_id'] = [first.id, first.name];
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    final lead = _useMobileForm && _createLayout != null
        ? await ref.read(createLeadControllerProvider.notifier).saveValues(
              formValues: Map<String, dynamic>.from(_formValues),
            )
        : await _saveLegacy();

    if (!mounted) return;

    if (lead != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.leadSaved),
        ),
      );
      context.pop();
      return;
    }

    final error = ref.read(createLeadControllerProvider).error;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    }
  }

  Future<dynamic> _saveLegacy() async {
    final values = <String, dynamic>{
      'partner_name': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'email_from': _emailController.text.trim(),
      'description': _noteController.text.trim().isEmpty
          ? false
          : _noteController.text.trim(),
    };
    return ref.read(createLeadControllerProvider.notifier).saveValues(
          formValues: values,
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final saveState = ref.watch(createLeadControllerProvider);

    if (!_layoutReady) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.createLead)),
        body: LoadingView(message: l10n.loading),
      );
    }

    if (_useMobileForm && _createLayout != null) {
      _applyCreateDefaults(_createLayout!);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.createLead),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: saveState.isSaving ? null : () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: saveState.isSaving ? null : _onSave,
            child: Text(l10n.save),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_useMobileForm && _createLayout != null)
                MobileUiFormBuilder(
                  layout: _createLayout!,
                  initialValues: _formValues,
                  controllers: _controllers,
                  formContext: MobileUiFormContext(
                    searchMany2one: (field, query) {
                      final relation = field.relation;
                      if (relation == null || relation.isEmpty) {
                        return Future.value([]);
                      }
                      return ref
                          .read(odooRelationSearchServiceProvider)
                          .search(relation: relation, query: query);
                    },
                    staticMany2oneOptions: {
                      'stage_id': _stageOptions,
                    },
                    tagOptions: _tagOptions,
                  ),
                  onChanged: () => setState(() {}),
                )
              else
                ..._legacyFormFields(l10n),
              const SizedBox(height: AppSizes.xl),
              PrimaryButton(
                label: l10n.save,
                isLoading: saveState.isSaving,
                onPressed: _onSave,
              ),
              const SizedBox(height: AppSizes.md),
              OutlinedButton(
                onPressed: saveState.isSaving ? null : () => context.pop(),
                child: Text(l10n.cancel),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _legacyFormFields(AppLocalizations l10n) => [
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(labelText: l10n.customerName),
          validator: (v) => Validators.required(v, field: l10n.customerName),
        ),
        const SizedBox(height: AppSizes.md),
        TextFormField(
          controller: _phoneController,
          decoration: InputDecoration(labelText: l10n.phone),
          keyboardType: TextInputType.phone,
          validator: (v) => Validators.required(v, field: l10n.phone),
        ),
        const SizedBox(height: AppSizes.md),
        TextFormField(
          controller: _emailController,
          decoration: InputDecoration(labelText: l10n.email),
          keyboardType: TextInputType.emailAddress,
          validator: Validators.email,
        ),
        const SizedBox(height: AppSizes.md),
        DropdownButtonFormField<String>(
          initialValue: _source,
          decoration: InputDecoration(labelText: l10n.source),
          items: _sources
              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
              .toList(),
          onChanged: (v) => setState(() => _source = v ?? _source),
        ),
        const SizedBox(height: AppSizes.md),
        TextFormField(
          controller: _noteController,
          decoration: InputDecoration(labelText: l10n.note),
          maxLines: 4,
        ),
      ];
}
