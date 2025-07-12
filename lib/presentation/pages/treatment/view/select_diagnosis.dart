import 'package:dent_app_mobile/models/diagnosis/diagnosis_model.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/diagnosis/core/bloc/all_diagnosis/all_diagnosis_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/treatment/core/service/condition_service.dart';
import 'package:dent_app_mobile/presentation/widgets/text/app_text.dart';
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

  @override
  void initState() {
    super.initState();
    _diagnosisCubit = AllDiagnosisCubit();
    _diagnosisCubit.getDiagnosisList();
  }

  @override
  void dispose() {
    _diagnosisCubit.close();
    super.dispose();
  }

  void _clearAllSelections() {
    context.read<ConditionService>().clearSelectedDiagnosis();
  }

  void _removeDiagnosis(DiagnosisModel diagnosis) {
    context.read<ConditionService>().setSelectedDiagnosis(diagnosis);
  }

  void _showSearchBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder:
          (context) => BlocProvider.value(
            value: _diagnosisCubit,
            child: const _DiagnosisSearchBottomSheet(),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _diagnosisCubit,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Search Field (Read-only, opens bottom sheet)
            GestureDetector(
              onTap: _showSearchBottomSheet,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.2),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).shadowColor.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.search,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Consumer<ConditionService>(
                        builder: (context, conditionService, child) {
                          final selectedCount =
                              conditionService.selectedDiagnosis.length;
                          return Text(
                            selectedCount == 0
                                ? 'Поиск и выбор диагнозов...'
                                : 'Выбрано: $selectedCount диагноз${selectedCount > 1 ? 'ов' : ''}',
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(
                              color:
                                  selectedCount == 0
                                      ? Theme.of(context).colorScheme.onSurface
                                          .withValues(alpha: 0.6)
                                      : Theme.of(context).colorScheme.onSurface,
                            ),
                          );
                        },
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_up,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),

            // Selected Diagnoses Chips
            Consumer<ConditionService>(
              builder: (context, conditionService, child) {
                final selectedDiagnosis = conditionService.selectedDiagnosis;

                if (selectedDiagnosis.isNotEmpty) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Text(
                            'Выбранные диагнозы:',
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const Spacer(),
                          TextButton.icon(
                            onPressed: _clearAllSelections,
                            icon: Icon(
                              Icons.clear_all,
                              size: 16,
                              color: Theme.of(context).colorScheme.error,
                            ),
                            label: Text(
                              'Очистить все',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                                fontSize: 12,
                              ),
                            ),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            selectedDiagnosis.map((diagnosis) {
                              return _buildDiagnosisChip(diagnosis);
                            }).toList(),
                      ),
                    ],
                  );
                }

                // Empty state when no diagnoses selected
                return Container(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height * 0.3,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.medical_information_outlined,
                          size: 64,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Диагнозы не выбраны',
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Нажмите на поле поиска выше,\nчтобы выбрать диагнозы',
                          textAlign: TextAlign.center,
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiagnosisChip(DiagnosisModel diagnosis) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              diagnosis.name ?? 'Без названия',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _removeDiagnosis(diagnosis),
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(
                Icons.close,
                size: 12,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Bottom Sheet Widget for Search and Selection
class _DiagnosisSearchBottomSheet extends StatefulWidget {
  const _DiagnosisSearchBottomSheet();

  @override
  State<_DiagnosisSearchBottomSheet> createState() =>
      _DiagnosisSearchBottomSheetState();
}

class _DiagnosisSearchBottomSheetState
    extends State<_DiagnosisSearchBottomSheet>
    with TickerProviderStateMixin {
  late final TextEditingController _searchController;
  late final FocusNode _searchFocusNode;
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;

  List<DiagnosisModel> _allDiagnosis = [];
  List<DiagnosisModel> _filteredDiagnosis = [];
  final Set<DiagnosisModel> _tempSelectedDiagnosis = {};

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _searchController.addListener(_onSearchChanged);

    // Load existing selections from ConditionService and auto focus
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final conditionService = context.read<ConditionService>();
      setState(() {
        _tempSelectedDiagnosis.clear();
        _tempSelectedDiagnosis.addAll(conditionService.selectedDiagnosis);
      });

      _searchFocusNode.requestFocus();

      // Check if data is already loaded
      final diagnosisCubit = context.read<AllDiagnosisCubit>();
      final currentState = diagnosisCubit.state;

      if (currentState is AllDiagnosisLoaded) {
        setState(() {
          _allDiagnosis = currentState.diagnosisList;
          _filteredDiagnosis = currentState.diagnosisList;
        });
        _animationController.forward();
      } else if (currentState is AllDiagnosisInitial) {
        diagnosisCubit.getDiagnosisList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _filterDiagnosis(_searchController.text);
    });
  }

  void _filterDiagnosis(String query) {
    if (query.isEmpty) {
      _filteredDiagnosis = List.from(_allDiagnosis);
    } else {
      _filteredDiagnosis =
          _allDiagnosis
              .where(
                (diagnosis) =>
                    diagnosis.name?.toLowerCase().contains(
                      query.toLowerCase(),
                    ) ??
                    false,
              )
              .toList();
    }
  }

  void _toggleDiagnosis(DiagnosisModel diagnosis) {
    setState(() {
      if (_tempSelectedDiagnosis.contains(diagnosis)) {
        _tempSelectedDiagnosis.remove(diagnosis);
      } else {
        _tempSelectedDiagnosis.add(diagnosis);
      }
    });

    // Apply selection immediately to ConditionService and close bottom sheet
    final conditionService = context.read<ConditionService>();
    conditionService.setSelectedDiagnosis(diagnosis);
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _filterDiagnosis('');
    });
  }

  void _clearAllSelections() {
    setState(() {
      _tempSelectedDiagnosis.clear();
    });
    context.read<ConditionService>().clearSelectedDiagnosis();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final fixedHeight = screenHeight * 0.85;

    return Container(
      height: fixedHeight,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 8, bottom: 16),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  'Поиск диагнозов',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                if (_tempSelectedDiagnosis.isNotEmpty)
                  TextButton(
                    onPressed: _clearAllSelections,
                    child: Text(
                      'Очистить все',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 14,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Selected count
          if (_tempSelectedDiagnosis.isNotEmpty)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Выбрано: ${_tempSelectedDiagnosis.length}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

          const SizedBox(height: 16),

          // Search field
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              decoration: InputDecoration(
                hintText: 'Введите название диагноза...',
                hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                suffixIcon:
                    _searchController.text.isNotEmpty
                        ? IconButton(
                          onPressed: _clearSearch,
                          icon: Icon(
                            Icons.clear,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.5),
                            size: 18,
                          ),
                        )
                        : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),

          const SizedBox(height: 16),

          // Diagnosis list
          Flexible(
            child: BlocConsumer<AllDiagnosisCubit, AllDiagnosisState>(
              listener: (context, state) {
                if (state is AllDiagnosisLoaded) {
                  setState(() {
                    _allDiagnosis = state.diagnosisList;
                    _filteredDiagnosis = state.diagnosisList;
                  });
                  _animationController.forward();
                }
              },
              builder: (context, state) {
                if (state is AllDiagnosisLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is AllDiagnosisError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Ошибка загрузки диагнозов',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.message,
                          style: Theme.of(context).textTheme.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed:
                              () =>
                                  context
                                      .read<AllDiagnosisCubit>()
                                      .getDiagnosisList(),
                          child: const Text('Повторить'),
                        ),
                      ],
                    ),
                  );
                }

                if (_filteredDiagnosis.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
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
                          'Ничего не найдено',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Попробуйте изменить поисковый запрос',
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredDiagnosis.length,
                    separatorBuilder:
                        (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final diagnosis = _filteredDiagnosis[index];
                      final isSelected = _tempSelectedDiagnosis.contains(
                        diagnosis,
                      );

                      return _buildDiagnosisItem(diagnosis, isSelected);
                    },
                  ),
                );
              },
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 12),
        ],
      ),
    );
  }

  Widget _buildDiagnosisItem(DiagnosisModel diagnosis, bool isSelected) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _toggleDiagnosis(diagnosis),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color:
                        isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.outline,
                    width: 2,
                  ),
                ),
                child:
                    isSelected
                        ? Icon(
                          Icons.check,
                          size: 14,
                          color: Theme.of(context).colorScheme.onPrimary,
                        )
                        : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      title: diagnosis.name ?? 'Без названия',
                      textType: TextType.body,
                      fontWeight: FontWeight.w500,
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
