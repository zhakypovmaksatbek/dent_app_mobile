import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/main.dart';
import 'package:dent_app_mobile/models/service/service_model.dart';
import 'package:dent_app_mobile/presentation/pages/calendar/bloc/save_service/save_service_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/services/core/bloc/get_service_item/get_service_item_cubit.dart';
import 'package:dent_app_mobile/presentation/theme/colors/color_constants.dart';
import 'package:dent_app_mobile/presentation/widgets/buttons/def_elevated_button.dart';
import 'package:dent_app_mobile/presentation/widgets/loading/loading_widget.dart';
import 'package:dent_app_mobile/presentation/widgets/snack_bars/app_snack_bar.dart';
import 'package:dent_app_mobile/presentation/widgets/text/app_text.dart';
import 'package:dent_app_mobile/presentation/widgets/text/price_convert_widget.dart';
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
  late final GetServiceItemCubit _serviceCubit;
  late final SaveServiceCubit _fastPayCubit;
  final TextEditingController _searchController = TextEditingController();

  final Set<int> _selectedServiceIds = {};
  final Map<int, double> _servicePriceMap = {};

  String _searchQuery = '';
  List<ServiceItem> _originalServices = [];
  List<ServiceItem> _filteredServices = [];

  @override
  void initState() {
    super.initState();
    _serviceCubit = GetServiceItemCubit();
    _fastPayCubit = SaveServiceCubit();
    _serviceCubit.getServiceItems();
  }

  @override
  void dispose() {
    _serviceCubit.close();
    _fastPayCubit.close();
    _searchController.dispose();
    super.dispose();
  }

  // MARK: - State Management
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

  List<ServiceItem> _filterServices() {
    if (_searchQuery.isEmpty) {
      return List.from(_originalServices);
    }

    return _originalServices.where((service) {
      final serviceName = (service.name ?? '').toLowerCase();
      return serviceName.contains(_searchQuery);
    }).toList();
  }

  void _updateServicesData(List<ServiceItem> services) {
    setState(() {
      _originalServices = services;
      _filteredServices = _filterServices();

      // Update price map
      _servicePriceMap.clear();
      for (final service in services) {
        if (service.id != null) {
          _servicePriceMap[service.id!] = service.price ?? 0.0;
        }
      }
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
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: TextField(
        controller: _searchController,
        onChanged: _updateSearchQuery,
        decoration: InputDecoration(
          hintText: LocaleKeys.diagnosis_search_services.tr(),
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildTotalAmountCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText(
            title: LocaleKeys.general_total_amount.tr(),
            textType: TextType.title20,
            fontWeight: FontWeight.bold,
          ),
          PriceConvertWidget(
            price: _totalAmount,
            textType: TextType.title20,
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildServiceItem(ServiceItem service) {
    final isSelected = _selectedServiceIds.contains(service.id);
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : null,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.lightGrey,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: AppText(
          title: service.name ?? 'Unknown Service',
          textType: TextType.body,
          fontWeight: FontWeight.w600,
        ),
        subtitle: PriceConvertWidget(
          price: service.price ?? 0,
          textType: TextType.body,
          color: AppColors.primary,
        ),
        trailing: Checkbox(
          value: isSelected,
          onChanged: (value) {
            if (service.id != null) {
              _toggleServiceSelection(service.id!);
            }
          },
          activeColor: AppColors.primary,
        ),
        onTap: () {
          if (service.id != null) {
            _toggleServiceSelection(service.id!);
          }
        },
      ),
    );
  }

  Widget _buildNoResultsWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          AppText(
            title: LocaleKeys.notifications_no_search_results.tr(
              namedArgs: {'query': _searchQuery},
            ),
            textType: TextType.body,
            color: AppColors.grey,
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: BlocListener<SaveServiceCubit, SaveServiceState>(
        listener: (context, state) {
          if (state is SaveServiceSuccess) {
            AppSnackBar.showSuccessSnackBar(context, state.message);
            Navigator.pop(context);
          } else if (state is SaveServiceError) {
            AppSnackBar.showErrorSnackBar(context, state.message);
          }
        },
        child: DefElevatedButton(
          onPressed: _processPayment,
          title: LocaleKeys.buttons_save.tr(),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
          const SizedBox(height: 16),
          AppText(
            title: LocaleKeys.errors_something_went_wrong.tr(),
            textType: TextType.body,
            color: Colors.red.shade700,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SaveServiceCubit, SaveServiceState>(
      bloc: _fastPayCubit,
      listener: (context, state) {
        if (state is SaveServiceSuccess) {
          AppSnackBar.showSuccessSnackBar(context, state.message);
          router.popAndPush(
            PaymentViewRoute(appointmentId: widget.appointmentId),
          );
        } else if (state is SaveServiceError) {
          AppSnackBar.showErrorSnackBar(context, state.message);
        }
      },
      child: BlocBuilder<GetServiceItemCubit, GetServiceItemState>(
        bloc: _serviceCubit,
        builder: (context, state) {
          if (state is GetServiceItemLoading) {
            return const LoadingWidget();
          }

          if (state is GetServiceItemLoaded) {
            // Servisleri güncelle
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _updateServicesData(state.serviceItems);
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
                                  (context, index) => _buildServiceItem(
                                    _filteredServices[index],
                                  ),
                            ),
                  ),
                  _buildSaveButton(),
                  SizedBox(height: MediaQuery.of(context).padding.bottom),
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
