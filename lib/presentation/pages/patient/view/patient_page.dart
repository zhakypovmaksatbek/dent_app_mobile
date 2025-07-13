import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/models/patient/patient_data_model.dart';
import 'package:dent_app_mobile/presentation/pages/patient/core/bloc/patient_bloc/patient_bloc.dart';
import 'package:dent_app_mobile/presentation/pages/patient/view/create_patient.dart';
import 'package:dent_app_mobile/presentation/pages/patient/widgets/patient_card.dart';
import 'package:dent_app_mobile/presentation/widgets/text/app_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

@RoutePage(name: 'PatientRoute')
class PatientPage extends StatefulWidget {
  const PatientPage({super.key});

  @override
  State<PatientPage> createState() => _PatientPageState();
}

class _PatientPageState extends State<PatientPage> {
  // Controllers and focus management
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _searchFocusNode = FocusNode();

  // State management
  final List<PatientModel> _patients = [];
  bool _isSearching = false;
  bool _isLoading = false;
  bool _isLast = false;
  Timer? _debounceTimer;

  // Constants
  static const int _pageSize = 10;
  static const Duration _debounceDelay = Duration(milliseconds: 500);
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  @override
  void dispose() {
    _cleanupResources();
    super.dispose();
  }

  /// Initialize page with initial data load and scroll listener
  void _initializePage() {
    _loadPatients();
    _scrollController.addListener(_handleScroll);
  }

  /// Clean up all resources to prevent memory leaks
  void _cleanupResources() {
    _searchController.dispose();
    _scrollController.dispose();
    _searchFocusNode.dispose();
    _debounceTimer?.cancel();
  }

  /// Load patients with pagination support
  void _loadPatients({bool isRefresh = true}) {
    if (isRefresh) {
      _currentPage = 1;
    }
    context.read<PatientBloc>().add(
      GetPatients(page: _currentPage, size: _pageSize, isRefresh: isRefresh),
    );
  }

