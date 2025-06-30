part of 'tooth_diagnosis_modal.dart';

class DiagnosisDetailsModal extends StatelessWidget {
  final ConditionModel conditions;
  final Conditions? selectedCondition;
  final ValueChanged<Conditions> onSelect;

  const DiagnosisDetailsModal({
    super.key,
    required this.conditions,
    required this.onSelect,
    this.selectedCondition,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      expand: false,

      builder: (context, controller) {
        final size = MediaQuery.of(context);
        return Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          margin: EdgeInsets.only(bottom: size.padding.bottom),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(theme),
              Expanded(
                child: ListView.separated(
                  controller: controller,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: conditions.conditions?.length ?? 0,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final diagnosis = conditions.conditions?[index];
                    return _DiagnosisOption(
                      diagnosis:
                          diagnosis ??
                          Conditions(
                            id: 0,
                            name: "",
                            code: "",
                            color: AppColors.primary,
                          ),
                      isSelected: selectedCondition == diagnosis,
                      onSelect:
                          () => onSelect(
                            diagnosis ??
                                Conditions(
                                  id: 0,
                                  name: "",
                                  code: "",
                                  color: AppColors.primary,
                                ),
                          ),
                      theme: theme,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 32,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: theme.dividerColor.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color:
                      conditions.conditions?.first.color ?? AppColors.primary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  conditions.codeName ?? "",
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: _getContrastColor(
                      conditions.conditions?.first.color ?? AppColors.primary,
                    ),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '${conditions.conditions?.length ?? 0} ${LocaleKeys.diagnosis_available_options.tr()}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withValues(
                    alpha: 0.7,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getContrastColor(Color backgroundColor) {
    return backgroundColor.computeLuminance() > 0.5
        ? Colors.black87
        : Colors.white;
  }
}

class _DiagnosisOption extends StatelessWidget {
  final Conditions diagnosis;
  final bool isSelected;
  final VoidCallback onSelect;
  final ThemeData theme;

  const _DiagnosisOption({
    required this.diagnosis,
    required this.isSelected,
    required this.onSelect,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onSelect,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color:
                isSelected
                    ? Colors.green.withValues(alpha: 0.15)
                    : diagnosis.color?.withValues(alpha: 0.2) ??
                        Colors.transparent,
            border: Border.all(
              color:
                  isSelected
                      ? Colors.green
                      : diagnosis.color?.withValues(alpha: 0.2) ??
                          Colors.transparent,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      diagnosis.name ?? "",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildDetailChip(
                          LocaleKeys.diagnosis_icd_code.tr(),
                          diagnosis.code ?? "",
                        ),
                        // if (diagnosis.surfaces?.isNotEmpty ?? false) ...[
                        //   const SizedBox(width: 8),
                        //   _buildDetailChip(
                        //     LocaleKeys.diagnosis_surfaces.tr(),
                        //     diagnosis.surfaces.join(', '),
                        //   ),
                        // ],
                      ],
                    ),
                  ],
                ),
              ),
              if (isSelected) ...[
                const SizedBox(width: 12),
                Icon(Icons.check_circle, color: Colors.green, size: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
