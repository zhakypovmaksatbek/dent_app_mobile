import 'package:auto_route/auto_route.dart';
import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/models/service/save_service_model.dart';
import 'package:dent_app_mobile/models/service/service_model.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/services/core/bloc/get_service/get_service_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/services/core/bloc/service/service_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/services/core/bloc/service_type/service_type_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/services/widgets/debounced_serach_field.dart'; // Corrected import if necessary
import 'package:dent_app_mobile/presentation/theme/colors/color_constants.dart';
import 'package:dent_app_mobile/presentation/theme/extension/card_style_extension.dart';
import 'package:dent_app_mobile/presentation/widgets/loading/app_loader.dart';
import 'package:dent_app_mobile/presentation/widgets/snack_bars/app_snack_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage(name: 'ServicesRoute')
class ServicesPage extends StatelessWidget {
  // The page itself is StatelessWidget, state management is inside _ServicesView.
  const ServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Returns the actual stateful content.
    return const _ServicesView();
  }
}

// StatefulWidget that manages the state and Cubits for the page.
class _ServicesView extends StatefulWidget {
  const _ServicesView();

  @override
  State<_ServicesView> createState() => _ServicesViewState();
}

class _ServicesViewState extends State<_ServicesView> {
  // Cubit instances are held within the state.
  late final GetServiceCubit getServiceCubit;
  late final ServiceTypeCubit serviceTypeCubit;
  late final ServiceCubit serviceCubit;

  // Controllers for UI elements.
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Cache to map service type ID to its name.
  final Map<int, String> _serviceTypeMap = {};

  @override
  void initState() {
    super.initState();
    // IMPORTANT: If Cubit constructors take dependencies (e.g., a Repository),
    // you need to provide them here. E.g.: getServiceCubit = GetServiceCubit(context.read<ServiceRepository>());
    // The current code assumes they take no dependencies.
    getServiceCubit = GetServiceCubit();
    serviceTypeCubit = ServiceTypeCubit();
    serviceCubit = ServiceCubit();

    // Initiate initial data loads after Cubits are created.
    getServiceCubit.getServices();
    serviceTypeCubit.getServiceTypes();
  }

  @override
  void dispose() {
    // Dispose controllers.
    _searchController.dispose();
    _scrollController.dispose();

    // Close manually created Cubits (release resources).
    getServiceCubit.close();
    serviceTypeCubit.close();
    serviceCubit.close(); // Ensure serviceCubit is closed.

    super.dispose();
  }

  // Called when the debounced search is triggered.
  void _handleSearchQuery(String query) {
    final trimmedQuery = query.trim();
    print("Performing search: '$trimmedQuery'");
    // Access the provided GetServiceCubit and perform search.
    // Using context.read works because it's provided via BlocProvider.value.
    context.read<GetServiceCubit>().getServices(
      search: trimmedQuery.isNotEmpty ? trimmedQuery : null,
    );
    // Alternative (direct instance): getServiceCubit.getServices(...)
  }

