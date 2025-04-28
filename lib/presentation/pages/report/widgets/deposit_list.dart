import 'package:dent_app_mobile/core/repo/report/report_repo.dart';
import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/models/report/payment_report_model.dart';
import 'package:dent_app_mobile/presentation/pages/report/core/bloc/deposit/deposit_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/report/utils/date_utils.dart';
import 'package:dent_app_mobile/presentation/pages/report/widgets/payment_item.dart';
import 'package:dent_app_mobile/presentation/widgets/loading/app_loader.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DepositList extends StatefulWidget {
  final DateTime startDate;
  final DateTime endDate;
  final DepositType? depositType;

  const DepositList({
    super.key,
    required this.startDate,
    required this.endDate,
    this.depositType,
  });

  @override
  State<DepositList> createState() => _DepositListState();
}

class _DepositListState extends State<DepositList> {
  final _scrollController = ScrollController();
  final List<PaymentReportModel> _depositReports = [];
  int _currentPage = 1;
  bool _isLoadingMore = false;
  bool _hasReachedEnd = false;
  late final DepositCubit _depositCubit;

  @override
  void initState() {
    super.initState();
    _depositCubit = context.read<DepositCubit>();
    _scrollController.addListener(_onScroll);
    // Initial fetch
    _fetchDepositReport(true);
  }

  @override
  void didUpdateWidget(DepositList oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload if date range or deposit type changes
    if (oldWidget.startDate != widget.startDate ||
        oldWidget.endDate != widget.endDate ||
        oldWidget.depositType != widget.depositType) {
      _fetchDepositReport(true);
    }
  }

  void _onScroll() {
    if (!_isLoadingMore && !_hasReachedEnd) {
      if (_scrollController.position.pixels >
          _scrollController.position.maxScrollExtent - 200) {
        _fetchDepositReport(false);
      }
    }
  }

  void _fetchDepositReport(bool reset) {
    if (reset) {
      setState(() {
        _depositReports.clear();
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
      _depositCubit.getDepositReport(
        startDateFormatted,
        endDateFormatted,
        page: _currentPage,
        depositType: widget.depositType,
      );
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DepositCubit, DepositState>(
      bloc: _depositCubit,
      listener: (context, state) {
        if (state is DepositLoaded) {
          setState(() {
            _isLoadingMore = false;
            if (state.depositReport.content == null ||
                state.depositReport.content!.isEmpty) {
              _hasReachedEnd = true;
            } else {
              // Update list
              _depositReports.addAll(state.depositReport.content!);
              _currentPage++;
              _hasReachedEnd = state.depositReport.last ?? false;
            }
          });
        } else if (state is DepositError) {
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
        if (state is DepositInitial) {
          _fetchDepositReport(true);
          return const Center(child: AppLoader());
        }

        // Loading state with empty list
        if (state is DepositLoading && _depositReports.isEmpty) {
          return const Center(child: AppLoader());
        }

        // Data loaded and list has items
        if (_depositReports.isNotEmpty) {
          return Column(
            children: [
              // _buildDepositTypeSelector(),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async => _fetchDepositReport(true),
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16.0),
                    itemCount:
                        _depositReports.length + (_isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _depositReports.length) {
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

                      return PaymentItem(payment: _depositReports[index]);
                    },
                  ),
                ),
              ),
            ],
          );
        }

        // Empty state
        return Column(
          children: [
            // _buildDepositTypeSelector(),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(LocaleKeys.report_no_deposit_records_found.tr()),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _fetchDepositReport(true),
                      child: Text(LocaleKeys.buttons_refresh.tr()),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Widget _buildDepositTypeSelector() {
  //   return Padding(
  //     padding: const EdgeInsets.all(16.0),
  //     child: Row(
  //       children: [
  //         Expanded(
  //           child: SegmentedButton<DepositType?>(
  //             segments: const [
  //               ButtonSegment(value: null, label: Text('All Deposits')),
  //               ButtonSegment(
  //                 value: DepositType.makeDeposit,
  //                 label: Text('Make Deposit'),
  //               ),
  //               ButtonSegment(
  //                 value: DepositType.paymentByDeposit,
  //                 label: Text('Payment by Deposit'),
  //               ),
  //             ],
  //             selected: {widget.depositType},
  //             onSelectionChanged: (newSelection) {
  //               if (context.mounted) {
  //                 // Pass the selected deposit type up to the parent
  //                 final newType = newSelection.first;
  //                 Navigator.of(context).pop();

  //                 // Wait for the pop animation to complete before recreating the widget
  //                 Future.delayed(const Duration(milliseconds: 300), () {
  //                   if (context.mounted) {
  //                     showModalBottomSheet(
  //                       context: context,
  //                       isScrollControlled: true,
  //                       useSafeArea: true,
  //                       builder:
  //                           (context) => SizedBox(
  //                             height: MediaQuery.of(context).size.height * 0.8,
  //                             child: DepositList(
  //                               startDate: widget.startDate,
  //                               endDate: widget.endDate,
  //                               depositType: newType,
  //                             ),
  //                           ),
  //                     );
  //                   }
  //                 });
  //               }
  //             },
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
