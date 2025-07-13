import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/main.dart';
import 'package:dent_app_mobile/presentation/pages/treatment/core/service/condition_service.dart';
import 'package:dent_app_mobile/presentation/widgets/text/app_text.dart';
import 'package:dent_app_mobile/router/app_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teeth_selector/teeth_selector.dart';

class ToothDiagnosisTab extends StatefulWidget {
  const ToothDiagnosisTab({super.key, required this.appointmentId});

  final int appointmentId;

  @override
  State<ToothDiagnosisTab> createState() => _ToothDiagnosisTabState();
}

class _ToothDiagnosisTabState extends State<ToothDiagnosisTab> {
  // Constants
  static const double _verticalSpacing = 10.0;
  static const double _cardMargin = 16.0;
  static const double _cardVerticalMargin = 8.0;
  static const double _cardRadius = 16.0;
  static const double _cardElevation = 4.0;
  static const double _cardPadding = 20.0;
  static const double _iconSize = 24.0;
  static const double _iconPadding = 12.0;
  static const double _iconRadius = 12.0;
  static const double _iconShadowBlur = 8.0;
  static const double _iconShadowOffset = 4.0;
  static const double _badgeRadius = 20.0;
  static const double _badgeShadowBlur = 6.0;
  static const double _badgeShadowOffset = 2.0;
  static const double _arrowIconSize = 16.0;
  static const double _arrowContainerSize = 8.0;
  static const double _contentSpacing = 16.0;
  static const double _badgeSpacing = 12.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<ConditionService>(
        builder: (context, conditionService, child) {
          return SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: _verticalSpacing),
                _buildTeethSelector(conditionService),
                if (conditionService.jobs.isNotEmpty)
                  _buildWorkItemsCard(conditionService),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Builds the teeth selector widget with professional configuration
  Widget _buildTeethSelector(ConditionService conditionService) {
    final theme = Theme.of(context);

    return Center(
      child: TeethSelector(
        showPrimary: true,
        multiSelect: false,
        showPermanent: true,
        colorized: _buildColorizedMap(conditionService, theme),
        selectedColor: theme.colorScheme.primary,
        rightString: LocaleKeys.general_right.tr(),
        leftString: LocaleKeys.general_left.tr(),
        initiallySelected: _getInitiallySelectedTeeth(conditionService),
        onChange:
            (selected) => _handleTeethSelection(selected, conditionService),
      ),
    );
  }

  /// Creates colorized map for teeth with smart color logic
  Map<String, Color> _buildColorizedMap(
    ConditionService conditionService,
    ThemeData theme,
  ) {
    return {
      for (final job in conditionService.jobs)
        job.toothId: _getToothColor(job.condition.color, theme),
    };
  }

  /// Determines the appropriate color for a tooth
  Color _getToothColor(Color? conditionColor, ThemeData theme) {
    if (conditionColor == Colors.white) {
      return Colors.green;
    }
    return conditionColor ?? theme.colorScheme.primary;
  }

  /// Gets initially selected teeth IDs
  List<String> _getInitiallySelectedTeeth(ConditionService conditionService) {
    return conditionService.jobs.map((job) => job.toothId).toList();
  }

  /// Handles teeth selection logic
  void _handleTeethSelection(
    List<String> selected,
    ConditionService conditionService,
  ) {
    if (selected.isNotEmpty) {
      _showToothDialog(selected.last, conditionService);
    }
  }

  /// Shows tooth examination dialog
  void _showToothDialog(String toothId, ConditionService conditionService) {
    final existingJob = conditionService.jobs.cast<dynamic>().firstWhere(
      (job) => job.toothId == toothId,
      orElse: () => null,
    );

    showDialog(
      context: context,
      builder:
          (context) => _ToothExaminationDialog(
            toothId: toothId,
            existingJob: existingJob,
            onExamine: () {
              Navigator.pop(context);
              conditionService.setToothId(toothId);
              router.push(const TeethConditionActionRoute());
            },
          ),
    );
  }

  /// Builds the work items card with professional styling
  Widget _buildWorkItemsCard(ConditionService conditionService) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: _cardMargin,
        vertical: _cardVerticalMargin,
      ),
      child: Material(
        elevation: _cardElevation,
        borderRadius: BorderRadius.circular(_cardRadius),
        color: Colors.white,
        shadowColor: theme.colorScheme.primary.withValues(alpha: 0.1),
        child: InkWell(
          onTap: () => _navigateToWorkItems(),
          borderRadius: BorderRadius.circular(_cardRadius),
          child: Container(
            decoration: _buildCardDecoration(theme),
            child: Padding(
              padding: const EdgeInsets.all(_cardPadding),
              child: Row(
                children: [
                  _buildCardContent(theme),
                  _buildCardActions(conditionService, theme),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Creates card decoration with gradient
  BoxDecoration _buildCardDecoration(ThemeData theme) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(_cardRadius),
      gradient: LinearGradient(
        colors: [
          theme.colorScheme.primary.withValues(alpha: 0.05),
          theme.colorScheme.secondary.withValues(alpha: 0.08),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    );
  }

  /// Builds the main content of the card (icon + text)
  Widget _buildCardContent(ThemeData theme) {
    return Expanded(
      child: Row(
        children: [
          _buildCardIcon(theme),
          const SizedBox(width: _contentSpacing),
          _buildCardTitle(theme),
        ],
      ),
    );
  }

  /// Builds the card icon with styling
  Widget _buildCardIcon(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(_iconPadding),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(_iconRadius),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: _iconShadowBlur,
            offset: const Offset(0, _iconShadowOffset),
          ),
        ],
      ),
      child: const Icon(
        Icons.work_outline,
        color: Colors.white,
        size: _iconSize,
      ),
    );
  }

  /// Builds the card title
  Widget _buildCardTitle(ThemeData theme) {
    return Expanded(
      child: AppText(
        title: LocaleKeys.general_work_items.tr(),
        textType: TextType.header,
        color: theme.colorScheme.onSurface,
      ),
    );
  }

  /// Builds the card actions (badge + arrow)
  Widget _buildCardActions(ConditionService conditionService, ThemeData theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildJobCountBadge(conditionService, theme),
        const SizedBox(width: _badgeSpacing),
        _buildArrowIcon(theme),
      ],
    );
  }

