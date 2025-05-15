import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/models/diagnosis/tooth_model.dart';
import 'package:dent_app_mobile/presentation/pages/patient/core/util/teeth_location_util.dart';
import 'package:dent_app_mobile/presentation/theme/colors/color_constants.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// Dialog that displays detailed information about a selected tooth
class TeethDetailDialog extends StatelessWidget {
  final String toothId;
  final ToothModel toothInfo;

  const TeethDetailDialog({
    super.key,
    required this.toothId,
    required this.toothInfo,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('${LocaleKeys.general_tooth.tr()} $toothId'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLocationInfo(),
            const SizedBox(height: 12),
            _buildDiagnosisInfo(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(LocaleKeys.buttons_close.tr()),
        ),
      ],
    );
  }

  /// Builds the location information section
  Widget _buildLocationInfo() {
    final location = TeethLocationUtil.getDetailedTeethLocation(toothId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${LocaleKeys.general_location.tr()}:',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('• ${location.jaw} / ${location.side}'),
              Text('• ${location.ageGroup}'),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds the diagnosis information section
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
        if (toothInfo.main?.name != null && toothInfo.main!.name!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '• ${LocaleKeys.general_main.tr()}: ${toothInfo.main!.name}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                if (toothInfo.main?.color != null &&
                    toothInfo.main!.color!.isNotEmpty)
                  Container(
                    width: 16,
                    height: 16,
                    margin: const EdgeInsets.only(left: 4),
                    decoration: BoxDecoration(
                      color: _hexToColor(toothInfo.main!.color!),
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
        if (_hasInnerToothDiagnosis()) ...[
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
                  toothInfo.innerToothResponse?.top,
                ),
                _buildInnerDiagnosisItem(
                  LocaleKeys.general_bottom.tr(),
                  toothInfo.innerToothResponse?.bottom,
                ),
                _buildInnerDiagnosisItem(
                  LocaleKeys.general_left.tr(),
                  toothInfo.innerToothResponse?.left,
                ),
                _buildInnerDiagnosisItem(
                  LocaleKeys.general_right.tr(),
                  toothInfo.innerToothResponse?.right,
                ),
                _buildInnerDiagnosisItem(
                  LocaleKeys.general_center_left.tr(),
                  toothInfo.innerToothResponse?.centerLeft,
                ),
                _buildInnerDiagnosisItem(
                  LocaleKeys.general_center_right.tr(),
                  toothInfo.innerToothResponse?.centerRight,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  /// Checks if the tooth has any inner diagnosis
  bool _hasInnerToothDiagnosis() {
    final inner = toothInfo.innerToothResponse;
    if (inner == null) return false;

    return (inner.top?.name != null && inner.top!.name!.isNotEmpty) ||
        (inner.bottom?.name != null && inner.bottom!.name!.isNotEmpty) ||
        (inner.left?.name != null && inner.left!.name!.isNotEmpty) ||
        (inner.right?.name != null && inner.right!.name!.isNotEmpty) ||
        (inner.centerLeft?.name != null &&
            inner.centerLeft!.name!.isNotEmpty) ||
        (inner.centerRight?.name != null &&
            inner.centerRight!.name!.isNotEmpty);
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
