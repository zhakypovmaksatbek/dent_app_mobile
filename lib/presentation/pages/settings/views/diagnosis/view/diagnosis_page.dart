import 'package:auto_route/auto_route.dart'; // Correct import
import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/main.dart';
import 'package:dent_app_mobile/models/diagnosis/diagnosis_model.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/diagnosis/core/bloc/cubit/diagnosis_configuration_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/diagnosis/core/bloc/diagnosis/diagnosis_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/diagnosis/widget/diagnosis_form_modal.dart';
import 'package:dent_app_mobile/presentation/theme/extension/card_style_extension.dart';
import 'package:dent_app_mobile/presentation/widgets/loading/app_loader.dart'; // Import loader
import 'package:dent_app_mobile/presentation/widgets/snack_bars/app_snack_bar.dart'; // Import snackbar
import 'package:dent_app_mobile/router/app_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage(name: 'DiagnosisRoute')
class DiagnosisPage extends StatelessWidget {
  // Keep page stateless, state is in _DiagnosisView
  const DiagnosisPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _DiagnosisView();
  }
}

class _DiagnosisView extends StatefulWidget {
  const _DiagnosisView();

  @override
  State<_DiagnosisView> createState() => _DiagnosisViewState();
}

class _DiagnosisViewState extends State<_DiagnosisView> {
  // Manually managed Cubits
  late final DiagnosisCubit _diagnosisCubit;
  late final DiagnosisConfigurationCubit _diagnosisConfigurationCubit;

  // UI Controllers
  final ScrollController _scrollController = ScrollController();

  // Pagination State
  final List<DiagnosisModel> _diagnosis = [];
  int _currentPage = 1;
  bool _isLastPage = false; // Tracks if the last page has been loaded
  bool _isLoadingMore = false; // Prevents multiple fetches during pagination

  @override
  void initState() {
    super.initState();
    // Initialize Cubits
    // IMPORTANT: Provide dependencies here if needed, e.g., DiagnosisCubit(context.read<SomeRepo>())
    _diagnosisCubit = DiagnosisCubit();
    _diagnosisConfigurationCubit = DiagnosisConfigurationCubit();

    // Fetch initial data
    _fetchDiagnoses(isRefresh: true, isInitial: true);

    // Setup scroll listener for pagination
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    // Dispose controllers
    _scrollController.removeListener(_onScroll); // Remove listener!
    _scrollController.dispose();

    // Close manually managed Cubits
    _diagnosisCubit.close();
    _diagnosisConfigurationCubit.close();
    super.dispose();
  }

