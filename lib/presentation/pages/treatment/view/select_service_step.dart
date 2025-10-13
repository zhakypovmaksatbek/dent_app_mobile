import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/main.dart';
import 'package:dent_app_mobile/models/service/service_model.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/services/core/bloc/get_service_item/get_service_item_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/treatment/core/service/condition_service.dart';
import 'package:dent_app_mobile/presentation/pages/treatment/widgets/service_card.dart';
import 'package:dent_app_mobile/presentation/widgets/buttons/def_elevated_button.dart';
import 'package:dent_app_mobile/presentation/widgets/text/app_text.dart';
import 'package:dent_app_mobile/presentation/widgets/text/price_convert_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

class SelectServiceStep extends StatefulWidget {
  const SelectServiceStep({super.key});

  @override
  State<SelectServiceStep> createState() => _SelectServiceStepState();
}

class _SelectServiceStepState extends State<SelectServiceStep> {
  late final GetServiceItemCubit _serviceCubit;

  @override
  void initState() {
    super.initState();
    _serviceCubit = GetServiceItemCubit();
    _serviceCubit.getServiceItems(); // Load all services initially
  }

  @override
  void dispose() {
    _serviceCubit.close();
    super.dispose();
  }

  void _removeService(ServiceItem service) {
    context.read<ConditionService>().setServiceCount(service, 0);
  }

  void _clearAllServices() {
    context.read<ConditionService>().clearSelectedServices();
  }

