import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/models/report/debtor_model.dart';
import 'package:dent_app_mobile/presentation/pages/report/core/bloc/debtor/debtor_cubit.dart';
import 'package:dent_app_mobile/presentation/theme/colors/color_constants.dart';
import 'package:dent_app_mobile/presentation/widgets/loading/app_loader.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DebtorList extends StatefulWidget {
  final DateTime startDate;
  final DateTime endDate;
  final String? searchQuery;

  const DebtorList({
    super.key,
    required this.startDate,
    required this.endDate,
    this.searchQuery,
  });

  @override
  State<DebtorList> createState() => _DebtorListState();
}

class _DebtorListState extends State<DebtorList> {
  final _scrollController = ScrollController();
  final List<DebtorModel> _debtors = [];
  final _searchController = TextEditingController();
  int _currentPage = 1;
  bool _isLoadingMore = false;
  bool _hasReachedEnd = false;
  late final DebtorCubit _debtorCubit;

  @override
  void initState() {
    super.initState();
    _debtorCubit = context.read<DebtorCubit>();
    _scrollController.addListener(_onScroll);
    _searchController.text = widget.searchQuery ?? '';
    // Initial fetch
    _fetchDebtors(true);
  }

  @override
  void didUpdateWidget(DebtorList oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload if date range or search query changes
    if (oldWidget.startDate != widget.startDate ||
        oldWidget.endDate != widget.endDate ||
        oldWidget.searchQuery != widget.searchQuery) {
      _searchController.text = widget.searchQuery ?? '';
      _fetchDebtors(true);
    }
  }

  void _onScroll() {
    if (!_isLoadingMore && !_hasReachedEnd) {
      if (_scrollController.position.pixels >
          _scrollController.position.maxScrollExtent - 200) {
        _fetchDebtors(false);
      }
    }
  }

  void _fetchDebtors(bool reset) {
    if (reset) {
      setState(() {
        _debtors.clear();
        _currentPage = 1;
        _hasReachedEnd = false;
      });
    }

    if (_isLoadingMore || _hasReachedEnd) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      _debtorCubit.getDebtorReport(
        widget.startDate.toString(),
        widget.endDate.toString(),
        page: _currentPage,
        search: _searchController.text.isEmpty ? null : _searchController.text,
      );
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  void _handleSearch() {
    _fetchDebtors(true);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DebtorCubit, DebtorState>(
      bloc: _debtorCubit,
      listener: (context, state) {
        if (state is DebtorLoaded) {
          setState(() {
            _isLoadingMore = false;
            if (state.debtorReport.content == null ||
                state.debtorReport.content!.isEmpty) {
              _hasReachedEnd = true;
            } else {
              // Update list
              _debtors.addAll(state.debtorReport.content!);
              _currentPage++;
              _hasReachedEnd = state.debtorReport.last ?? false;
            }
          });
        } else if (state is DebtorError) {
          setState(() {
            _isLoadingMore = false;
          });

          // Show error message
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: ${state.message}')));
        }
      },
      builder: (context, state) {
        return Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: LocaleKeys.report_search_debtors.tr(),
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 0,
                          horizontal: 16,
                        ),
                      ),
                      onSubmitted: (_) => _handleSearch(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _handleSearch,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(12),
                      minimumSize: const Size(0, 48),
                    ),
                    child: Text(LocaleKeys.buttons_search.tr()),
                  ),
                ],
              ),
            ),

            Expanded(child: _buildContent(state)),
          ],
        );
      },
    );
  }

  Widget _buildContent(DebtorState state) {
    // Initial loading state
    if (state is DebtorInitial) {
      _fetchDebtors(true);
      return const Center(child: AppLoader());
    }

    // Loading state with empty list
    if (state is DebtorLoading && _debtors.isEmpty) {
      return const Center(child: AppLoader());
    }

    // Data loaded and list has items
    if (_debtors.isNotEmpty) {
      return RefreshIndicator(
        onRefresh: () async => _fetchDebtors(true),
        child: ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16.0),
          itemCount: _debtors.length + (_isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == _debtors.length) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: SizedBox(
                    height: 30,
                    width: 30,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              );
            }

            return _buildDebtorCard(_debtors[index]);
          },
        ),
      );
    }

    // Empty state
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(LocaleKeys.report_no_debtors_found.tr()),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _fetchDebtors(true),
            child: Text(LocaleKeys.buttons_refresh.tr()),
          ),
        ],
      ),
    );
  }

  Widget _buildDebtorCard(DebtorModel debtor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: ColorConstants.primary.withValues(alpha: .08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        debtor.fullName ?? 'Unknown Patient',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (debtor.phoneNumber != null &&
                          debtor.phoneNumber!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            debtor.phoneNumber!,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                    ],
                  ),
                ),
                // Container(
                //   padding: const EdgeInsets.symmetric(
                //     horizontal: 12,
                //     vertical: 6,
                //   ),
                //   decoration: BoxDecoration(
                //     color: AppColors.primary.withOpacity(0.1),
                //     borderRadius: BorderRadius.circular(16),
                //     border: Border.all(
                //       color: AppColors.primary.withOpacity(0.3),
                //     ),
                //   ),
                //   child: Text(
                //     'ID: ${debtor.id ?? "N/A"}',
                //     style: Theme.of(context).textTheme.titleSmall?.copyWith(
                //       fontWeight: FontWeight.bold,
                //       color: AppColors.primary,
                //     ),
                //   ),
                // ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    context: context,
                    label: LocaleKeys.report_paid.tr(),
                    value: '${debtor.payed ?? 0}',
                    valueColor: Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    context: context,
                    label: LocaleKeys.report_debt.tr(),
                    value: '${debtor.debt ?? 0}',
                    valueColor: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required BuildContext context,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: ColorConstants.primary),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}
