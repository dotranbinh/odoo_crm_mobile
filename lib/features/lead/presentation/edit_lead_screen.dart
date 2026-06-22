import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/constants/app_config.dart';
import '../../../app/constants/app_sizes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/mobile_ui/mobile_ui_debug_log.dart';
import '../../../core/mobile_ui/mobile_ui_form_builder.dart';
import '../../../core/mobile_ui/mobile_ui_form_context.dart';
import '../../../core/mobile_ui/mobile_ui_schema.dart';
import '../../../core/odoo/odoo_relation_search_service.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../l10n/app_localizations.dart';
import '../application/edit_lead_controller.dart';
import '../application/edit_lead_view_controller.dart';
import '../data/lead_repository.dart';
import '../domain/lead.dart';
import '../domain/lead_update_input.dart';
import 'widgets/lead_stage_badge.dart';

class EditLeadScreen extends ConsumerStatefulWidget {
  const EditLeadScreen({required this.leadId, super.key});

  final int leadId;

  @override
  ConsumerState<EditLeadScreen> createState() => _EditLeadScreenState();
}

class _EditLeadScreenState extends ConsumerState<EditLeadScreen> {
  final _formKey = GlobalKey<FormState>();
  final _controllers = <String, TextEditingController>{};

  MobileUiLayoutSchema? _formLayout;
  Map<String, dynamic> _formValues = {};
  List<({int id, String name})> _stageOptions = [];
  List<({int id, String name})> _tagOptions = [];
  bool _layoutReady = false;
  bool _useMobileForm = false;

  // Legacy fallback controllers
  final _titleController = TextEditingController();
  final _nameController = TextEditingController();
  final _companyController = TextEditingController();
  final _phoneController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _websiteController = TextEditingController();
  final _jobController = TextEditingController();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _revenueController = TextEditingController();
  final _probabilityController = TextEditingController();
  final _noteController = TextEditingController();