  // Scroll listener logic for pagination
  void _onScroll() {
    // Check if near the bottom and if more data can be loaded
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !_isLastPage &&
        !_isLoadingMore) {
      _fetchDiagnoses(); // Fetch the next page
    }
  }

  // Method to fetch diagnoses (handles initial load, refresh, and pagination)
  Future<void> _fetchDiagnoses({
    bool isRefresh = false,
    bool isInitial = false,
  }) async {
    if (_isLoadingMore) return; // Don't fetch if already loading more

    if (isRefresh) {
      _currentPage = 1;
      _isLastPage = false; // Reset last page status on refresh
    }

    if (!isInitial) {
      _currentPage++;
    }

    // Trigger the cubit
    await _diagnosisCubit.getDiagnosis(_currentPage, isRefresh: isRefresh);
  }

  // --- Add/Edit/Delete Modals and Dialogs ---

  void _showAddDiagnosisDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (modalContext) => DiagnosisFormModal(
            onSubmit: (name) async {
              router.maybePop();

              // Call saveDiagnosis using the DIRECT INSTANCE

              await _diagnosisConfigurationCubit.saveDiagnosis(name);
            },
          ),
    );
  }

  void _showEditDiagnosisDialog(DiagnosisModel diagnosis) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (modalContext) => DiagnosisFormModal(
            initialDiagnosis: diagnosis, // Pass the diagnosis for editing
            onSubmit: (name) async {
              if (diagnosis.id != null) {
                router.maybePop();

                // Call updateDiagnosis using the DIRECT INSTANCE
                await _diagnosisConfigurationCubit.updateDiagnosis(
                  diagnosis.id!,
                  name,
                );
              }
            },
          ),
    );
  }

  final router = getIt<AppRouter>();
  void _confirmDeleteDiagnosis(DiagnosisModel diagnosis) {
    if (diagnosis.id == null) return; // Cannot delete without ID

    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: Text(LocaleKeys.buttons_delete.tr()),
            content: Text(
              // Use a specific confirmation message if available
              LocaleKeys.alerts_confirm_delete_diagnosis.tr(
                // ADD THIS LOCALE KEY
                namedArgs: {'name': diagnosis.name ?? ''},
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
                onPressed: () async {
                  // Call deleteDiagnosis using the DIRECT INSTANCE
                  await _diagnosisConfigurationCubit.deleteDiagnosis(
                    diagnosis.id!,
                  );
                  router.maybePop();
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: Text(LocaleKeys.buttons_delete.tr()),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Provide all manually managed cubits to the widget tree
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _diagnosisCubit),
        BlocProvider.value(value: _diagnosisConfigurationCubit),
      ],
      child: Scaffold(
        body: SafeArea(
          // Listen for ADD/EDIT/DELETE results
          child: BlocListener<
            DiagnosisConfigurationCubit,
            DiagnosisConfigurationState
          >(
            listener: (context, configState) {
              if (configState is DiagnosisConfigurationLoaded) {
                AppSnackBar.showSuccessSnackBar(
                  context,
                  LocaleKeys.alerts_operation_successful
                      .tr(), // ADD THIS LOCALE KEY
                );
                // Refresh the list from the start after a successful operation
                _fetchDiagnoses(isRefresh: true, isInitial: true);
              } else if (configState is DiagnosisConfigurationError) {
                AppSnackBar.showErrorSnackBar(context, configState.message);
              }
            },
            child: RefreshIndicator(
              onRefresh: () async {
                _currentPage = 1;
                _diagnosis.clear();
                _fetchDiagnoses(isRefresh: true, isInitial: true);
              },
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverAppBar(
                    title: Text(LocaleKeys.general_diagnosis_info.tr()),
                    pinned: true, // Keep AppBar visible
                    floating: false,
                    snap: false,
                    surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
                    // Add action button for adding new diagnosis
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        tooltip:
                            LocaleKeys.buttons_add_new_diagnosis
                                .tr(), // ADD THIS LOCALE KEY
                        onPressed: _showAddDiagnosisDialog,
                      ),
                    ],
                  ),
                  // Listen for diagnosis list data
                  BlocConsumer<DiagnosisCubit, DiagnosisState>(
                    listener: (context, diagState) {
                      // Update local list and pagination state when data is loaded
                      if (diagState is DiagnosisLoaded) {
                        if (diagState.isRefresh) {
                          _currentPage = 1;
                          _diagnosis.clear();
                        }
                        // Append new content
                        _diagnosis.addAll(diagState.diagnosis.content ?? []);
                        // Update pagination flags
                        _isLastPage = diagState.diagnosis.last ?? true;
                        // API page numbers are 0-based

                        // Reset loading flag (listener runs after cubit method finishes)

                        _isLoadingMore = false;
                      } else if (diagState is DiagnosisError) {
                        // If fetching fails, reset loading flag
                        if (_isLoadingMore && mounted) {
                          _isLoadingMore = false;
                        }
                        // Optionally show snackbar for list fetch error
                        AppSnackBar.showErrorSnackBar(
                          context,
                          diagState.message,
                        );
                      } else if (diagState is DiagnosisLoading) {
                        _isLoadingMore = true;
                      }
                    },
                    builder: (context, diagState) {
                      // Show initial loading indicator only if the list is empty
                      if (diagState is DiagnosisLoading && _diagnosis.isEmpty) {
                        return const SliverFillRemaining(
                          child: Center(child: AppLoader()),
                        );
                      }

                      // Show empty state if list is empty and not loading
                      if (_diagnosis.isEmpty &&
                          diagState is! DiagnosisLoading) {
                        return SliverFillRemaining(
                          child: Center(
                            child: Text(
                              LocaleKeys.notifications_no_diagnosis_found
                                  .tr(), // ADD THIS LOCALE KEY
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(color: Colors.grey.shade600),
                            ),
                          ),
                        );
                      }

                      // Build the list using SliverList.builder
                      return SliverList.builder(
                        // Add 1 extra item for the loading indicator if needed
                        itemCount: _diagnosis.length,
                        itemBuilder: (context, index) {
                          // Check if it's the loading indicator item

                          // Otherwise, build the diagnosis item card
                          final diagnosis = _diagnosis[index];
                          return _buildDiagnosisItemCard(diagnosis);
                        },
                      );
                    },
                  ),
                  // Optional: Add padding at the bottom if FAB obscures last item
                  SliverToBoxAdapter(
                    child: BlocBuilder<DiagnosisCubit, DiagnosisState>(
                      builder: (context, state) {
                        if (state is DiagnosisLoading) {
                          return const Padding(
                            padding: EdgeInsets.only(top: 20, bottom: 50),
                            child: Center(child: AppLoader()),
                          );
                        }
                        return const Padding(
                          padding: EdgeInsets.only(top: 20, bottom: 50),
                          child: SizedBox.shrink(),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Builds the custom card for a single diagnosis item
  Widget _buildDiagnosisItemCard(DiagnosisModel diagnosis) {
    final theme = Theme.of(context);
    // Use the theme extension for consistent styling
    final cardStyle = theme.extension<CardStyleExtension>();
    final decoration =
        cardStyle?.customCardDecoration ??
        CardStyleExtension.defaultCardDecoration;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 6,
      ), // Margin around each card
      decoration: decoration,
      child: Padding(
        padding: const EdgeInsets.only(
          left: 16,
          right: 8,
          top: 12,
          bottom: 12,
        ), // Adjusted padding
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.center, // Center items vertically
          children: [
            // Optional: Leading icon
            Icon(
              Icons.biotech_outlined,
              color: theme.primaryColor.withValues(alpha: 0.7),
              size: 20,
            ),
            const SizedBox(width: 12),
            // Diagnosis Name (takes remaining space)
            Expanded(
              child: Text(
                diagnosis.name ?? 'Unnamed Diagnosis',
                style: theme.textTheme.bodyLarge, // Slightly larger text maybe
              ),
            ),
            const SizedBox(width: 8),
            // Action Buttons (Edit/Delete)
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: Colors.grey.shade600),
              tooltip: LocaleKeys.buttons_more_options.tr(),
              onSelected: (value) {
                if (value == 'edit') {
                  _showEditDiagnosisDialog(diagnosis);
                } else if (value == 'delete') {
                  _confirmDeleteDiagnosis(diagnosis);
                }
              },
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