  void _showSearchBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder:
          (context) => BlocProvider.value(
            value: _serviceCubit,
            child: const _ServiceSearchBottomSheet(),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _serviceCubit,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                              conditionService.selectedServices.length;
                          final totalCount =
                              conditionService.totalServicesCount;

                          return Text(
                            selectedCount == 0
                                ? 'Поиск и выбор услуг...'
                                : 'Выбрано: $selectedCount услуг${selectedCount > 1 ? '' : 'а'} ($totalCount шт.)',
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

            // Selected Services Chips
            Consumer<ConditionService>(
              builder: (context, conditionService, child) {
                final selectedServices = conditionService.selectedServices;

                if (selectedServices.isNotEmpty) {
                  return Column(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Text(
                                'Выбранные услуги:',
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              const Spacer(),
                              TextButton.icon(
                                onPressed: _clearAllServices,
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
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // DEĞİŞİKLİK: ConstrainedBox yerine Flexible/Expanded kullan
                          // Ekranın %25'i
                          Column(
                            spacing: 8,
                            children:
                                selectedServices.entries.map((entry) {
                                  return _buildServiceChip(
                                    entry.key,
                                    entry.value,
                                  );
                                }).toList(),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Total sum
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          AppText(
                            title: "${LocaleKeys.report_total_amount.tr()}:",
                            textType: TextType.title24,
                            fontWeight: FontWeight.w600,
                            color:
                                Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
                          ),
                          PriceConvertWidget(
                            price: conditionService.totalServicesSum,
                            textType: TextType.title24,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ],
                      ),
                    ],
                  );
                }

                // Empty state
                return Container(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height * 0.3,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.medical_services_outlined,
                          size: 64,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Услуги не выбраны',
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Нажмите на поле поиска выше,\nчтобы выбрать услуги',
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

  Widget _buildServiceChip(ServiceItem service, int count) {
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Service name - Flexible ile wrap et
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  service.name ?? 'Без названия',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (count > 1)
                  Text(
                    'Количество: $count',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.7),
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Buttons group - Fixed width
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Decrement button
              _CompactIconButton(
                icon: Icons.remove,
                onPressed: () => _decrementService(service),
              ),
              const SizedBox(width: 4),
              // Increment button
              _CompactIconButton(
                icon: Icons.add,
                onPressed: () => _incrementService(service),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _incrementService(ServiceItem service) {
    final conditionService = context.read<ConditionService>();
    conditionService.addService(service);
  }

  void _decrementService(ServiceItem service) {
    final conditionService = context.read<ConditionService>();
    conditionService.removeService(service);
  }
}

class _CompactIconButton extends StatelessWidget {
  const _CompactIconButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(
          icon,
          size: 22,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

// Bottom Sheet Widget for Search and Selection
class _ServiceSearchBottomSheet extends StatefulWidget {
  const _ServiceSearchBottomSheet();

  @override
  State<_ServiceSearchBottomSheet> createState() =>
      _ServiceSearchBottomSheetState();
}

class _ServiceSearchBottomSheetState extends State<_ServiceSearchBottomSheet>
    with TickerProviderStateMixin {
  late final TextEditingController _searchController;
  late final FocusNode _searchFocusNode;
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;

  List<ServiceItem> _allServices = [];
  List<ServiceItem> _filteredServices = [];
  String _currentSearchQuery = '';

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

    // Auto focus search field and load data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
      // Check if data is already loaded
      final serviceCubit = context.read<GetServiceItemCubit>();
      final currentState = serviceCubit.state;

      if (currentState is GetServiceItemLoaded) {
        setState(() {
          _allServices = currentState.serviceItems;
          _filteredServices = currentState.serviceItems;
        });
        _animationController.forward();
      } else if (currentState is GetServiceItemInitial) {
        serviceCubit.getServiceItems();
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
    _debounceSearch();
  }

  void _debounceSearch() {
    // Simple debounce implementation
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted && _searchController.text == _currentSearchQuery) {
        _performSearch();
      }
    });
    _currentSearchQuery = _searchController.text;
  }

  void _performSearch() {
    final query = _searchController.text.trim();

    // If query is empty, show all services
    if (query.isEmpty) {
      setState(() {
        _filteredServices = List.from(_allServices);
      });
    } else {
      // Filter locally first
      final localResults =
          _allServices
              .where(
                (service) =>
                    service.name?.toLowerCase().contains(query.toLowerCase()) ??
                    false,
              )
              .toList();

      setState(() {
        _filteredServices = localResults;
      });

      // Also perform server search
      context.read<GetServiceItemCubit>().getServiceItems(search: query);
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _currentSearchQuery = '';
      _filteredServices = List.from(_allServices);
    });
    context.read<GetServiceItemCubit>().getServiceItems();
  }

  void _toggleService(ServiceItem service) {
    final conditionService = context.read<ConditionService>();
    conditionService.toggleService(service);
  }

  void _incrementService(ServiceItem service) {
    final conditionService = context.read<ConditionService>();
    conditionService.addService(service);
  }

  void _decrementService(ServiceItem service) {
    final conditionService = context.read<ConditionService>();
    conditionService.removeService(service);
  }

  void _clearAllSelections() {
    final conditionService = context.read<ConditionService>();
    conditionService.clearSelectedServices();
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
                  'Поиск услуг',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                Consumer<ConditionService>(
                  builder: (context, conditionService, child) {
                    if (conditionService.selectedServices.isNotEmpty) {
                      return TextButton(
                        onPressed: _clearAllSelections,
                        child: Text(
                          'Очистить все',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: 14,
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),

          // Selected count
          Consumer<ConditionService>(
            builder: (context, conditionService, child) {
              if (conditionService.selectedServices.isNotEmpty) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Выбрано: ${conditionService.selectedServices.length} услуг (${conditionService.totalServicesCount} шт.)',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
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
              onTapOutside: (event) {
                _searchFocusNode.unfocus();
              },
              decoration: InputDecoration(
                hintText: 'Введите название услуги...',
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

          // Services list
          Flexible(
            child: BlocConsumer<GetServiceItemCubit, GetServiceItemState>(
              listener: (context, state) {
                if (state is GetServiceItemLoaded) {
                  setState(() {
                    _allServices = state.serviceItems;
                    if (_currentSearchQuery.isEmpty) {
                      _filteredServices = state.serviceItems;
                    }
                  });
                  _animationController.forward();
                } else if (state is GetServiceItemError) {
                  // Error handling if needed
                }
              },
              builder: (context, state) {
                if (state is GetServiceItemLoading && _allServices.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is GetServiceItemError && _allServices.isEmpty) {
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
                          'Ошибка загрузки услуг',
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
                                      .read<GetServiceItemCubit>()
                                      .getServiceItems(),
                          child: const Text('Повторить'),
                        ),
                      ],
                    ),
                  );
                }

                if (_filteredServices.isEmpty) {
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
                          LocaleKeys.notifications_services_not_found.tr(),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          LocaleKeys.notifications_try_changing_search_query
                              .tr(),
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Search results info
                      if (_currentSearchQuery.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.secondary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.search,
                                size: 16,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${LocaleKeys.diagnosis_search_services.tr()}: "$_currentSearchQuery" (${_filteredServices.length} ${LocaleKeys.notifications_results.tr()})',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodySmall?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 8),

                      // Services list
                      Flexible(
                        child: ListView.separated(
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filteredServices.length,
                          separatorBuilder:
                              (context, index) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final service = _filteredServices[index];

                            return Consumer<ConditionService>(
                              builder: (context, conditionService, child) {
                                final isSelected = conditionService
                                    .isServiceSelected(service);
                                final count = conditionService.getServiceCount(
                                  service,
                                );

                                return ServiceCard(
                                  service: service,
                                  isSelected: isSelected,
                                  count: count,
                                  onTap: () => _toggleService(service),
                                  onIncrement: () => _incrementService(service),
                                  onDecrement: () => _decrementService(service),
                                );
                              },
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: DefElevatedButton(
                          title: LocaleKeys.buttons_apply.tr(),

                          onPressed: () {
                            router.maybePop();
                          },
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).padding.bottom),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