  /// Builds the job count badge
  Widget _buildJobCountBadge(
    ConditionService conditionService,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: _iconPadding,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(_badgeRadius),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: _badgeShadowBlur,
            offset: const Offset(0, _badgeShadowOffset),
          ),
        ],
      ),
      child: AppText(
        title: "${conditionService.jobs.length}",
        textType: TextType.subtitle,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  /// Builds the arrow icon
  Widget _buildArrowIcon(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(_arrowContainerSize),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(_arrowContainerSize),
      ),
      child: Icon(
        Icons.arrow_forward_ios_rounded,
        color: theme.colorScheme.primary,
        size: _arrowIconSize,
      ),
    );
  }

  /// Navigates to work items page
  void _navigateToWorkItems() {
    router.push(WorkItemsRoute(appointmentId: widget.appointmentId));
  }
}

// Tooth Examination Dialog Widget
class _ToothExaminationDialog extends StatelessWidget {
  final String toothId;
  final dynamic existingJob;
  final VoidCallback onExamine;

  const _ToothExaminationDialog({
    required this.toothId,
    this.existingJob,
    required this.onExamine,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 10,
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Tooth Icon & Number
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(color: theme.colorScheme.primary, width: 3),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.biotech_outlined,
                    color: theme.colorScheme.primary,
                    size: 32,
                  ),
                  AppText(
                    title: toothId,
                    textType: TextType.subtitle,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Title
            AppText(
              title: "Зуб $toothId",
              textType: TextType.header,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),

            const SizedBox(height: 16),

            // Existing treatments or examination prompt
            if (existingJob != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.secondary.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.history,
                          color: theme.colorScheme.secondary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        AppText(
                          title: "Текущий осмотр",
                          textType: TextType.subtitle,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.secondary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    AppText(
                      title:
                          "Состояние: ${existingJob.condition?.name ?? 'Неизвестно'}",
                      textType: TextType.body,
                    ),
                    if (existingJob.diagnosis?.isNotEmpty == true) ...[
                      const SizedBox(height: 4),
                      AppText(
                        title: "Диагноз: ${existingJob.diagnosis.length} шт.",
                        textType: TextType.subtitle,
                      ),
                    ],
                    if (existingJob.servicesWithCount?.isNotEmpty == true) ...[
                      const SizedBox(height: 4),
                      AppText(
                        title:
                            "Услуги: ${existingJob.servicesWithCount.length} шт.",
                        textType: TextType.subtitle,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),
              AppText(
                title: "Хотите ли вы провести повторный осмотр этого зуба?",
                textType: TextType.body,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ] else ...[
              AppText(
                title: "Хотите ли вы провести осмотр этого зуба?",
                textType: TextType.body,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ],

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: AppText(
                      title: "Отмена",
                      textType: TextType.body,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: onExamine,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 2,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.biotech, size: 18),
                        const SizedBox(width: 8),
                        AppText(
                          title:
                              existingJob != null
                                  ? "Повторный осмотр"
                                  : "Осмотреть",
                          textType: TextType.subtitle,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
