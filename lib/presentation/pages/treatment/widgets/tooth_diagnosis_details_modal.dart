part of 'tooth_diagnosis_modal.dart';

class _DiagnosisDetailsModal extends StatelessWidget {
  final ToothDiagnosisCategory category;
  final ToothStateModel? selectedDiagnosis;
  final ValueChanged<ToothStateModel> onSelect;

  const _DiagnosisDetailsModal({
    required this.category,
    required this.onSelect,
    this.selectedDiagnosis,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.85,
      minChildSize: 0.4,
      expand: false,
      builder: (context, controller) {
        return Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(theme),
              Expanded(
                child: ListView.separated(
                  controller: controller,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: category.diagnoses.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final diagnosis = category.diagnoses[index];
                    return _DiagnosisOption(
                      diagnosis: diagnosis,
                      isSelected: selectedDiagnosis == diagnosis,
                      onSelect: () => onSelect(diagnosis),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: category.color,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  category.title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: _getContrastColor(category.color),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${category.diagnoses.length} ${LocaleKeys.diagnosis_available_options.tr()}',
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
  final ToothStateModel diagnosis;
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
                    : diagnosis.color.withValues(alpha: 0.08),
            border: Border.all(
              color:
                  isSelected
                      ? Colors.green
                      : diagnosis.color.withValues(alpha: 0.2),
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
                      diagnosis.description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildDetailChip(
                          LocaleKeys.diagnosis_icd_code.tr(),
                          diagnosis.icdCode,
                        ),
                        if (diagnosis.surfaces.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          _buildDetailChip(
                            LocaleKeys.diagnosis_surfaces.tr(),
                            diagnosis.surfaces.join(', '),
                          ),
                        ],
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