  LeadStage _stage = LeadStage.newLead;
  LeadPriority _priority = LeadPriority.normal;
  String _source = 'Website';
  DateTime? _deadline;
  bool _legacyPopulated = false;

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
    _loadFormLayout();
  }

  Future<void> _loadFormLayout() async {
    final repo = ref.read(leadRepositoryProvider);
    final layout = await repo.loadFormLayout();
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
      screen: 'form',
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
      _formLayout = layout.isConfigured ? layout : null;
      _useMobileForm = layout.isConfigured;
      _stageOptions = stages;
      _tagOptions = tags;
      _layoutReady = true;
    });
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    _titleController.dispose();
    _nameController.dispose();
    _companyController.dispose();
    _phoneController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    _jobController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _revenueController.dispose();
    _probabilityController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _populateMobileForm(Map<String, dynamic> values) {
    _formValues = Map<String, dynamic>.from(values);
    for (final c in _controllers.values) {
      c.dispose();
    }
    _controllers.clear();
  }

  void _populateLegacy(Lead lead) {
    if (_legacyPopulated) return;
    _legacyPopulated = true;
    _titleController.text = lead.title ?? '';
    _nameController.text = lead.customerName;
    _companyController.text = lead.companyName ?? '';
    _phoneController.text = lead.phone;
    _mobileController.text = lead.mobile ?? '';
    _emailController.text = lead.email;
    _websiteController.text = lead.website ?? '';
    _jobController.text = lead.jobPosition ?? '';
    _streetController.text = lead.street ?? '';
    _cityController.text = lead.city ?? '';
    _revenueController.text =
        lead.expectedRevenue != null ? lead.expectedRevenue!.toStringAsFixed(0) : '';
    _probabilityController.text =
        lead.probability != null ? lead.probability!.toStringAsFixed(0) : '';
    _noteController.text = lead.note ?? '';
    _stage = lead.stage;
    _priority = lead.priority;
    _deadline = lead.dateDeadline;
    if (lead.source.isNotEmpty && _sources.contains(lead.source)) {
      _source = lead.source;
    }
  }

  LeadUpdateInput _buildLegacyInput() {
    final revenue = double.tryParse(_revenueController.text.trim());
    final probability = double.tryParse(_probabilityController.text.trim());

    return LeadUpdateInput(
      title: _titleController.text.trim(),
      customerName: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      mobile: _mobileController.text.trim().isEmpty
          ? null
          : _mobileController.text.trim(),
      website: _websiteController.text.trim().isEmpty
          ? null
          : _websiteController.text.trim(),
      jobPosition:
          _jobController.text.trim().isEmpty ? null : _jobController.text.trim(),
      companyName: _companyController.text.trim().isEmpty
          ? null
          : _companyController.text.trim(),
      street: _streetController.text.trim().isEmpty
          ? null
          : _streetController.text.trim(),
      city: _cityController.text.trim().isEmpty
          ? null
          : _cityController.text.trim(),
      source: _source,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
      stage: _stage,
      priority: _priority,
      expectedRevenue: revenue,
      probability: probability,
      dateDeadline: _deadline,
    );
  }

  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _deadline = picked);
    }
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    final notifier = ref.read(editLeadControllerProvider.notifier);
    final bool success;

    if (_useMobileForm && _formLayout != null) {
      success = await notifier.saveValues(
        leadId: widget.leadId,
        formValues: Map<String, dynamic>.from(_formValues),
      );
    } else {
      success = await notifier.save(
        leadId: widget.leadId,
        input: _buildLegacyInput(),
      );
    }

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.leadUpdated),
        ),
      );
      context.pop(true);
      return;
    }

    final error = ref.read(editLeadControllerProvider).error;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final asyncLead = ref.watch(editLeadViewControllerProvider(widget.leadId));
    final saveState = ref.watch(editLeadControllerProvider);

    if (!_layoutReady) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.editLead)),
        body: LoadingView(message: l10n.loading),
      );
    }

    return asyncLead.when(
      loading: () => Scaffold(
        appBar: AppBar(title: Text(l10n.editLead)),
        body: LoadingView(message: l10n.loading),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: Text(l10n.editLead)),
        body: ErrorView(
          message: e.toString(),
          onRetry: () => ref
              .read(editLeadViewControllerProvider(widget.leadId).notifier)
              .refresh(),
        ),
      ),
      data: (view) {
        if (_useMobileForm) {
          if (_formValues.isEmpty) {
            _populateMobileForm(view.values);
          }
        } else {
          _populateLegacy(view.summary);
        }
        return _buildScaffold(context, l10n, saveState.isSaving);
      },
    );
  }

  Widget _buildScaffold(
    BuildContext context,
    AppLocalizations l10n,
    bool isSaving,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.editLead),
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: l10n.cancel,
          onPressed: isSaving ? null : () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.screenPaddingH,
          AppSizes.md,
          AppSizes.screenPaddingH,
          AppSizes.xl,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_useMobileForm && _formLayout != null)
                MobileUiFormBuilder(
                  layout: _formLayout!,
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
                isLoading: isSaving,
                onPressed: _onSave,
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _legacyFormFields(AppLocalizations l10n) => [
        _SectionLabel(l10n.contactInfo),
        TextFormField(
          controller: _titleController,
          decoration: InputDecoration(labelText: l10n.leadTitle),
        ),
        const SizedBox(height: AppSizes.md),
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(labelText: l10n.customerName),
          validator: (v) => Validators.required(v, field: l10n.customerName),
        ),
        const SizedBox(height: AppSizes.md),
        TextFormField(
          controller: _companyController,
          decoration: InputDecoration(labelText: l10n.company),
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
          controller: _mobileController,
          decoration: InputDecoration(labelText: l10n.mobile),
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: AppSizes.md),
        TextFormField(
          controller: _emailController,
          decoration: InputDecoration(labelText: l10n.email),
          keyboardType: TextInputType.emailAddress,
          validator: Validators.email,
        ),
        const SizedBox(height: AppSizes.md),
        TextFormField(
          controller: _websiteController,
          decoration: InputDecoration(labelText: l10n.website),
          keyboardType: TextInputType.url,
        ),
        const SizedBox(height: AppSizes.md),
        TextFormField(
          controller: _jobController,
          decoration: InputDecoration(labelText: l10n.jobPosition),
        ),
        const SizedBox(height: AppSizes.md),
        TextFormField(
          controller: _streetController,
          decoration: InputDecoration(labelText: l10n.address),
        ),
        const SizedBox(height: AppSizes.md),
        TextFormField(
          controller: _cityController,
          decoration: InputDecoration(labelText: l10n.city),
        ),
        const SizedBox(height: AppSizes.lg),
        _SectionLabel(l10n.salesInfo),
        DropdownButtonFormField<LeadStage>(
          initialValue: _stage,
          decoration: InputDecoration(labelText: l10n.stage),
          items: LeadStage.values
              .map(
                (s) => DropdownMenuItem(
                  value: s,
                  child: Text(LeadStageBadge.labelFor(s)),
                ),
              )
              .toList(),
          onChanged: (v) => setState(() => _stage = v ?? _stage),
        ),
        const SizedBox(height: AppSizes.md),
        DropdownButtonFormField<LeadPriority>(
          initialValue: _priority,
          decoration: InputDecoration(labelText: l10n.priority),
          items: LeadPriority.values
              .map(
                (p) => DropdownMenuItem(
                  value: p,
                  child: Text(_priorityLabel(l10n, p)),
                ),
              )
              .toList(),
          onChanged: (v) => setState(() => _priority = v ?? _priority),
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
          controller: _revenueController,
          decoration: InputDecoration(labelText: l10n.expectedRevenue),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: AppSizes.md),
        TextFormField(
          controller: _probabilityController,
          decoration: InputDecoration(labelText: l10n.probability),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: AppSizes.md),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.deadline),
          subtitle: Text(
            _deadline != null
                ? AppFormatters.date(_deadline!)
                : l10n.selectDate,
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_deadline != null)
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => setState(() => _deadline = null),
                ),
              IconButton(
                icon: const Icon(Icons.calendar_today_outlined),
                onPressed: _pickDeadline,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.md),
        TextFormField(
          controller: _noteController,
          decoration: InputDecoration(labelText: l10n.note),
          maxLines: 4,
        ),
      ];

  String _priorityLabel(AppLocalizations l10n, LeadPriority p) => switch (p) {
        LeadPriority.low => l10n.priorityLow,
        LeadPriority.normal => l10n.priorityNormal,
        LeadPriority.high => l10n.priorityHigh,
        LeadPriority.veryHigh => l10n.priorityVeryHigh,
      };
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.sm),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
              letterSpacing: 0,
            ),
      ),
    );
  }
}
