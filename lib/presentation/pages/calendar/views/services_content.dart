import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/main.dart';
import 'package:dent_app_mobile/models/service/service_model.dart';
import 'package:dent_app_mobile/presentation/pages/calendar/bloc/save_service/save_service_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/services/core/bloc/get_service/get_service_cubit.dart';
import 'package:dent_app_mobile/presentation/theme/colors/color_constants.dart';
import 'package:dent_app_mobile/presentation/widgets/buttons/def_elevated_button.dart';
import 'package:dent_app_mobile/presentation/widgets/loading/loading_widget.dart';
import 'package:dent_app_mobile/presentation/widgets/snack_bars/app_snack_bar.dart';
import 'package:dent_app_mobile/presentation/widgets/text/app_text.dart';
import 'package:dent_app_mobile/router/app_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ServicesContent extends StatefulWidget {
  final int appointmentId;

  const ServicesContent({super.key, required this.appointmentId});

  @override
  State<ServicesContent> createState() => _ServicesContentState();
}

class _ServicesContentState extends State<ServicesContent> {
  late final GetServiceCubit _serviceCubit;
  late final SaveServiceCubit _fastPayCubit;
  final TextEditingController _searchController = TextEditingController();

  final Set<int> _selectedServiceIds = {};
  final Map<int, String> _serviceTypeMap = {};
  final Map<int, double> _servicePriceMap = {};
  final Set<String> _expandedCategories = {};

  String _searchQuery = '';
  List<ServiceModel> _originalServices = [];
  List<ServiceModel> _filteredServices = [];

  @override
  void initState() {
    super.initState();
    _serviceCubit = GetServiceCubit();
    _fastPayCubit = SaveServiceCubit();
    _serviceCubit.getServices();
  }

  @override
  void dispose() {
    _serviceCubit.close();
    _fastPayCubit.close();
    _searchController.dispose();
    super.dispose();
  }

  // MARK: - State Management
  void _toggleCategoryExpansion(String category) {
    setState(() {
      if (_expandedCategories.contains(category)) {
        _expandedCategories.remove(category);
      } else {
        _expandedCategories.add(category);
      }
    });
  }

  void _toggleServiceSelection(int serviceId) {
    setState(() {
      if (_selectedServiceIds.contains(serviceId)) {
        _selectedServiceIds.remove(serviceId);
      } else {
        _selectedServiceIds.add(serviceId);
      }
    });
  }

  double get _totalAmount => _selectedServiceIds.fold<double>(
    0.0,
    (total, serviceId) => total + (_servicePriceMap[serviceId] ?? 0.0),
  );

