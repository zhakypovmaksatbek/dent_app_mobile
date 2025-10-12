import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/main.dart';
import 'package:dent_app_mobile/models/diagnosis/tooth_model.dart';
import 'package:dent_app_mobile/presentation/constants/asset_constants.dart';
import 'package:dent_app_mobile/presentation/pages/patient/core/bloc/patient_tooth/patient_tooth_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/treatment/core/service/condition_service.dart';
import 'package:dent_app_mobile/presentation/theme/colors/color_constants.dart';
import 'package:dent_app_mobile/presentation/widgets/image/custom_asset_image.dart';
import 'package:dent_app_mobile/presentation/widgets/text/app_text.dart';
import 'package:dent_app_mobile/router/app_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:teeth_selector/teeth_selector.dart';

class ToothDiagnosisTab extends StatefulWidget {
  const ToothDiagnosisTab({
    super.key,
    required this.appointmentId,
    required this.patientId,
  });

  final int appointmentId;
  final int patientId;

  @override
  State<ToothDiagnosisTab> createState() => _ToothDiagnosisTabState();
}

class _ToothDiagnosisTabState extends State<ToothDiagnosisTab> {
  late PatientToothCubit _patientToothCubit;
  List<ToothModel> _teeth = [];

  @override
  void initState() {
    super.initState();
    _patientToothCubit = PatientToothCubit();
    _patientToothCubit.getToothList(widget.patientId);
  }

