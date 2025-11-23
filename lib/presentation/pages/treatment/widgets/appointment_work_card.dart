import 'dart:async';

import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/models/work/appointment_work_model.dart';
import 'package:dent_app_mobile/presentation/pages/treatment/content/diagnosis_selection_sheet.dart';
import 'package:dent_app_mobile/presentation/pages/treatment/content/services_selection_sheet.dart';
import 'package:dent_app_mobile/presentation/pages/treatment/content/tooth_condition_info_widget.dart';
import 'package:dent_app_mobile/presentation/pages/treatment/core/bloc/pattern/pattern_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/treatment/core/data/pattern_type.dart';
import 'package:dent_app_mobile/presentation/pages/treatment/utils/pattern_utils.dart';
import 'package:dent_app_mobile/presentation/pages/treatment/utils/treatment_form_controller.dart';
import 'package:dent_app_mobile/presentation/pages/treatment/widgets/expandable_text_field_widget.dart';
import 'package:dent_app_mobile/presentation/pages/treatment/widgets/pattern_selection_bottom_sheet.dart';
import 'package:dent_app_mobile/presentation/widgets/text/app_text.dart';
import 'package:dent_app_mobile/presentation/widgets/text/price_convert_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class AppointmentWorkCard extends StatefulWidget {
  final AppointmentWorkModel work;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final Function(AppointmentWorkModel updatedWork)? onSave;

  const AppointmentWorkCard({
    super.key,
    required this.work,
    this.onEdit,
    this.onDelete,
    this.onSave,
  });

  @override
  State<AppointmentWorkCard> createState() => _AppointmentWorkCardState();
}