  // Shows the modal for adding a new service.
  void _showAddServiceDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (modalContext) =>
          // Provide necessary Cubits to the modal via MultiBlocProvider.
          MultiBlocProvider(
            providers: [
              BlocProvider.value(value: serviceTypeCubit),
              BlocProvider.value(value: serviceCubit),
            ],
            child: ServiceFormModal(
              formatServiceTypeName: formatServiceTypeName,
              onSubmit: (service) {
                // Call saveService using the direct instance or context.read.
                serviceCubit.saveService(service);
                Navigator.pop(modalContext);
              },
            ),
          ),
    );
  }

  // Shows the modal for editing an existing service.
  void _showEditServiceDialog(ServiceItem item) {
    final serviceType = _serviceTypeMap[item.id]; // Get cached type

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (modalContext) => MultiBlocProvider(
            providers: [
              BlocProvider.value(value: serviceTypeCubit),
              BlocProvider.value(value: serviceCubit),
            ],
            child: ServiceFormModal(
              formatServiceTypeName: formatServiceTypeName,
              initialService: SaveServiceModel(
                name: item.name,
                price: item.price?.toInt(),
                serviceType: serviceType,
              ),
              onSubmit: (service) {
                serviceCubit.updateService(item.id!, service);
                Navigator.pop(modalContext);
              },
            ),
          ),
    );
  }

  // Shows the confirmation dialog for deleting a service.
  void _confirmDelete(ServiceItem item) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: Text(LocaleKeys.buttons_delete.tr()),
            content: Text(
              LocaleKeys.alerts_confirm_delete_service.tr(
                namedArgs: {'name': item.name ?? ''},
              ),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(LocaleKeys.buttons_cancel.tr()),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  // Call deleteService using the direct instance or context.read.
                  serviceCubit.deleteService(item.id!);
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: Text(LocaleKeys.buttons_delete.tr()),
              ),
            ],
          ),
    );
  }

  // Converts a service type code into a human-readable string.
  String formatServiceTypeName(String type) {
    // The content of this method can remain the same.
    switch (type) {
      case 'NO_CATEGORY':
        return 'No Category';
      case 'CONSULTATION':
        return 'Consultation';
      case 'X_RAY':
        return 'X-Ray';
      case 'ORTHOPEDICS':
        return 'Orthopedics';
      case 'SURGERY_CHILD':
        return 'Child Surgery';
      case 'THERAPY':
        return 'Therapy';
      case 'SURGERY':
        return 'Surgery';
      case 'IMPLANTATION':
        return 'Implantation';
      case 'ORTHODONTICS':
        return 'Orthodontics';
      case 'ANESTHESIA':
        return 'Anesthesia';
      case 'HYGIENE':
        return 'Hygiene';
      case 'PREPS_AND_MATERIALS':
        return 'Preparations & Materials';
      case 'CHILD_DENTISTRY':
        return 'Child Dentistry';
      case 'LABORATORY':
        return 'Laboratory';
      case 'BONE_SOFT':
        return 'Bone Soft';
      case 'COSMETOLOGY':
        return 'Cosmetology';
      case 'PEDIATRIC_DENTISTRY':
        return 'Pediatric Dentistry';
      case 'TECHNICAL_WORKS':
        return 'Technical Works';
      case 'FUNCTIONAL_DIAGNOSTICS':
        return 'Functional Diagnostics';
      case 'DIAGNOSTICS':
        return 'Diagnostics';
      case 'GENERAL_EVENTS':
        return 'General Events';
      case 'MAXILLOFACIAL_SURGERY':
        return 'Maxillofacial Surgery';
      case 'PREVENTION':
        return 'Preventive Care';
      case 'SERVICE':
        return 'Service';
      default:
        if (type.isEmpty) return 'Unknown';
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

  // Extracts a list of ServiceItem from the API models and caches their types.
  List<ServiceItem> _extractAndCacheServiceItems(List<ServiceModel> services) {
    final allServices = <ServiceItem>[];
    _serviceTypeMap.clear(); // Clear previous cache

    for (final serviceModel in services) {
      if (serviceModel.serviceItem != null) {
        for (final item in serviceModel.serviceItem!) {
          if (item.id != null) {
            _serviceTypeMap[item.id!] =
                serviceModel.serviceType ?? 'NO_CATEGORY';
            allServices.add(item);
          }
        }
      }
    }
    // Optional: Sorting can be added here
    // allServices.sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));
    return allServices;
  }

  @override
  Widget build(BuildContext context) {
    // Provide Cubit instances to the widget tree using MultiBlocProvider.
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: getServiceCubit),
        BlocProvider.value(value: serviceTypeCubit),
        BlocProvider.value(value: serviceCubit),
      ],
      child: Scaffold(
        body: SafeArea(
          // BlocListener to react to state changes from ServiceCubit (Add/Edit/Delete results).
          child: BlocListener<ServiceCubit, ServiceState>(
            listener: (context, state) {
              if (state is ServiceActionSuccess) {
                AppSnackBar.showSuccessSnackBar(context, state.message);
                // Refresh the list if an action was successful.
                context.read<GetServiceCubit>().getServices(
                  search:
                      _searchController.text.isNotEmpty
                          ? _searchController.text.trim()
                          : null,
                );
              } else if (state is ServiceError) {
                AppSnackBar.showErrorSnackBar(context, state.message);
              }
            },
            // Main scrollable content area.
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                // Pinned AppBar with the search field.
                _buildPinnedAppBarWithSearch(context),
                // Service list or its loading/error/empty state.
                _buildSliverServiceList(),
                // Spacer for the FloatingActionButton.
                const SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showAddServiceDialog,
          backgroundColor: ColorConstants.primary,
          foregroundColor: Colors.white,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  // Widget that builds the pinned AppBar with the search field in its bottom area.
  Widget _buildPinnedAppBarWithSearch(BuildContext context) {
    const double searchFieldHeight =
        70.0; // Approximate height for the search field area.

    return SliverAppBar(
      title: Text(LocaleKeys.routes_services.tr()),
      pinned: true, // Keeps the AppBar pinned at the top.
      floating: false,
      snap: false,
      // Ensures the AppBar color doesn't blend with scrolled content.
      surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(searchFieldHeight),
        child: Container(
          // Background color can match the AppBar or Scaffold.
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8.0),
            child: DebouncedSearchField(
              controller: _searchController,
              debounceDuration: const Duration(milliseconds: 500),
              onSearchChanged: _handleSearchQuery,
            ),
          ),
        ),
      ),
    );
  }

  // Sliver widget that builds the service list or shows the relevant state (loading, error, empty).
  Widget _buildSliverServiceList() {
    // Build the UI based on the state of GetServiceCubit.
    return BlocBuilder<GetServiceCubit, GetServiceState>(
      builder: (context, state) {
        if (state is GetServiceLoading) {
          return const SliverFillRemaining(child: Center(child: AppLoader()));
        } else if (state is GetServiceLoaded) {
          final allServices = _extractAndCacheServiceItems(state.services);

          if (allServices.isEmpty) {
            // Message shown if there are no services initially or after a search.
            return SliverFillRemaining(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    // Display a different message if a search is active.
                    _searchController.text.isNotEmpty
                        ? LocaleKeys.notifications_no_search_results.tr(
                          namedArgs: {'query': _searchController.text},
                        ) // Example of a new locale key
                        : LocaleKeys.notifications_no_services_found.tr(),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ),
            );
          }

          // SliverList displaying the service items.
          return SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
            ), // Top and side padding.
            sliver: SliverList.separated(
              itemBuilder: (context, index) {
                final item = allServices[index];
                return _buildServiceItemCard(item);
              },
              separatorBuilder: (context, index) {
                return const SizedBox(height: 12);
              },
              itemCount: allServices.length,
            ),
          );
        } else if (state is GetServiceError) {
          return SliverFillRemaining(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  state.message,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red.shade700),
                ),
              ),
            ),
          );
        }

        // Fallback for initial or unexpected states.
        return const SliverToBoxAdapter(child: SizedBox.shrink());
      },
    );
  }

  // Widget that builds a single service item card.
  Widget _buildServiceItemCard(ServiceItem item) {
    final theme = Theme.of(context);
    // Dynamic locale and currency symbol.
    final localeString = context.locale.toString();
    final priceFormat = NumberFormat.currency(
      locale: localeString,
      symbol: NumberFormat.simpleCurrency(locale: localeString).currencySymbol,
      decimalDigits: 0,
    );

    // Date format based on dynamic locale.
    final formattedDate =
        item.createdAt != null
            ? DateFormat(
              'dd/MM/yyyy',
              localeString,
            ).format(DateTime.parse(item.createdAt!))
            : 'N/A';

    final serviceTypeRaw =
        item.id != null ? _serviceTypeMap[item.id] : 'NO_CATEGORY';
    final serviceTypeName = formatServiceTypeName(
      serviceTypeRaw ?? 'NO_CATEGORY',
    );

    return Container(
      // No margin here, spacing is handled by Padding in SliverList delegate
      decoration: theme.extension<CardStyleExtension>()?.customCardDecoration,

      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name ?? 'Unnamed Service',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$serviceTypeName • ${LocaleKeys.forms_created_on.tr()}: $formattedDate',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.price != null
                        ? priceFormat.format(item.price)
                        : '${priceFormat.currencySymbol} -', // Show symbol with dash if price is null.
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: ColorConstants.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Edit/Delete actions menu.
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: Colors.grey.shade600),
              tooltip: LocaleKeys.buttons_more_options.tr(),
              onSelected: (value) {
                if (value == 'edit') {
                  _showEditServiceDialog(item);
                } else if (value == 'delete') {
                  _confirmDelete(item);
                }
              },
              color: ColorConstants.white,
              itemBuilder:
                  (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(
                            Icons.edit_outlined,
                            size: 20,
                            color: theme.iconTheme.color,
                          ),
                          const SizedBox(width: 8),
                          Text(LocaleKeys.buttons_edit.tr()),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline,
                            size: 20,
                            color: Colors.red.shade700,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            LocaleKeys.buttons_delete.tr(),
                            style: TextStyle(color: Colors.red.shade700),
                          ),
                        ],
                      ),
                    ),
                  ],
            ),
          ],
        ),
      ),
    );
  }
}