  @override
  void dispose() {
    _patientToothCubit.close();
    super.dispose();
  }

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
      body: BlocConsumer<PatientToothCubit, PatientToothState>(
        bloc: _patientToothCubit,
        listener: (context, state) {
          if (state is PatientToothLoaded) {
            _teeth = state.teeth;
          }
        },
        builder: (context, state) {
          return Consumer<ConditionService>(
            builder: (context, conditionService, child) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: _verticalSpacing),
                    _buildTeethSelector(conditionService, _teeth),
                    const SizedBox(height: _verticalSpacing),
                    if (conditionService.jobs.isNotEmpty)
                      _buildWorkItemsCard(conditionService),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          router.push(
                            PaymentDetailRoute(
                              appointmentId: widget.appointmentId,
                            ),
                          );
                        },
                        child: Center(child: Text(LocaleKeys.buttons_pay.tr())),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Map<String, Color> _getTeethColorMap() {
    final map = <String, Color>{};

    for (final tooth in _teeth) {
      if (tooth.toothNumber != null &&
          tooth.main?.color != null &&
          tooth.main!.color!.isNotEmpty) {
        final String toothId = tooth.toothNumber.toString();
        map[toothId] = _hexToColor(tooth.main!.color!);
      }
    }

    return map;
  }

  /// Converts a hex string to Color
  Color _hexToColor(String hexString) {
    try {
      final String colorStr = hexString.replaceFirst('#', 'FF');
      return Color(int.parse(colorStr, radix: 16));
    } catch (e) {
      // Return default color on error
      return ColorConstants.primary;
    }
  }

  /// Builds the teeth selector widget with jaw overlay buttons
  Widget _buildTeethSelector(
    ConditionService conditionService,
    List<ToothModel> teeth,
  ) {
    final theme = Theme.of(context);

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // TeethSelector as base
          TeethSelector(
            showPrimary: true,
            StrokedColorized: _getTeethColorMap(),
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

          // Overlay jaw buttons in the center
          Positioned(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Upper jaw button
                _buildCompactJawButton(
                  context: context,
                  title: LocaleKeys.tooth_upper_jaw.tr(),
                  toothId: "29",
                  isUpper: true,
                  conditionService: conditionService,
                  theme: theme,
                ),
                const SizedBox(height: 12),
                // Lower jaw button
                _buildCompactJawButton(
                  context: context,
                  title: LocaleKeys.tooth_lower_jaw.tr(),
                  toothId: "39",
                  isUpper: false,
                  conditionService: conditionService,
                  theme: theme,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds compact jaw button for overlay
  Widget _buildCompactJawButton({
    required BuildContext context,
    required String title,
    required String toothId,
    required bool isUpper,
    required ConditionService conditionService,
    required ThemeData theme,
  }) {
    // Check if this jaw has existing jobs
    final hasJob = conditionService.jobs.any((job) => job.toothId == toothId);
    final jawJob =
        hasJob
            ? conditionService.jobs.firstWhere((job) => job.toothId == toothId)
            : null;

    return Material(
      elevation: hasJob ? 0 : 2,
      borderRadius: BorderRadius.circular(16),
      color:
          hasJob
              ? theme.colorScheme.primary.withValues(alpha: 0.1)
              : Colors.white.withValues(alpha: 0.95),
      child: InkWell(
        onTap: () {
          // EKLE: Jaw için de tooth history bul
          int? toothIdInt;
          try {
            toothIdInt = int.parse(toothId);
          } catch (e) {
            // Parse error
          }

          final toothInfo =
              toothIdInt != null
                  ? _teeth.firstWhere(
                    (tooth) => tooth.toothNumber == toothIdInt,
                    orElse: () => ToothModel(toothNumber: toothIdInt),
                  )
                  : null;

          _showToothDialog(toothId, conditionService, teethHistory: toothInfo);
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color:
                  hasJob
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline.withValues(alpha: 0.3),
              width: hasJob ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // SVG Icon
              Icon(
                isUpper ? Icons.arrow_upward : Icons.arrow_downward,
                size: 20,
                color:
                    hasJob
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface,
              ),
              const SizedBox(width: 8),

              // Title
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    title: title,
                    textType: TextType.body,
                    fontWeight: FontWeight.w600,
                    color:
                        hasJob
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface,
                  ),
                  if (hasJob && jawJob != null)
                    AppText(
                      title:
                          "${jawJob.servicesWithCount.values.fold(0, (sum, count) => sum + count)} услуг",
                      textType: TextType.subtitle,
                      color: theme.colorScheme.primary,
                    ),
                ],
              ),
            ],
          ),
        ),
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
    int? toothId;
    try {
      toothId = int.parse(selected.last);
    } catch (e) {
      // Ignore parsing error
      return;
    }
    final toothInfo = _teeth.firstWhere(
      (tooth) => tooth.toothNumber == toothId,
      orElse: () => ToothModel(toothNumber: toothId),
    );
    if (selected.isNotEmpty) {
      _showToothDialog(
        selected.last,
        conditionService,
        teethHistory: toothInfo,
      );
    }
  }

  /// Shows tooth examination dialog
  /// Shows tooth examination dialog
  void _showToothDialog(
    String toothId,
    ConditionService conditionService, {
    ToothModel? teethHistory,
  }) {
    final existingJob = conditionService.jobs.cast<dynamic>().firstWhere(
      (job) => job.toothId == toothId,
      orElse: () => null,
    );

    // EKLE: toothId'yi int'e çevir ve tooth history'yi bul
    int? toothIdInt;
    try {
      toothIdInt = int.parse(toothId);
    } catch (e) {
      // Parse error
    }

    // Eğer teethHistory parametresi gelmemişse, _teeth listesinden bul
    final toothInfo =
        teethHistory ??
        (toothIdInt != null
            ? _teeth.firstWhere(
              (tooth) => tooth.toothNumber == toothIdInt,
              orElse: () => ToothModel(toothNumber: toothIdInt),
            )
            : null);

    showDialog(
      context: context,
      builder:
          (context) => _ToothExaminationDialog(
            toothId: toothId,
            existingJob: existingJob,
            teethHistory: toothInfo, // HER ZAMAN GÖNDER
            onExamine: () {
              router.pop();
              conditionService.setToothId(toothId);
              router.push(
                TeethConditionActionRoute(appointmentId: widget.appointmentId),
              );
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
  final ToothModel? teethHistory;
  const _ToothExaminationDialog({
    required this.toothId,
    this.existingJob,
    required this.onExamine,
    this.teethHistory,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tooth Icon & Number
            Center(
              child: Container(
                width: 80,
                alignment: Alignment.center,
                height: 80,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.colorScheme.primary,
                    width: 3,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CustomAssetImage(
                      path: AssetConstants.toothLogo.png,
                      height: 30,
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
            ),

            const SizedBox(height: 20),

            // Title
            Center(
              child: AppText(
                title: "Зуб $toothId",
                textType: TextType.header,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 16),
            if (teethHistory != null) ...[_buildDiagnosisInfo()],

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

  Widget _buildDiagnosisInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${LocaleKeys.routes_diagnosis.tr()}:',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),

        // Main diagnosis
        if (teethHistory?.main?.name != null &&
            teethHistory?.main?.name?.isNotEmpty == true)
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '• ${LocaleKeys.general_main.tr()}: ${teethHistory?.main?.name}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                if (teethHistory?.main?.color != null &&
                    teethHistory?.main?.color?.isNotEmpty == true)
                  Container(
                    width: 16,
                    height: 16,
                    margin: const EdgeInsets.only(left: 4),
                    decoration: BoxDecoration(
                      color: _hexToColor(teethHistory?.main?.color ?? ''),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
              ],
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              '• ${LocaleKeys.general_main.tr()}: ${LocaleKeys.general_no_diagnosis.tr()}',
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
          ),

        const SizedBox(height: 8),

        // Inner tooth details section
        if (teethHistory?.innerToothResponse != null) ...[
          Text(
            LocaleKeys.general_inner_tooth_details.tr(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInnerDiagnosisItem(
                  LocaleKeys.general_top.tr(),
                  teethHistory?.innerToothResponse?.top,
                ),
                _buildInnerDiagnosisItem(
                  LocaleKeys.general_bottom.tr(),
                  teethHistory?.innerToothResponse?.bottom,
                ),
                _buildInnerDiagnosisItem(
                  LocaleKeys.general_left.tr(),
                  teethHistory?.innerToothResponse?.left,
                ),
                _buildInnerDiagnosisItem(
                  LocaleKeys.general_right.tr(),
                  teethHistory?.innerToothResponse?.right,
                ),
                _buildInnerDiagnosisItem(
                  LocaleKeys.general_center_left.tr(),
                  teethHistory?.innerToothResponse?.centerLeft,
                ),
                _buildInnerDiagnosisItem(
                  LocaleKeys.general_center_right.tr(),
                  teethHistory?.innerToothResponse?.centerRight,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  /// Builds an inner diagnosis item with proper null checks
  Widget _buildInnerDiagnosisItem(String label, MainModel? diagnosis) {
    if (diagnosis == null ||
        diagnosis.name == null ||
        diagnosis.name!.isEmpty) {
      return const SizedBox.shrink(); // Don't show if no diagnosis
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        children: [
          Expanded(child: Text('• $label: ${diagnosis.name}')),
          if (diagnosis.color != null && diagnosis.color!.isNotEmpty)
            Container(
              width: 14,
              height: 14,
              margin: const EdgeInsets.only(left: 4),
              decoration: BoxDecoration(
                color: _hexToColor(diagnosis.color!),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
        ],
      ),
    );
  }

  /// Converts a hex string to Color
  Color _hexToColor(String hexString) {
    try {
      final String colorStr = hexString.replaceFirst('#', 'FF');
      return Color(int.parse(colorStr, radix: 16));
    } catch (e) {
      // Return default color on error
      return ColorConstants.primary;
    }
  }
}
