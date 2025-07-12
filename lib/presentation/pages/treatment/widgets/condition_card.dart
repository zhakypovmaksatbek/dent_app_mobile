import 'package:dent_app_mobile/models/diagnosis/condition_model.dart';
import 'package:dent_app_mobile/presentation/theme/colors/color_constants.dart';
import 'package:dent_app_mobile/presentation/widgets/text/app_text.dart';
import 'package:flutter/material.dart';

class ConditionCard extends StatelessWidget {
  final ConditionModel category;
  final Conditions? selectedDiagnosis;
  final ValueChanged<ConditionModel> onTap;
  final bool isSelected;

  const ConditionCard({
    super.key,
    required this.category,
    required this.onTap,
    this.selectedDiagnosis,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onTap(category),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: category.conditions?.first.color,
            border: Border.all(
              color:
                  isSelected
                      ? AppColors.primary
                      : AppColors.primary.withValues(alpha: 0.5),
              width: isSelected ? 3 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              _buildHeaderRow(theme, isSelected),
              Expanded(child: _buildContentSection(theme)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderRow(ThemeData theme, bool isSelected) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: AppText(
                      title: category.codeName ?? "",
                      textType: TextType.subtitle,
                      fontWeight: FontWeight.w600,
                      color: _getContrastColor(
                        category.conditions?.first.color ?? AppColors.primary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if ((category.conditions?.length ?? 0) > 1) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: (category.conditions?.first.color ??
                                AppColors.primary)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: (category.conditions?.first.color ??
                                  AppColors.primary)
                              .withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: AppText(
                        title: "+${(category.conditions!.length - 1)}",
                        textType: TextType.description,
                        color: _getContrastColor(
                          category.conditions?.first.color ?? AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              if (category.codeName != null &&
                  category.codeName!.isNotEmpty) ...[
                AppText(
                  title: category.codeDescription!,
                  textType: TextType.description,
                  color: _getContrastColor(
                    category.conditions?.first.color ?? AppColors.primary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContentSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          child: AppText(
            title: category.codeDescription ?? "",
            textType: TextType.body,
            color: theme.hintColor,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Tooltip(
                  message:
                      selectedDiagnosis != null && isSelected
                          ? (selectedDiagnosis!.name ?? "N/A")
                          : (category.code ?? "N/A"),
                  child: AppText(
                    title:
                        selectedDiagnosis != null && isSelected
                            ? (selectedDiagnosis!.name ?? "N/A")
                            : (category.code ?? "N/A"),
                    textType: TextType.description,
                    fontWeight: FontWeight.w600,
                    color: theme.textTheme.bodySmall?.color?.withValues(
                      alpha: 0.8,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Icon(Icons.check_circle, color: AppColors.primary, size: 18),
            ],
          ],
        ),
      ],
    );
  }

  Color _getContrastColor(Color backgroundColor) {
    return backgroundColor.computeLuminance() > 0.5
        ? Colors.black87
        : Colors.white;
  }
}
