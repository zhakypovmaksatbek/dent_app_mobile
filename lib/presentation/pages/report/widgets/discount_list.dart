import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/models/report/payment_report_model.dart';
import 'package:dent_app_mobile/presentation/pages/report/core/bloc/discount/discount_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/report/utils/date_utils.dart';
import 'package:dent_app_mobile/presentation/pages/report/widgets/payment_item.dart';
import 'package:dent_app_mobile/presentation/widgets/loading/app_loader.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DiscountList extends StatefulWidget {
  final DateTime startDate;
  final DateTime endDate;

  const DiscountList({
    super.key,
    required this.startDate,
    required this.endDate,
  });

  @override
  State<DiscountList> createState() => _DiscountListState();
}

class _DiscountListState extends State<DiscountList> {
  final _scrollController = ScrollController();
  final List<PaymentReportModel> _discountReports = [];
  int _currentPage = 1;
  bool _isLoadingMore = false;
  bool _hasReachedEnd = false;
  late final DiscountCubit _discountCubit;

  @override
  void initState() {
    super.initState();
    _discountCubit = context.read<DiscountCubit>();
    _scrollController.addListener(_onScroll);
    // Initial fetch
    _fetchDiscountReport(true);
  }

  @override
  void didUpdateWidget(DiscountList oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload if date range changes
    if (oldWidget.startDate != widget.startDate ||
        oldWidget.endDate != widget.endDate) {
      _fetchDiscountReport(true);
    }
  }

  void _onScroll() {
    if (!_isLoadingMore && !_hasReachedEnd) {
      if (_scrollController.position.pixels >
          _scrollController.position.maxScrollExtent - 200) {
        _fetchDiscountReport(false);
      }
    }
  }

  void _fetchDiscountReport(bool reset) {
    if (reset) {
      setState(() {
        _discountReports.clear();
        _currentPage = 1;
        _hasReachedEnd = false;
      });
    }

    if (_isLoadingMore || _hasReachedEnd) return;

    setState(() {
      _isLoadingMore = true;
    });

    final startDateFormatted = ReportDateUtils.formatForApi(widget.startDate);
    final endDateFormatted = ReportDateUtils.formatForApi(widget.endDate);

    try {
      _discountCubit.getDiscountReport(
        startDateFormatted,
        endDateFormatted,
        page: _currentPage,
      );
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DiscountCubit, DiscountState>(
      bloc: _discountCubit,
      listener: (context, state) {
        if (state is DiscountLoaded) {
          setState(() {
            _isLoadingMore = false;
            if (state.discountReport.content == null ||
                state.discountReport.content!.isEmpty) {
              _hasReachedEnd = true;
            } else {
              // Update list
              _discountReports.addAll(state.discountReport.content!);
              _currentPage++;
              _hasReachedEnd = state.discountReport.last ?? false;
            }
          });
        } else if (state is DiscountError) {
          setState(() {
            _isLoadingMore = false;
          });

          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${LocaleKeys.notifications_error.tr()} ${state.message}',
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        // Initial loading state
        if (state is DiscountInitial) {
          _fetchDiscountReport(true);
          return const Center(child: AppLoader());
        }

        // Loading state with empty list
        if (state is DiscountLoading && _discountReports.isEmpty) {
          return const Center(child: AppLoader());
        }

        // Data loaded and list has items
        if (_discountReports.isNotEmpty) {
          return RefreshIndicator(
            onRefresh: () async => _fetchDiscountReport(true),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          LocaleKeys.report_discount_reports.tr(),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      Text(
                        '${LocaleKeys.report_total.tr()}: ${_discountReports.length}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16.0),
                    itemCount:
                        _discountReports.length + (_isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _discountReports.length) {
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

                      return PaymentItem(payment: _discountReports[index]);
                    },
                  ),
                ),
              ],
            ),
          );
        }

        // Empty state
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(LocaleKeys.report_no_discount_records_found.tr()),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _fetchDiscountReport(true),
                child: Text(LocaleKeys.buttons_refresh.tr()),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
