import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/models/report/payment_report_model.dart';
import 'package:dent_app_mobile/presentation/pages/report/core/bloc/payment/payment_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/report/utils/date_utils.dart';
import 'package:dent_app_mobile/presentation/pages/report/widgets/payment_item.dart';
import 'package:dent_app_mobile/presentation/widgets/loading/app_loader.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PaymentsList extends StatefulWidget {
  final DateTime startDate;
  final DateTime endDate;

  const PaymentsList({
    super.key,
    required this.startDate,
    required this.endDate,
  });

  @override
  State<PaymentsList> createState() => _PaymentsListState();
}

class _PaymentsListState extends State<PaymentsList> {
  final _scrollController = ScrollController();
  final List<PaymentReportModel> _paymentReports = [];
  int _currentPage = 1;
  bool _isLoadingMore = false;
  bool _hasReachedEnd = false;
  late final PaymentCubit _paymentCubit;

  @override
  void initState() {
    super.initState();
    _paymentCubit = context.read<PaymentCubit>();
    _scrollController.addListener(_onScroll);
    // Initial fetch
    _fetchPaymentReport(true);
  }

  @override
  void didUpdateWidget(PaymentsList oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload if date range changes
    if (oldWidget.startDate != widget.startDate ||
        oldWidget.endDate != widget.endDate) {
      _fetchPaymentReport(true);
    }
  }

  void _onScroll() {
    if (!_isLoadingMore && !_hasReachedEnd) {
      if (_scrollController.position.pixels >
          _scrollController.position.maxScrollExtent - 200) {
        _fetchPaymentReport(false);
      }
    }
  }

  void _fetchPaymentReport(bool reset) {
    if (reset) {
      setState(() {
        _paymentReports.clear();
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
      _paymentCubit.getPaymentReport(
        startDateFormatted,
        endDateFormatted,
        page: _currentPage,
        size: 10, // Items per page
      );
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PaymentCubit, PaymentState>(
      bloc: _paymentCubit,
      listener: (context, state) {
        if (state is PaymentLoaded) {
          setState(() {
            _isLoadingMore = false;
            if (state.paymentReport.content == null ||
                state.paymentReport.content!.isEmpty) {
              _hasReachedEnd = true;
            } else {
              // Update list
              _paymentReports.addAll(state.paymentReport.content!);
              _currentPage++;
              _hasReachedEnd = state.paymentReport.last ?? false;
            }
          });
        } else if (state is PaymentError) {
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
        if (state is PaymentInitial) {
          _fetchPaymentReport(true);
          return const Center(child: AppLoader());
        }

        // Loading state with empty list
        if (state is PaymentLoading && _paymentReports.isEmpty) {
          return const Center(child: AppLoader());
        }

        // Data loaded and list has items
        if (_paymentReports.isNotEmpty) {
          return RefreshIndicator(
            onRefresh: () async => _fetchPaymentReport(true),
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              itemCount: _paymentReports.length + (_isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _paymentReports.length) {
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

                return PaymentItem(payment: _paymentReports[index]);
              },
            ),
          );
        }

        // Empty state
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(LocaleKeys.report_no_payment_records_found.tr()),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _fetchPaymentReport(true),
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