class _AppointmentWorkCardState extends State<AppointmentWorkCard>
    with AutomaticKeepAliveClientMixin {
  late final TreatmentFormController _treatmentFormController;
  late final PatternCubit _patternCubit;

  late List<DiagnosesResponse> _currentDiagnoses;
  late List<ServiceResponse> _currentServices;

  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _treatmentFormController = TreatmentFormController();
    _patternCubit = PatternCubit();

    _initializeData();
    _initializeFormController();
  }

  void _initializeData() {
    _currentDiagnoses = List.from(widget.work.diagnosesResponse ?? []);
    _currentServices = List.from(widget.work.serviceResponses ?? []);
  }

  @override
  void didUpdateWidget(AppointmentWorkCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.work.workId != widget.work.workId) {
      _initializeData();
      _updateControllersFromModel();
      _checkChanges();
    }
  }

  @override
  void dispose() {
    _treatmentFormController.dispose();
    _patternCubit.close();
    super.dispose();
  }

  void _initializeFormController() {
    _updateControllersFromModel();

    _treatmentFormController.surveyPlanController.addListener(_checkChanges);
    _treatmentFormController.recommendationController.addListener(
      _checkChanges,
    );
    _treatmentFormController.treatmentController.addListener(_checkChanges);

    _treatmentFormController.setupFocusNodeListeners(_onFocusChanged);
  }

  void _updateControllersFromModel() {
    _treatmentFormController.surveyPlanController.text =
        widget.work.surveyPlan ?? '';
    _treatmentFormController.recommendationController.text =
        widget.work.recommendations ?? '';
    _treatmentFormController.treatmentController.text =
        widget.work.treatment ?? '';
  }

  /// Degisiklik var mi kontrol eder
  void _checkChanges() {
    bool textChanged =
        _treatmentFormController.surveyPlanController.text !=
            (widget.work.surveyPlan ?? '') ||
        _treatmentFormController.recommendationController.text !=
            (widget.work.recommendations ?? '') ||
        _treatmentFormController.treatmentController.text !=
            (widget.work.treatment ?? '');

    // Diagnosis listesi karsilastirmasi (Basitce ID ve uzunluk kontrolu)
    bool diagnosisChanged = false;
    if (_currentDiagnoses.length !=
        (widget.work.diagnosesResponse?.length ?? 0)) {
      diagnosisChanged = true;
    } else {
      // Icerik kontrolü: ID'leri karsilastir
      final oldIds = (widget.work.diagnosesResponse ?? [])
          .map((e) => e.id)
          .toSet();
      final newIds = _currentDiagnoses.map((e) => e.id).toSet();
      if (oldIds.length != newIds.length || !oldIds.containsAll(newIds)) {
        diagnosisChanged = true;
      }
    }

    // Servis listesi karsilastirmasi (Adet ve ID kontrolu)
    // Not: ServiceResponse modelinde adet (count) yoksa, listedeki tekrar sayisina gore bakilabilir
    // Veya modelin yapisina gore (id, price vb.)
    // Burada basitce liste uzunlugu ve icerigi kontrol ediliyor.
    bool serviceChanged = false;
    if (_currentServices.length !=
        (widget.work.serviceResponses?.length ?? 0)) {
      serviceChanged = true;
    } else {
      // Servis ID'leri ve Fiyatlari ayni mi?
      // (Burada daha detayli bir Deep Equality Check yapilabilir collection paketi ile)
      // Basit kontrol:
      final oldServices = widget.work.serviceResponses ?? [];
      for (int i = 0; i < oldServices.length; i++) {
        if (oldServices[i].id != _currentServices[i].id) {
          serviceChanged = true;
          break;
        }
      }
    }

    final hasChanges = textChanged || diagnosisChanged || serviceChanged;

    if (_hasChanges != hasChanges) {
      setState(() {
        _hasChanges = hasChanges;
      });
    }
  }

  void _onSavePressed() {
    if (widget.onSave != null) {
      // Guncel verilerle yeni bir model olustur
      final updatedWork = widget.work.copyWith(
        surveyPlan: _treatmentFormController.surveyPlanController.text,
        recommendations: _treatmentFormController.recommendationController.text,
        treatment: _treatmentFormController.treatmentController.text,
        diagnosesResponse: _currentDiagnoses,
        serviceResponses: _currentServices,
      );

      widget.onSave!(updatedWork);

      // Kaydettikten sonra UI'i guncellemek icin beklenebilir veya parent widget rebuild edebilir.
      // Simdilik degisiklik yokmus gibi isaretliyoruz (Parent rebuild edince zaten duzelecek)
      setState(() {
        _hasChanges = false;
      });
    }
  }

  void _onFocusChanged(PatternType patternType) {
    setState(() {});
    _searchPatterns('');
  }

  Future<void> _searchPatterns(String searchText) async {
    // Pattern search logic ayni kaldi
    // ... (Yukaridaki kodunuzdan alabilirsiniz)
    final activeType = _treatmentFormController.activePatternType;
    if (activeType != null) {
      if (searchText.isEmpty || searchText.length >= 2) {
        if (!_treatmentFormController.isSearching) {
          _treatmentFormController.setSearching(true);
          if (mounted) setState(() {});
        }
        try {
          await _patternCubit.getPatternList(
            activeType,
            search: searchText.isEmpty ? null : searchText,
          );
        } finally {
          if (mounted) {
            _treatmentFormController.setSearching(false);
            setState(() {});
          }
        }
      }
    }
  }

  // Renk Parse Helper
  Color _parseColor(String? hexColor) {
    if (hexColor == null || hexColor.isEmpty) return Colors.grey;
    try {
      final buffer = StringBuffer();
      if (hexColor.length == 6 || hexColor.length == 7) buffer.write('ff');
      buffer.write(hexColor.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (e) {
      return Colors.grey;
    }
  }

  // TEŞHİS SEÇİM MODALI
  void _openDiagnosisSelection() {
    // Burada AllDiagnosisCubit'in zaten bir ust widgetta provide edildigini varsayiyoruz.
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DiagnosisSelectionSheet(
        initialSelected: _currentDiagnoses,
        onSelectionChanged: (List<DiagnosesResponse> selected) {
          setState(() {
            _currentDiagnoses = selected;
            _checkChanges();
          });
        },
      ),
    );
  }

  // SERVİS SEÇİM MODALI
  void _openServiceSelection() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ServiceSelectionSheet(
        initialServices: _currentServices,
        onSelectionChanged: (List<ServiceResponse> selected) {
          setState(() {
            _currentServices = selected;
            _checkChanges();
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final toothNumber = widget.work.toothResponse?.toothNumber;

    // Fiyat hesabi (Guncel listeye gore)
    final double totalPrice = _currentServices
        .fold(0, (prev, element) => prev + (element.price ?? 0))
        .toDouble();
    final int totalServices = _currentServices.length;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: _hasChanges
            ? Border.all(
                color: Theme.of(context).colorScheme.primary,
                width: 1.5,
              ) // Degisiklik varsa border renkli olsun
            : Border.all(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
              ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _hasChanges
                  ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                  : Theme.of(context).colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.3),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              spacing: 6,
              children: [
                AppText(
                  title: toothNumber != null
                      ? '${LocaleKeys.forms_tooth.tr()}: $toothNumber'
                      : LocaleKeys.general_undefined.tr(),
                  textType: TextType.title24,
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
                const Spacer(),

                // SAVE BUTTON (Sadece degisiklik varsa goster)
                if (_hasChanges)
                  ElevatedButton(
                    onPressed: _onSavePressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                    child: Text(LocaleKeys.buttons_save.tr()),
                  ),
                IconButton(
                  onPressed: widget.onDelete,
                  icon: const Icon(Icons.delete_outline),
                  iconSize: 24,
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.error.withValues(alpha: 0.1),
                    foregroundColor: Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 12,
              children: [
                // DIAGNOSIS SECTION (Editable)
                _buildDiagnosisSection(context),

                // TOOTH INFO (Read Only)
                if (widget.work.toothResponse != null)
                  ToothConditionInfoWidget(
                    toothResponse: widget.work.toothResponse!,
                  ),

                // TEXT FIELDS
                ExpandableTextFieldWidget(
                  title: PatternUtils.getTitleForPatternType(
                    PatternType.surveyPlan,
                  ),
                  hintText: PatternUtils.getHintTextForPatternType(
                    PatternType.surveyPlan,
                  ),
                  controller: _treatmentFormController.surveyPlanController,
                  focusNode: _treatmentFormController.surveyPlanFocusNode,
                  patternType: PatternType.surveyPlan,
                  onPatternTap: () =>
                      _showPatternSelectionDialog(PatternType.surveyPlan),
                ),

                ExpandableTextFieldWidget(
                  title: PatternUtils.getTitleForPatternType(
                    PatternType.treatment,
                  ),
                  hintText: PatternUtils.getHintTextForPatternType(
                    PatternType.treatment,
                  ),
                  controller: _treatmentFormController.treatmentController,
                  focusNode: _treatmentFormController.treatmentFocusNode,
                  patternType: PatternType.treatment,
                  onPatternTap: () =>
                      _showPatternSelectionDialog(PatternType.treatment),
                ),

                ExpandableTextFieldWidget(
                  title: PatternUtils.getTitleForPatternType(
                    PatternType.recommendation,
                  ),
                  hintText: PatternUtils.getHintTextForPatternType(
                    PatternType.recommendation,
                  ),
                  controller: _treatmentFormController.recommendationController,
                  focusNode: _treatmentFormController.recommendationFocusNode,
                  patternType: PatternType.recommendation,
                  onPatternTap: () =>
                      _showPatternSelectionDialog(PatternType.recommendation),
                ),

                // SERVICES SECTION (Editable)
                _buildServicesSection(context, totalPrice, totalServices),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildDiagnosisSection(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: _openDiagnosisSelection, // TIKLANINCA DUZENLEME MODUNU AC
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: theme.colorScheme.outlineVariant,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.medical_services,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      LocaleKeys.forms_tooth_diagnosis.tr(),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Icon(Icons.edit, size: 16, color: theme.colorScheme.secondary),
              ],
            ),
            const SizedBox(height: 8),
            if (_currentDiagnoses.isEmpty)
              Text(
                LocaleKeys.general_select.tr(), // "Seciniz"
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.hintColor,
                ),
              )
            else
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _currentDiagnoses.map((diagnosis) {
                  return Chip(
                    label: Text(diagnosis.name),
                    labelStyle: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    backgroundColor: theme.colorScheme.surfaceContainerHigh,
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                    onDeleted: () {
                      setState(() {
                        _currentDiagnoses.remove(diagnosis);
                        _checkChanges();
                      });
                    },
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildServicesSection(
    BuildContext context,
    double totalPrice,
    int totalCount,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Row with Add Button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.list_alt,
                  size: 18,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                const SizedBox(width: 8),
                Text(
                  LocaleKeys.routes_services.tr(),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
            TextButton.icon(
              onPressed: _openServiceSelection,
              icon: const Icon(Icons.add_circle_outline, size: 16),
              label: Text(LocaleKeys.buttons_edit.tr()), // Duzenle
              style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
            ),
          ],
        ),
        const SizedBox(height: 4),

        // Services List Container
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
            ),
          ),
          child: _currentServices.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      LocaleKeys.notifications_no_search_results.tr(),
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                    ),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(8),
                  itemCount: _currentServices.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    color: Theme.of(context).dividerColor.withOpacity(0.1),
                  ),
                  itemBuilder: (context, index) {
                    final service = _currentServices[index];
                    // Servisleri tek tek gosteriyoruz, count logic service selection icinde handle edilecek
                    // ve buraya flatten (duzlestirilmis) liste olarak donecek diye varsayiyoruz.
                    // Eger ayni servis birden fazla ise burada gruplayabiliriz ama
                    // ServiceResponse modelinde 'count' yoksa duz liste daha mantikli.

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 4,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              service.name ?? 'Unknown',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                          PriceConvertWidget(
                            price: service.price?.toDouble() ?? 0,
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),

        const SizedBox(height: 12),
        // Total Price Footer
        Container(
          padding: const EdgeInsets.all(12),

          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                LocaleKeys.report_total_amount.tr(),
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
              ),
              PriceConvertWidget(
                price: totalPrice,
                textType: TextType.title,
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showPatternSelectionDialog(PatternType patternType) {
    final title = PatternUtils.getTitleForPatternType(patternType);
    _treatmentFormController.setActivePatternType(patternType, _onFocusChanged);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => PatternSelectionBottomSheet(
        patternType: patternType,
        title: title,
        patternCubit: _patternCubit,
        onPatternSelected: (pattern) =>
            _handlePatternSelection(patternType, pattern),
      ),
    );
  }

  void _handlePatternSelection(PatternType patternType, dynamic pattern) {
    final controller = _getControllerForPatternType(patternType);
    _treatmentFormController.insertPattern(controller, pattern);
    _checkChanges(); // Pattern eklendikten sonra degisiklik kontrolu
  }

  TextEditingController _getControllerForPatternType(PatternType patternType) {
    return switch (patternType) {
      PatternType.surveyPlan => _treatmentFormController.surveyPlanController,
      PatternType.recommendation =>
        _treatmentFormController.recommendationController,
      PatternType.treatment => _treatmentFormController.treatmentController,
      _ => _treatmentFormController.surveyPlanController,
    };
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
