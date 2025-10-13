import 'dart:async';

import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/presentation/pages/treatment/core/bloc/pattern/pattern_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/treatment/core/data/pattern_type.dart';
import 'package:dent_app_mobile/presentation/pages/treatment/core/model/job_model.dart';
import 'package:dent_app_mobile/presentation/pages/treatment/core/service/condition_service.dart';
import 'package:dent_app_mobile/presentation/pages/treatment/utils/pattern_utils.dart';
import 'package:dent_app_mobile/presentation/pages/treatment/utils/tooth_type.dart';
import 'package:dent_app_mobile/presentation/pages/treatment/utils/treatment_form_controller.dart';
import 'package:dent_app_mobile/presentation/pages/treatment/widgets/expandable_text_field_widget.dart';
import 'package:dent_app_mobile/presentation/pages/treatment/widgets/pattern_selection_bottom_sheet.dart';
import 'package:dent_app_mobile/presentation/widgets/text/app_text.dart';
import 'package:dent_app_mobile/presentation/widgets/text/price_convert_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class JobCard extends StatefulWidget {
  final JobModel job;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final ConditionService conditionService;

  const JobCard({
    super.key,
    required this.job,
    this.onEdit,
    this.onDelete,
    required this.conditionService,
  });

  @override
  State<JobCard> createState() => _JobCardState();
}

class _JobCardState extends State<JobCard> {
  late final TreatmentFormController _treatmentFormController;
  late final PatternCubit _patternCubit;

  // Flag to prevent recursive updates
  bool _isUpdatingFromModel = false;

  // Debounce timer for text updates
  Timer? _debounceTimer;

  // Track last update times to prevent excessive updates
  final Map<PatternType, DateTime> _lastUpdateTimes = {};

  @override
  void initState() {
    super.initState();
    _treatmentFormController = TreatmentFormController();
    _patternCubit = PatternCubit();
    _initializeFormController();
  }

  @override
  void didUpdateWidget(JobCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update controllers if job data has changed
    if (oldWidget.job.id != widget.job.id) {
      _updateControllersFromJob();
    }
  }

  /// Updates text controllers with current job data
  void _updateControllersFromJob() {
    _isUpdatingFromModel = true;

    _treatmentFormController.surveyPlanController.text =
        widget.job.surveyPlan ?? '';
    _treatmentFormController.recommendationController.text =
        widget.job.recommendation ?? '';
    _treatmentFormController.treatmentController.text =
        widget.job.treatment ?? '';

    _isUpdatingFromModel = false;
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _treatmentFormController.dispose();
    _patternCubit.close();
    super.dispose();
  }

  void _initializeFormController() {
    // Initialize text controllers with current job data
    _treatmentFormController.surveyPlanController.text =
        widget.job.surveyPlan ?? '';
    _treatmentFormController.recommendationController.text =
        widget.job.recommendation ?? '';
    _treatmentFormController.treatmentController.text =
        widget.job.treatment ?? '';

    // Set up listeners for text changes
    _treatmentFormController.surveyPlanController.addListener(
      () => _onTextChanged(PatternType.surveyPlan),
    );
    _treatmentFormController.recommendationController.addListener(
      () => _onTextChanged(PatternType.recommendation),
    );
    _treatmentFormController.treatmentController.addListener(
      () => _onTextChanged(PatternType.treatment),
    );

    // Set up focus listeners
    _treatmentFormController.setupFocusNodeListeners(_onFocusChanged);
  }