  // MARK: - Search Methods
  void _updateSearchQuery(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      _filteredServices = _filterServices();
    });
  }

  List<ServiceModel> _filterServices() {
    if (_searchQuery.isEmpty) {
      return List.from(_originalServices);
    }

    return _originalServices
        .where((service) {
          // Kategori adına göre arama
          final categoryName =
              _formatServiceTypeName(service.serviceType ?? '').toLowerCase();
          final categoryMatches = categoryName.contains(_searchQuery);

          // Servis adlarına göre arama
          final hasMatchingService =
              service.serviceItem?.any((item) {
                final serviceName = (item.name ?? '').toLowerCase();
                return serviceName.contains(_searchQuery);
              }) ??
              false;

          return categoryMatches || hasMatchingService;
        })
        .map((service) {
          // Eğer kategori adı eşleşmiyorsa, sadece eşleşen servisleri göster
          final categoryName =
              _formatServiceTypeName(service.serviceType ?? '').toLowerCase();
          if (!categoryName.contains(_searchQuery)) {
            final filteredItems =
                service.serviceItem?.where((item) {
                  final serviceName = (item.name ?? '').toLowerCase();
                  return serviceName.contains(_searchQuery);
                }).toList() ??
                [];

            return ServiceModel(
              serviceType: service.serviceType,
              serviceItem: filteredItems,
            );
          }
          return service;
        })
        .toList();
  }

  void _updateServicesData(List<ServiceModel> services) {
    setState(() {
      _originalServices = services;
      _filteredServices = _filterServices();
    });
  }

  // MARK: - Business Logic
  void _processPayment() {
    if (_selectedServiceIds.isEmpty) {
      AppSnackBar.showErrorSnackBar(
        context,
        LocaleKeys.notifications_please_select_at_least_one_service.tr(),
      );
      return;
    }

    _fastPayCubit.fastPay(widget.appointmentId, _selectedServiceIds.toList());
  }

  // MARK: - UI Components
  Widget _buildHeader() {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  title: LocaleKeys.routes_services.tr(),
                  textType: TextType.title24,
                ),
                const SizedBox(height: 4),
                AppText(
                  title: LocaleKeys.general_select_services_for_payment.tr(),
                  textType: TextType.body,
                  color: AppColors.grey,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => router.pop(),
            icon: Icon(Icons.close, color: theme.colorScheme.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightGrey),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _updateSearchQuery,
        decoration: InputDecoration(
          hintText: 'Поиск услуг...',
          hintStyle: TextStyle(color: AppColors.grey),
          prefixIcon: Icon(Icons.search, color: AppColors.grey),
          suffixIcon:
              _searchQuery.isNotEmpty
                  ? IconButton(
                    icon: Icon(Icons.clear, color: AppColors.grey),
                    onPressed: () {
                      _searchController.clear();
                      _updateSearchQuery('');
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

  Widget _buildTotalAmountCard() {
    if (_selectedServiceIds.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary.withValues(alpha: 0.8), AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                title: LocaleKeys.general_total_amount.tr(),
                textType: TextType.header,
                color: AppColors.white,
              ),
              const SizedBox(height: 4),
              AppText(
                title: LocaleKeys.general_total_services_selected.tr(
                  namedArgs: {'count': _selectedServiceIds.length.toString()},
                ),
                textType: TextType.description,
                color: AppColors.white.withValues(alpha: 0.8),
              ),
            ],
          ),
          AppText(
            title: _totalAmount.toStringAsFixed(0),
            textType: TextType.title,
            color: AppColors.white,
            fontWeight: FontWeight.bold,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(ServiceModel category) {
    final isExpanded = _expandedCategories.contains(category.serviceType);
    final services = category.serviceItem ?? [];
    final selectedCount =
        services
            .where(
              (service) =>
                  service.id != null &&
                  _selectedServiceIds.contains(service.id),
            )
            .length;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightGrey, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildCategoryHeader(
            category,
            isExpanded,
            services.length,
            selectedCount,
          ),
          if (isExpanded) _buildServicesList(category, services),
        ],
      ),
    );
  }

  Widget _buildCategoryHeader(
    ServiceModel category,
    bool isExpanded,
    int serviceCount,
    int selectedCount,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        onTap: () => _toggleCategoryExpansion(category.serviceType ?? ''),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _buildCategoryIcon(),
              const SizedBox(width: 12),
              Expanded(child: _buildCategoryDetails(category, serviceCount)),
              if (selectedCount > 0) _buildSelectionBadge(selectedCount),
              const SizedBox(width: 8),
              _buildExpandIcon(isExpanded),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryIcon() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(Icons.category, size: 20, color: AppColors.primary),
    );
  }

  Widget _buildCategoryDetails(ServiceModel category, int serviceCount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          title: _formatServiceTypeName(category.serviceType ?? 'NO_CATEGORY'),
          textType: TextType.title,
          fontWeight: FontWeight.w600,
        ),
        const SizedBox(height: 2),
        AppText(
          title: '$serviceCount услуг',
          textType: TextType.description,
          color: AppColors.grey,
        ),
      ],
    );
  }

  Widget _buildSelectionBadge(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: AppText(
        title: count.toString(),
        textType: TextType.description,
        color: AppColors.white,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildExpandIcon(bool isExpanded) {
    return Icon(
      isExpanded ? Icons.expand_less : Icons.expand_more,
      color: AppColors.grey,
      size: 24,
    );
  }

  Widget _buildServicesList(ServiceModel category, List<ServiceItem> services) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightGrey.withValues(alpha: 0.3),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: services.length,
        itemBuilder:
            (context, index) => _buildServiceItem(services[index], category),
      ),
    );
  }

  Widget _buildServiceItem(ServiceItem service, ServiceModel category) {
    final isSelected =
        service.id != null && _selectedServiceIds.contains(service.id);

    // Cache service info
    if (service.id != null) {
      _serviceTypeMap[service.id!] = category.serviceType ?? 'NO_CATEGORY';
      _servicePriceMap[service.id!] = service.price ?? 0.0;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color:
            isSelected
                ? AppColors.primary.withValues(alpha: 0.1)
                : AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isSelected
                  ? AppColors.primary.withValues(alpha: 0.4)
                  : AppColors.lightGrey,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            if (service.id != null) {
              _toggleServiceSelection(service.id!);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _buildServiceSelectionIndicator(isSelected),
                const SizedBox(width: 12),
                Expanded(child: _buildServiceDetails(service, isSelected)),
                _buildServicePrice(service, isSelected),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServiceSelectionIndicator(bool isSelected) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? AppColors.primary : AppColors.lightGrey,
        border: Border.all(
          color:
              isSelected
                  ? AppColors.primary.withValues(alpha: 0.4)
                  : AppColors.lightGrey,
          width: 2,
        ),
      ),
      child:
          isSelected
              ? const Icon(Icons.check, size: 10, color: AppColors.white)
              : null,
    );
  }

  Widget _buildServiceDetails(ServiceItem service, bool isSelected) {
    return AppText(
      title: service.name ?? 'Без названия',
      textType: TextType.body,
      fontWeight: FontWeight.w500,
      color: isSelected ? AppColors.primary : AppColors.black,
    );
  }

  Widget _buildServicePrice(ServiceItem service, bool isSelected) {
    return AppText(
      title: service.price?.toStringAsFixed(0) ?? '0',
      textType: TextType.subtitle,
      fontWeight: FontWeight.bold,
      color:
          isSelected
              ? AppColors.primary
              : AppColors.grey.withValues(alpha: 0.8),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BlocBuilder<SaveServiceCubit, SaveServiceState>(
        bloc: _fastPayCubit,
        builder: (context, fastPayState) {
          if (fastPayState is SaveServiceLoading) {
            return const LoadingWidget();
          }
          return SafeArea(
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: DefElevatedButton(
                backgroundColor: AppColors.primary,
                onPressed:
                    fastPayState is SaveServiceLoading ? null : _processPayment,
                title:
                    '${LocaleKeys.buttons_save.tr()} (${_totalAmount.toStringAsFixed(0)})',
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNoResultsWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: AppColors.grey.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            AppText(
              title: 'По вашему запросу услуг не найдено',
              textType: TextType.title,
              color: AppColors.grey,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            AppText(
              title: 'Попробуйте изменить поисковый запрос',
              textType: TextType.body,
              color: AppColors.grey.withValues(alpha: 0.7),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.grey),
            const SizedBox(height: 16),
            AppText(
              title: 'Не удалось загрузить услуги',
              textType: TextType.title20,
              fontWeight: FontWeight.w500,
              color: AppColors.grey,
            ),
          ],
        ),
      ),
    );
  }

  // MARK: - Utilities
  String _formatServiceTypeName(String type) {
    switch (type) {
      case 'NO_CATEGORY':
        return 'Без категории';
      case 'CONSULTATION':
        return 'Консультация';
      case 'X_RAY':
        return 'Рентген';
      case 'ORTHOPEDICS':
        return 'Ортопедия';
      case 'SURGERY_CHILD':
        return 'Детская хирургия';
      case 'THERAPY':
        return 'Терапия';
      case 'SURGERY':
        return 'Хирургия';
      case 'IMPLANTATION':
        return 'Имплантация';
      case 'ORTHODONTICS':
        return 'Ортодонтия';
      case 'ANESTHESIA':
        return 'Анестезия';
      case 'HYGIENE':
        return 'Гигиена';
      case 'PREPS_AND_MATERIALS':
        return 'Препараты и материалы';
      case 'CHILD_DENTISTRY':
        return 'Детская стоматология';
      case 'LABORATORY':
        return 'Лаборатория';
      case 'BONE_SOFT':
        return 'Костная ткань';
      case 'COSMETOLOGY':
        return 'Косметология';
      case 'PEDIATRIC_DENTISTRY':
        return 'Педиатрическая стоматология';
      case 'TECHNICAL_WORKS':
        return 'Технические работы';
      case 'FUNCTIONAL_DIAGNOSTICS':
        return 'Функциональная диагностика';
      case 'DIAGNOSTICS':
        return 'Диагностика';
      case 'GENERAL_EVENTS':
        return 'Общие мероприятия';
      case 'MAXILLOFACIAL_SURGERY':
        return 'Челюстно-лицевая хирургия';
      case 'PREVENTION':
        return 'Профилактика';
      case 'SERVICE':
        return 'Услуга';
      default:
        if (type.isEmpty) return 'Неизвестно';
        return type
            .replaceAll('_', ' ')
            .toLowerCase()
            .split(' ')
            .map(
              (word) =>
                  word.isEmpty
                      ? ''
                      : '${word[0].toUpperCase()}${word.substring(1)}',
            )
            .join(' ');
    }
  }

  // MARK: - Build Method
  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<SaveServiceCubit, SaveServiceState>(
          bloc: _fastPayCubit,
          listener: (context, state) async {
            if (state is SaveServiceSuccess) {
              AppSnackBar.showSuccessSnackBar(context, state.message);
              router.popAndPush(
                PaymentViewRoute(appointmentId: widget.appointmentId),
              );
            } else if (state is SaveServiceError) {
              AppSnackBar.showErrorSnackBar(context, state.message);
            }
          },
        ),
      ],
      child: BlocBuilder<GetServiceCubit, GetServiceState>(
        bloc: _serviceCubit,
        builder: (context, state) {
          if (state is GetServiceLoading) {
            return const LoadingWidget();
          }

          if (state is GetServiceLoaded) {
            // Servisleri güncelle
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _updateServicesData(state.services);
            });

            return Container(
              height: MediaQuery.of(context).size.height * 0.9,
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  _buildHeader(),
                  _buildSearchBar(),
                  _buildTotalAmountCard(),
                  Expanded(
                    child:
                        _filteredServices.isEmpty && _searchQuery.isNotEmpty
                            ? _buildNoResultsWidget()
                            : ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              itemCount: _filteredServices.length,
                              itemBuilder:
                                  (context, index) => _buildCategoryCard(
                                    _filteredServices[index],
                                  ),
                            ),
                  ),
                  _buildSaveButton(),
                ],
              ),
            );
          }

          return _buildErrorState();
        },
      ),
    );
  }
}