//------------------------------------------------------------------
// Service Add/Edit Form Modal (No Changes Needed Here)
//------------------------------------------------------------------
class ServiceFormModal extends StatefulWidget {
  final SaveServiceModel? initialService;
  final Function(SaveServiceModel) onSubmit;
  final String Function(String)
  formatServiceTypeName; // Takes the formatter function directly

  const ServiceFormModal({
    super.key,
    this.initialService,
    required this.onSubmit,
    required this.formatServiceTypeName,
  });

  @override
  State<ServiceFormModal> createState() => _ServiceFormModalState();
}

class _ServiceFormModalState extends State<ServiceFormModal> {
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  String? _selectedServiceType;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialService?.name);
    _priceController = TextEditingController(
      text: widget.initialService?.price?.toString() ?? '',
    );
    _selectedServiceType = widget.initialService?.serviceType;
    // No need to listen to ServiceTypeCubit here initially, BlocBuilder handles it.
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  // Submit the form if valid.
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final service = SaveServiceModel(
        name: _nameController.text.trim(),
        price: int.tryParse(_priceController.text) ?? 0,
        serviceType: _selectedServiceType,
      );
      widget.onSubmit(service);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Modal content can remain the same as before.
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 16,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildModalHeader(),
                  const SizedBox(height: 24),
                  // Use BlocBuilder to get the ServiceTypeState for the dropdown.
                  BlocBuilder<ServiceTypeCubit, ServiceTypeState>(
                    builder:
                        (context, state) => _buildServiceTypeDropdown(state),
                  ),
                  const SizedBox(height: 16),
                  _buildNameField(),
                  const SizedBox(height: 16),
                  _buildPriceField(),
                  const SizedBox(height: 32),
                  _buildSubmitButton(),
                  const SizedBox(height: 10), // Bottom padding inside modal
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Builds the header of the modal.
  Widget _buildModalHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          widget.initialService == null
              ? LocaleKeys.buttons_add_new_service
                  .tr() // Title for adding
              : LocaleKeys.buttons_edit_service.tr(), // Title for editing
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
          tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
        ),
      ],
    );
  }

  // Builds the dropdown for selecting service type based on the Cubit state.
  Widget _buildServiceTypeDropdown(ServiceTypeState state) {
    List<String> availableTypes = [];
    bool isLoading = false;

    if (state is ServiceTypeLoading) {
      isLoading = true;
    } else if (state is ServiceTypeLoaded &&
        state.serviceTypes.serviceTypes != null) {
      availableTypes = state.serviceTypes.serviceTypes!;
    }

    // Check and adjust the selected type if necessary.
    // This logic runs every time BlocBuilder rebuilds (when state changes).
    if (_selectedServiceType != null &&
        !availableTypes.contains(_selectedServiceType)) {
      // If the currently selected type is not in the list, select the first available one (if any).
      _selectedServiceType =
          availableTypes.isNotEmpty ? availableTypes.first : null;
    } else if (_selectedServiceType == null && availableTypes.isNotEmpty) {
      // If no type is selected and the list is not empty, select the first one.
      _selectedServiceType = availableTypes.first;
    }

    return DropdownButtonFormField<String>(
      value: _selectedServiceType, // Shows the currently selected value.
      isExpanded: true,
      decoration: InputDecoration(
        labelText: LocaleKeys.general_service_type.tr(),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon:
            isLoading
                ? const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
                : null,
        hintText:
            availableTypes.isEmpty && !isLoading
                ? LocaleKeys.notifications_no_types_available.tr()
                : null,
      ),
      // IMPORTANT: setState MUST be called here to update the UI when the dropdown value changes.
      onChanged:
          (isLoading || availableTypes.isEmpty)
              ? null
              : (value) {
                if (value != null) {
                  setState(() {
                    _selectedServiceType = value;
                  });
                }
              },
      // Map the available raw types to DropdownMenuItems using the formatter function.
      items:
          availableTypes.map((type) {
            final displayName = widget.formatServiceTypeName(
              type,
            ); // Use the passed formatter
            return DropdownMenuItem<String>(
              value: type,
              child: Text(displayName),
            );
          }).toList(),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return LocaleKeys.validation_select_service_type.tr();
        }
        return null;
      },
    );
  }

  // Builds the name input field.
  Widget _buildNameField() {
    // Content can remain the same.
    return TextFormField(
      controller: _nameController,
      decoration: InputDecoration(
        labelText: LocaleKeys.general_service_name.tr(),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: const Icon(Icons.medical_services_outlined),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return LocaleKeys.validation_enter_service_name.tr();
        }
        return null;
      },
    );
  }

  // Builds the price input field.
  Widget _buildPriceField() {
    // Content can remain the same (with dynamic locale/symbol).
    final localeString = context.locale.toString();
    final priceFormat = NumberFormat.currency(
      locale: localeString,
      symbol: NumberFormat.simpleCurrency(locale: localeString).currencySymbol,
      decimalDigits: 0,
    );
    return TextFormField(
      controller: _priceController,
      decoration: InputDecoration(
        labelText: LocaleKeys.general_service_price.tr(),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 12.0, right: 4.0),
          child: Text(
            priceFormat.currencySymbol,
            style: const TextStyle(fontSize: 16),
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: false),
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return LocaleKeys.validation_enter_service_price.tr();
        }
        if (int.tryParse(value) == null) {
          return LocaleKeys.validation_enter_valid_service_price.tr();
        }
        if (int.parse(value) < 0) {
          return LocaleKeys.validation_price_cannot_be_negative.tr();
        }
        return null;
      },
    );
  }

  // Builds the submit button.
  Widget _buildSubmitButton() {
    // Content can remain the same.
    return ElevatedButton(
      onPressed: _submitForm,
      style: ElevatedButton.styleFrom(
        backgroundColor: ColorConstants.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
      child: Text(
        widget.initialService == null
            ? LocaleKeys.buttons_add.tr()
            : LocaleKeys.buttons_save.tr(),
      ),
    );
  }
}

// Remember to add the necessary locale keys, for example:
// "notifications_no_search_results": "No services found matching '{query}'"
