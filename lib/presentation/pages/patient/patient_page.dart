import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/models/patient/patient_data_model.dart';
import 'package:dent_app_mobile/presentation/pages/patient/core/bloc/patient_bloc.dart';
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
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<PatientModel> _patients = [];
  bool _isSearching = false;
  static const int _pageSize = 10;
  int _currentPage = 1;
  bool _isLoading = false;
  bool _isLast = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _getPatients();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _getPatients({bool isRefresh = true}) {
    if (isRefresh) {
      _currentPage = 1;
    }
    context.read<PatientBloc>().add(
      GetPatients(page: _currentPage, size: _pageSize, isRefresh: isRefresh),
    );
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (!_isLast && !_isLoading) {
        _currentPage++;
        _getPatients(isRefresh: false);
      }
    }
  }

  void _handleSearch(String query) {
    _debounceTimer?.cancel();

    if (query.isEmpty) {
      _getPatients();
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        context.read<PatientBloc>().add(SearchPatients(query.trim()));
      }
    });
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _getPatients();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppText(
          title: LocaleKeys.patients_patients.tr(),
          textType: TextType.title,
        ),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: _toggleSearch,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (_searchController.text.isEmpty) {
            _getPatients();
          } else {
            context.read<PatientBloc>().add(
              SearchPatients(_searchController.text.trim()),
            );
          }
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          controller: _scrollController,
          slivers: [
            if (_isSearching) SliverToBoxAdapter(child: _buildSearchField()),
            BlocConsumer<PatientBloc, PatientState>(
              listener: (context, state) {
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
                  _patients.clear();
                  _patients.addAll(state.patients.content ?? []);
                } else {
                  _isLoading = false;
                }
              },
              builder: (context, state) {
                if (state is PatientLoading && _patients.isEmpty) {
                  return _buildLoadingIndicator();
                } else if (state is PatientError) {
                  return _buildErrorState(state);
                } else {
                  if (_patients.isEmpty) {
                    return _buildEmptyState();
                  }
                  return _buildPatientList(_patients);
                }
              },
            ),

            SliverPadding(
              padding: EdgeInsets.only(top: 20.0, bottom: 50),
              sliver: BlocBuilder<PatientBloc, PatientState>(
                builder: (context, state) {
                  if (state is PatientLoading) {
                    return const SliverToBoxAdapter(
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  return const SliverToBoxAdapter();
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showCupertinoModalBottomSheet(
            context: context,
            builder: (context) => const CreatePatientPage(),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: LocaleKeys.patients_search_patient.tr(),
          prefixIcon: const Icon(Icons.search),
          suffixIcon:
              _searchController.text.isNotEmpty
                  ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      _getPatients();
                    },
                  )
                  : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        textInputAction: TextInputAction.search,
        onChanged: _handleSearch,
        onSubmitted: (value) {
          if (value.isNotEmpty) {
            _debounceTimer?.cancel();
            context.read<PatientBloc>().add(SearchPatients(value.trim()));
          }
        },
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return SliverFillRemaining(
      child: const Center(child: CircularProgressIndicator()),
    );
  }

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
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.people_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            AppText(
              title: LocaleKeys.patients_not_found.tr(),
              textType: TextType.body,
            ),
          ],
        ),
      ),
    );
  }

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
}