  /// Handle infinite scroll pagination
  void _handleScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      // Only allow pagination for normal patient loading, not for search results
      if (!_isLast && !_isLoading && !_isSearching) {
        _currentPage++;
        _loadPatients(isRefresh: false);
      }
    }
  }

  /// Handle search input with debouncing
  void _handleSearch(String query) {
    _debounceTimer?.cancel();

    if (query.isEmpty) {
      // If search is cleared, switch back to normal mode
      setState(() {
        _isSearching = false;
      });
      _currentPage = 1;
      _isLast = false;
      _loadPatients();
      return;
    }

    _debounceTimer = Timer(_debounceDelay, () {
      if (mounted) {
        // Ensure we're in search mode and disable pagination
        setState(() {
          _isSearching = true;
        });
        _isLast = true; // Prevent pagination for search
        context.read<PatientBloc>().add(SearchPatients(query.trim()));
      }
    });
  }

  /// Toggle search mode with proper focus management
  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
    });

    if (_isSearching) {
      // Focus on search field when opening
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _searchFocusNode.requestFocus();
      });
    } else {
      // Clear search and reload when closing
      _searchController.clear();
      _searchFocusNode.unfocus();
      // Reset pagination state when exiting search
      _currentPage = 1;
      _isLast = false;
      _loadPatients();
    }
  }

  /// Clear search and reset to original state
  void _clearSearch() {
    _searchController.clear();
    _searchFocusNode.unfocus();
    // Reset pagination state when clearing search
    _currentPage = 1;
    _isLast = false;
    _loadPatients();
  }

  /// Handle manual search submission
  void _submitSearch(String value) {
    if (value.trim().isEmpty) return;

    _debounceTimer?.cancel();
    context.read<PatientBloc>().add(SearchPatients(value.trim()));
  }

  /// Handle pull-to-refresh
  Future<void> _handleRefresh() async {
    if (_searchController.text.isEmpty) {
      _loadPatients();
    } else {
      context.read<PatientBloc>().add(
        SearchPatients(_searchController.text.trim()),
      );
    }
  }

  /// Show create patient bottom sheet
  void _showCreatePatient() {
    showCupertinoModalBottomSheet(
      context: context,
      builder: (context) => const CreatePatientPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  /// Build app bar with search functionality
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: AppText(
        title: LocaleKeys.patients_patients.tr(),
        textType: TextType.title,
      ),
      actions: [
        IconButton(
          icon: Icon(_isSearching ? Icons.close : Icons.search),
          onPressed: _toggleSearch,
          tooltip: _isSearching ? 'Закрыть поиск' : 'Поиск пациентов',
        ),
      ],
      bottom:
          _isSearching
              ? PreferredSize(
                preferredSize: const Size.fromHeight(72),
                child: _buildSearchField(),
              )
              : null,
    );
  }

  /// Build search input field
  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: _searchController,
        builder: (context, value, child) {
          return TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            decoration: InputDecoration(
              hintText: LocaleKeys.patients_search_patient.tr(),
              prefixIcon: const Icon(Icons.search),
              suffixIcon:
                  value.text.isNotEmpty
                      ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _clearSearch,
                        tooltip: 'Очистить поиск',
                      )
                      : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Theme.of(context).primaryColor),
              ),
            ),
            textInputAction: TextInputAction.search,
            onChanged: _handleSearch,
            onSubmitted: _submitSearch,
          );
        },
      ),
    );
  }

  /// Build main body content
  Widget _buildBody() {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        controller: _scrollController,
        slivers: [_buildPatientContent(), _buildLoadingFooter()],
      ),
    );
  }

  /// Build patient content based on state
  Widget _buildPatientContent() {
    return BlocConsumer<PatientBloc, PatientState>(
      listener: _handlePatientStateChanges,
      builder: (context, state) {
        if (state is PatientLoading && _patients.isEmpty) {
          return _buildLoadingIndicator();
        } else if (state is PatientError) {
          return _buildErrorState(state);
        } else {
          return _patients.isEmpty
              ? _buildEmptyState()
              : _buildPatientList(_patients);
        }
      },
    );
  }

  /// Handle patient state changes
  void _handlePatientStateChanges(BuildContext context, PatientState state) {
    if (state is PatientLoading) {
      _isLoading = true;
    } else if (state is PatientLoaded) {
      _isLoading = false;
      _isLast = state.isLast;
      if (state.isRefresh) {
        _currentPage = 1;
        _patients.clear();
      }
      _patients.addAll(state.patients.content ?? []);
    } else if (state is PatientSearched) {
      _isLoading = false;
      _isLast = true; // Search results don't support pagination
      _patients.clear();
      _patients.addAll(state.patients.content ?? []);
    } else {
      _isLoading = false;
    }
  }

  /// Build loading indicator
  Widget _buildLoadingIndicator() {
    return const SliverFillRemaining(
      child: Center(child: CircularProgressIndicator()),
    );
  }

  /// Build error state
  Widget _buildErrorState(PatientError state) {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            AppText(
              title: state.message,
              textType: TextType.body,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadPatients,
              child: const Text('Повторить'),
            ),
          ],
        ),
      ),
    );
  }

  /// Build empty state
  Widget _buildEmptyState() {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.people_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            AppText(
              title:
                  _isSearching
                      ? 'Пациенты не найдены'
                      : LocaleKeys.patients_not_found.tr(),
              textType: TextType.body,
            ),
            if (_isSearching) ...[
              const SizedBox(height: 8),
              AppText(
                title: 'Попробуйте изменить поисковый запрос',
                textType: TextType.subtitle,
                color: Colors.grey,
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Build patient list
  Widget _buildPatientList(List<PatientModel> patients) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList.separated(
        itemBuilder: (context, index) {
          final patient = patients[index];
          return PatientCard(patient: patient);
        },
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemCount: patients.length,
      ),
    );
  }

  /// Build loading footer for pagination
  Widget _buildLoadingFooter() {
    return SliverPadding(
      padding: const EdgeInsets.only(top: 20.0, bottom: 50),
      sliver: BlocBuilder<PatientBloc, PatientState>(
        builder: (context, state) {
          if (state is PatientLoading && _patients.isNotEmpty) {
            return const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              ),
            );
          }
          return const SliverToBoxAdapter();
        },
      ),
    );
  }

  /// Build floating action button
  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: _showCreatePatient,
      tooltip: 'Добавить пациента',
      child: const Icon(Icons.add),
    );
  }
}
