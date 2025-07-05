import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/models/diagnosis/diagnosis_model.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/diagnosis/core/bloc/all_diagnosis/all_diagnosis_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/treatment/core/service/condition_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

class SelectDiagnosisStep extends StatefulWidget {
  const SelectDiagnosisStep({super.key});

  @override
  State<SelectDiagnosisStep> createState() => _SelectDiagnosisStepState();
}

class _SelectDiagnosisStepState extends State<SelectDiagnosisStep> {
  late final AllDiagnosisCubit _diagnosisCubit;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<DiagnosisModel> _diagnosisList = [];
  List<DiagnosisModel> _filteredDiagnosisList = [];

  @override
  void initState() {
    super.initState();
    _diagnosisCubit = AllDiagnosisCubit();
    _diagnosisCubit.getDiagnosisList();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredDiagnosisList = _diagnosisList;
      } else {
        _filteredDiagnosisList =
            _diagnosisList
                .where(
                  (diagnosis) =>
                      (diagnosis.name?.toLowerCase().contains(query) ??
                          false) ||
                      diagnosis.id.toString().contains(query),
                )
                .toList();
      }
    });
  }

  void _toggleDiagnosis(DiagnosisModel diagnosis) {
    context.read<ConditionService>().setSelectedDiagnosis(diagnosis);
  }

  void _showInstructions(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Theme.of(context).colorScheme.surface,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.psychology,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Как выбрать диагнозы',
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                      style: IconButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.surface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInstructionStep(
                        context,
                        '1',
                        'Множественный выбор',
                        'Выберите один или несколько диагнозов. Можно выбрать несколько для комплексного лечения',
                        Icons.checklist,
                      ),
                      const SizedBox(height: 12),
                      _buildInstructionStep(
                        context,
                        '2',
                        'Поиск диагнозов',
                        'Введите название диагноза или его код в поле поиска для быстрого поиска',
                        Icons.search,
                      ),
                      const SizedBox(height: 12),
                      _buildInstructionStep(
                        context,
                        '3',
                        'Управление выбором',
                        'Нажмите на карточку для добавления/удаления. Выбранные диагнозы отмечены галочкой',
                        Icons.touch_app,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Понятно',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInstructionStep(
    BuildContext context,
    String stepNumber,
    String title,
    String description,
    IconData icon,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              stepNumber,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _diagnosisCubit,
      child: BlocConsumer<AllDiagnosisCubit, AllDiagnosisState>(
        listener: (context, state) {
          if (state is AllDiagnosisLoaded) {
            setState(() {
              _diagnosisList = state.diagnosisList;
              _filteredDiagnosisList = state.diagnosisList;
            });
          }
        },
        builder: (context, state) {
          if (state is AllDiagnosisLoading) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (state is AllDiagnosisError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => _diagnosisCubit.getDiagnosisList(),
                      icon: const Icon(Icons.refresh),
                      label: Text(LocaleKeys.buttons_retry.tr()),
                    ),
                  ],
                ),
              ),
            );
          }

          return Consumer<ConditionService>(
            builder:
                (context, conditionService, child) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with selected count
                    _buildHeader(context, conditionService),
                    const SizedBox(height: 16),

                    // Search Field
                    _buildSearchField(context),
                    const SizedBox(height: 16),

                    // Results Count
                    if (_filteredDiagnosisList.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          'Найдено: ${_filteredDiagnosisList.length} диагнозов',
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ),

                    // Diagnosis List
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(
                              context,
                            ).dividerColor.withValues(alpha: 0.3),
                          ),
                        ),
                        child:
                            _filteredDiagnosisList.isEmpty
                                ? _buildEmptyState()
                                : ListView.separated(
                                  padding: const EdgeInsets.all(8),
                                  itemCount: _filteredDiagnosisList.length,
                                  separatorBuilder:
                                      (context, index) => const Divider(
                                        height: 16,
                                        thickness: 0.5,
                                      ),
                                  itemBuilder: (context, index) {
                                    final diagnosis =
                                        _filteredDiagnosisList[index];
                                    final isSelected = conditionService
                                        .selectedDiagnosis
                                        .any((d) => d.id == diagnosis.id);

                                    return _ModernDiagnosisCard(
                                      diagnosis: diagnosis,
                                      isSelected: isSelected,
                                      onTap: () => _toggleDiagnosis(diagnosis),
                                    );
                                  },
                                ),
                      ),
                    ),
                  ],
                ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ConditionService conditionService) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Выбор диагнозов',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              if (conditionService.selectedDiagnosis.isNotEmpty) ...[
                const SizedBox(height: 4),
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
                  child: Text(
                    'Выбрано: ${conditionService.selectedDiagnosis.length}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        GestureDetector(
          onTap: () => _showInstructions(context),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.help_outline,
              size: 18,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        if (conditionService.selectedDiagnosis.isNotEmpty) ...[
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => conditionService.clearSelectedDiagnosis(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.clear_all, size: 18, color: Colors.red),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
        ),
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        decoration: InputDecoration(
          hintText: 'Поиск по названию или коду...',
          prefixIcon: Icon(
            Icons.search,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          suffixIcon:
              _searchController.text.isNotEmpty
                  ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      _searchFocusNode.unfocus();
                    },
                  )
                  : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search_off,
                size: 48,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'Диагнозы не найдены',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Попробуйте изменить поисковый запрос',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Modern diagnosis card widget for multiple selection
class _ModernDiagnosisCard extends StatelessWidget {
  final DiagnosisModel diagnosis;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModernDiagnosisCard({
    required this.diagnosis,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color:
                isSelected
                    ? theme.colorScheme.primary.withValues(alpha: 0.1)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border:
                isSelected
                    ? Border.all(color: theme.colorScheme.primary, width: 2)
                    : null,
            boxShadow:
                isSelected
                    ? [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: 0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ]
                    : null,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            diagnosis.name ?? 'Без названия',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color:
                                  isSelected
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                        AnimatedScale(
                          scale: isSelected ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 200),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
