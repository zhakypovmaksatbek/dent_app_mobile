import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/main.dart';
import 'package:dent_app_mobile/models/diagnosis/condition_model.dart';
import 'package:dent_app_mobile/presentation/pages/treatment/core/bloc/condition/condition_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/treatment/core/data/condition_type.dart';
import 'package:dent_app_mobile/presentation/pages/treatment/core/service/condition_service.dart';
import 'package:dent_app_mobile/presentation/pages/treatment/widgets/condition_card.dart';
import 'package:dent_app_mobile/presentation/pages/treatment/widgets/tooth_diagnosis_modal.dart';
import 'package:dent_app_mobile/presentation/widgets/text/app_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

class SelectConditionStep extends StatefulWidget {
  const SelectConditionStep({super.key});

  @override
  State<SelectConditionStep> createState() => _SelectConditionStepState();
}

class _SelectConditionStepState extends State<SelectConditionStep> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearchActive = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
                        Icons.medical_information,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppText(
                        title:
                            LocaleKeys.diagnosis_how_to_select_condition.tr(),
                        textType: TextType.header,
                        fontWeight: FontWeight.w600,
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
                        'Просмотр категорий',
                        'Выберите категорию состояния зуба из доступных вариантов',
                        Icons.category,
                      ),
                      const SizedBox(height: 12),
                      _buildInstructionStep(
                        context,
                        '2',
                        'Поиск состояния',
                        'Используйте поле поиска для быстрого нахождения конкретного состояния',
                        Icons.search,
                      ),
                      const SizedBox(height: 12),
                      _buildInstructionStep(
                        context,
                        '3',
                        'Выбор состояния',
                        'Нажмите на карточку состояния или выберите из детального списка',
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
                    child: Text(
                      LocaleKeys.buttons_ok.tr(),
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
    return BlocBuilder<ConditionCubit, ConditionState>(
      builder: (context, state) {
        if (state is ConditionLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ),
          );
        } else if (state is ConditionError) {
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
                    onPressed: () {
                      context.read<ConditionCubit>().getConditionList(
                        ConditionType.mains,
                      );
                    },
                    icon: const Icon(Icons.refresh),
                    label: Text(LocaleKeys.buttons_retry.tr()),
                  ),
                ],
              ),
            ),
          );
        } else if (state is ConditionLoaded) {
          final conditionModels = state.conditions;

          return Consumer<ConditionService>(
            builder:
                (context, conditionService, child) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Step Info with Tooltip
                    Row(
                      children: [
                        AppText(
                          title: LocaleKeys.diagnosis_select_condition.tr(),
                          textType: TextType.header,
                          fontWeight: FontWeight.w600,
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => _showInstructions(context),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.help_outline,
                              size: 16,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Search Field
                    _buildSearchField(),
                    const SizedBox(height: 16),

                    // Grid View
                    Expanded(
                      child: _buildGridView(conditionModels, conditionService),
                    ),
                  ],
                ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildSearchField() {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              _isSearchActive
                  ? theme.primaryColor
                  : theme.dividerColor.withValues(alpha: 0.3),
        ),
      ),
      child: TextField(
        controller: _searchController,
        onTap: () {
          setState(() {
            _isSearchActive = true;
          });
        },
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        onTapOutside: (event) {
          FocusScope.of(context).unfocus();
        },
        decoration: InputDecoration(
          hintText: 'Поиск состояний...',
          prefixIcon: Icon(
            Icons.search,
            color: _isSearchActive ? theme.primaryColor : theme.hintColor,
          ),
          suffixIcon:
              _isSearchActive
                  ? IconButton(
                    icon: Icon(Icons.clear, color: theme.hintColor),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                        _isSearchActive = false;
                        FocusScope.of(context).unfocus();
                      });
                    },
                  )
                  : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildGridView(
    List<ConditionModel> conditionModels,
    ConditionService conditionService,
  ) {
    if (_isSearchActive) {
      // Search mode: Show individual conditions
      final allConditions = _flattenConditions(conditionModels);
      final filteredConditions = _filterIndividualConditions(allConditions);

      if (filteredConditions.isEmpty) {
        return _buildNoResultsWidget();
      }

      return GridView.builder(
        padding: EdgeInsets.zero,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 2,
          mainAxisExtent: 100,
        ),
        itemBuilder:
            (context, index) => ConditionCard(
              category: _createConditionModelFromCondition(
                filteredConditions[index],
              ),
              selectedDiagnosis: conditionService.condition,
              onTap:
                  (category) => _handleIndividualConditionSelection(
                    filteredConditions[index],
                    conditionService,
                  ),
              isSelected:
                  conditionService.condition?.id ==
                  filteredConditions[index].id,
            ),
        itemCount: filteredConditions.length,
      );
    } else {
      // Normal mode: Show ConditionModels
      return GridView.builder(
        padding: EdgeInsets.zero,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 2,
          mainAxisExtent: 100,
        ),
        itemBuilder:
            (context, index) => ConditionCard(
              category: conditionModels[index],
              selectedDiagnosis: conditionService.condition,
              onTap:
                  (category) => _handleDiagnosisSelection(
                    context,
                    conditionModels[index],
                    (diagnosis) {
                      conditionService.setCondition(diagnosis);
                    },
                    conditionService,
                  ),
              isSelected:
                  conditionService.condition?.code ==
                  conditionModels[index].code,
            ),
        itemCount: conditionModels.length,
      );
    }
  }

  List<Conditions> _flattenConditions(List<ConditionModel> conditionModels) {
    List<Conditions> allConditions = [];
    for (var model in conditionModels) {
      if (model.conditions != null) {
        allConditions.addAll(model.conditions!);
      }
    }
    return allConditions;
  }

  List<Conditions> _filterIndividualConditions(List<Conditions> conditions) {
    if (_searchQuery.isEmpty) return conditions;

    return conditions.where((condition) {
      final name = condition.name?.toLowerCase() ?? '';
      final code = condition.code?.toLowerCase() ?? '';
      final query = _searchQuery.toLowerCase();

      return name.contains(query) || code.contains(query);
    }).toList();
  }

  ConditionModel _createConditionModelFromCondition(Conditions condition) {
    return ConditionModel(
      code: condition.code,
      codeName: condition.name,
      codeDescription: condition.name,

      conditions: [condition],
    );
  }

  void _handleIndividualConditionSelection(
    Conditions condition,
    ConditionService conditionService,
  ) {
    conditionService.setCondition(condition);
    // Deactivate search after selection
    setState(() {
      _isSearchActive = false;
      _searchQuery = '';
      _searchController.clear();
    });
  }

  Widget _buildNoResultsWidget() {
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
                'Состояния не найдены',
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

  void _handleDiagnosisSelection(
    BuildContext context,
    ConditionModel conditions,
    ValueChanged<Conditions> onSelect,
    ConditionService conditionService,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      clipBehavior: Clip.antiAlias,
      builder:
          (_) => DiagnosisDetailsModal(
            conditions: conditions,
            selectedCondition: conditionService.condition,
            onSelect: (condition) {
              onSelect(condition);
              router.maybePop();
            },
          ),
    );
  }
}
