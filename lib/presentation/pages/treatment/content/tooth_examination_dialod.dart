import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/models/diagnosis/tooth_model.dart';
import 'package:dent_app_mobile/presentation/constants/asset_constants.dart';
import 'package:dent_app_mobile/presentation/pages/treatment/core/service/condition_service.dart';
import 'package:dent_app_mobile/presentation/theme/colors/color_constants.dart';
import 'package:dent_app_mobile/presentation/widgets/image/custom_asset_image.dart';
import 'package:dent_app_mobile/presentation/widgets/text/app_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

// Tooth Examination Dialog Widget
class ToothExaminationDialog extends StatelessWidget {
  final String toothId;
  final ConditionService? existingJob;
  final VoidCallback onExamine;
  final ToothModel? teethHistory;
  const ToothExaminationDialog({
    super.key,
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
                title: LocaleKeys.diagnosis_tooth.tr(args: [toothId]),
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
                          title: LocaleKeys.diagnosis_current_inspection.tr(),
                          textType: TextType.subtitle,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.secondary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    AppText(
                      title: LocaleKeys.diagnosis_condition_name.tr(
                        args: [
                          existingJob?.condition?.name ??
                              LocaleKeys.notifications_unknown_state.tr(),
                        ],
                      ),
                      textType: TextType.body,
                    ),
                    if (existingJob?.selectedDiagnosis.isNotEmpty == true) ...[
                      const SizedBox(height: 4),
                      AppText(
                        title: LocaleKeys.notifications_diagnosis_length.tr(
                          args: [
                            existingJob!.selectedDiagnosis.length.toString(),
                          ],
                        ),
                        textType: TextType.subtitle,
                      ),
                    ],
                    if (existingJob?.selectedServicesList.isNotEmpty ==
                        true) ...[
                      const SizedBox(height: 4),
                      AppText(
                        title: LocaleKeys.notifications_diagnosis_length.tr(
                          args: [
                            existingJob!.selectedServicesList.length.toString(),
                          ],
                        ),
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
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: AppText(
                  title: "Хотите ли вы провести осмотр этого зуба?",
                  textType: TextType.body,
                  fontWeight: FontWeight.w600,
                ),
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
                          title: existingJob != null
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
      final String colorStr = hexString.replaceAll('#', '');
      return Color(int.parse('FF$colorStr', radix: 16));
    } catch (e) {
      // Return default color on error
      return ColorConstants.primary;
    }
  }
}