  /// Handles text changes with debouncing to prevent excessive updates
  void _onTextChanged(PatternType patternType) {
    // Prevent recursive updates
    if (_isUpdatingFromModel) return;

    // Cancel previous timer
    _debounceTimer?.cancel();

    // Start new debounced update
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _performDebouncedUpdate(patternType);
    });
  }

  /// Performs the actual job update after debouncing
  void _performDebouncedUpdate(PatternType patternType) {
    final controller = _getControllerForPatternType(patternType);
    final newText = controller.text;

    // Only update if the text has actually changed
    final currentValue = switch (patternType) {
      PatternType.surveyPlan => widget.job.surveyPlan,
      PatternType.recommendation => widget.job.recommendation,
      PatternType.treatment => widget.job.treatment,
      _ => null,
    };

    if (currentValue != newText) {
      // Check if enough time has passed since last update
      final lastUpdate = _lastUpdateTimes[patternType];
      final now = DateTime.now();

      if (lastUpdate == null ||
          now.difference(lastUpdate).inMilliseconds > 300) {
        _updateJobField(patternType, newText);
        _lastUpdateTimes[patternType] = now;
      }
    }
  }

  /// Updates the job field with proper error handling
  Future<void> _updateJobField(PatternType patternType, String value) async {
    try {
      widget.conditionService.updateJob(widget.job.id, patternType, value);

      // Optional: Show success feedback
      if (mounted) {
        // You could show a subtle success indicator here
      }
    } catch (e) {
      // Handle error gracefully
      debugPrint('Error updating job field ${patternType.name}: $e');

      if (mounted) {
        // Show user-friendly error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to update ${patternType.name}. Please try again.',
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _onFocusChanged(PatternType patternType) {
    setState(() {
      // Update UI if needed
    });
    // Load initial patterns with empty search
    _searchPatterns('');
  }

  Future<void> _searchPatterns(String searchText) async {
    final activeType = _treatmentFormController.activePatternType;
    if (activeType != null) {
      // Only search if the text has at least 2 characters or is empty (show all)
      if (searchText.isEmpty || searchText.length >= 2) {
        // Set loading state
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
          // Reset loading state
          if (mounted) {
            _treatmentFormController.setSearching(false);
            setState(() {});
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with ID and Actions
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                AppText(
                  title:
                      '${LocaleKeys.forms_tooth.tr()}: ${widget.job.toothId}',
                  textType: TextType.title24,
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
                const Spacer(),
                if (widget.onEdit != null)
                  IconButton(
                    onPressed: widget.onEdit,
                    icon: const Icon(Icons.edit_outlined),
                    iconSize: 20,
                    style: IconButton.styleFrom(
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.secondary.withValues(alpha: 0.1),
                      foregroundColor: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                const SizedBox(width: 8),
                if (widget.onDelete != null)
                  IconButton(
                    onPressed: widget.onDelete,
                    icon: const Icon(Icons.delete_outline),
                    iconSize: 20,
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

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 12,
              children: [
                // Diagnosis Info
                _buildDiagnosisSection(context),

                // Condition and Tooth Type
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildInfoSection(
                        context,
                        LocaleKeys.forms_tooth_condition.tr(),
                        widget.job.condition.name ?? 'Не указано',
                        Icons.healing,
                        widget.job.condition.color ?? Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildInfoSection(
                        context,
                        LocaleKeys.forms_damaged_side.tr(),
                        widget.job.toothType?.title ?? '',
                        CupertinoIcons.plus,
                        widget.job.condition.color?.withValues(alpha: 0.8) ??
                            Colors.blue,
                      ),
                    ),
                  ],
                ),

                // Services List with Counts
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
                  onPatternTap:
                      () => _showPatternSelectionDialog(PatternType.surveyPlan),
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

                  onPatternTap:
                      () => _showPatternSelectionDialog(PatternType.treatment),
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
                  onPatternTap:
                      () => _showPatternSelectionDialog(
                        PatternType.recommendation,
                      ),
                ),
                _buildServicesSection(context),

                // Total Price
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.1),
                        Theme.of(
                          context,
                        ).colorScheme.secondary.withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.attach_money,
                          color: Theme.of(context).colorScheme.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              LocaleKeys.report_total_amount.tr(),
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.7),
                              ),
                            ),
                            PriceConvertWidget(
                              price: widget.job.totalPrice,
                              textType: TextType.title,
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${widget.job.totalServiceCount} ${LocaleKeys.routes_services.tr()}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getContrastColor(Color color) {
    return color.computeLuminance() > 0.5 ? Colors.black87 : color;
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
      builder:
          (context) => PatternSelectionBottomSheet(
            patternType: patternType,
            title: title,
            patternCubit: _patternCubit,
            onPatternSelected: (pattern) {
              _handlePatternSelection(patternType, pattern);
            },
          ),
    );
  }

  /// Handles pattern selection with proper text insertion
  void _handlePatternSelection(PatternType patternType, dynamic pattern) {
    final controller = _getControllerForPatternType(patternType);

    // Prevent recursive updates during pattern insertion
    _isUpdatingFromModel = true;

    try {
      _treatmentFormController.insertPattern(controller, pattern);

      // Update the job immediately after pattern insertion
      _updateJobField(patternType, controller.text);
    } finally {
      _isUpdatingFromModel = false;
    }
  }

  TextEditingController _getControllerForPatternType(PatternType patternType) {
    return switch (patternType) {
      PatternType.surveyPlan => _treatmentFormController.surveyPlanController,
      PatternType.recommendation =>
        _treatmentFormController.recommendationController,
      PatternType.treatment => _treatmentFormController.treatmentController,
      _ => _treatmentFormController.surveyPlanController, // fallback
    };
  }

  Widget _buildDiagnosisSection(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.medical_services,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                LocaleKeys.forms_tooth_diagnosis.tr(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${widget.job.diagnosis.length}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children:
                widget.job.diagnosis.map((diagnosis) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.local_hospital,
                          size: 16,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: AppText(
                            title: diagnosis.name ?? 'Без названия',
                            textType: TextType.subtitle,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getContrastColor(color).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: _getContrastColor(color)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _getContrastColor(color),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
            ),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(8),
            itemCount: widget.job.servicesWithCount.length,
            separatorBuilder:
                (context, index) => Divider(
                  height: 1,
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
                ),
            itemBuilder: (context, index) {
              final entry = widget.job.servicesWithCount.entries.elementAt(
                index,
              );
              final service = entry.key;
              final count = entry.value;
              final servicePrice = service.price ?? 0;
              final totalServicePrice = servicePrice * count;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            service.name ?? 'Без названия',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w500),
                          ),
                          if (count > 1)
                            Row(
                              children: [
                                PriceConvertWidget(
                                  price: servicePrice,
                                  textType: TextType.description,
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (count > 1)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.secondary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '×$count',
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.secondary,
                                fontWeight: FontWeight.w600,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: PriceConvertWidget(
                            price: totalServicePrice,
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
