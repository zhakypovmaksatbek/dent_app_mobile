import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/models/report/report_model.dart';
import 'package:dent_app_mobile/presentation/pages/report/core/bloc/report/report_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/report/utils/date_utils.dart';
import 'package:dent_app_mobile/presentation/pages/report/widgets/financial_summary_card.dart';
import 'package:dent_app_mobile/presentation/pages/report/widgets/payment_method_card.dart';
import 'package:dent_app_mobile/presentation/pages/report/widgets/report_section_card.dart';
import 'package:dent_app_mobile/presentation/widgets/loading/app_loader.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OverviewTab extends StatefulWidget {
  final DateTime startDate;
  final DateTime endDate;
  final Function() onDateRangeSelect;

  const OverviewTab({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.onDateRangeSelect,
  });

  @override
  State<OverviewTab> createState() => _OverviewTabState();
}

class _OverviewTabState extends State<OverviewTab> {
  late final ReportCubit _reportCubit;

  @override
  void initState() {
    super.initState();
    _reportCubit = context.read<ReportCubit>();
    _fetchReport();
  }

  @override
  void didUpdateWidget(OverviewTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.startDate != widget.startDate ||
        oldWidget.endDate != widget.endDate) {
      _fetchReport();
    }
  }

  void _fetchReport() {
    final startDateFormatted = ReportDateUtils.formatForApi(widget.startDate);
    final endDateFormatted = ReportDateUtils.formatForApi(widget.endDate);
    _reportCubit.getReport(startDateFormatted, endDateFormatted);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReportCubit, ReportState>(
      bloc: _reportCubit,
      builder: (context, state) {
        return switch (state) {
          ReportInitial() => Center(
            child: Text(
              LocaleKeys.report_select_date_range_to_view_report.tr(),
            ),
          ),
          ReportLoading() => const Center(child: AppLoader()),
          ReportLoaded() => _buildReportContent(state.report),
          ReportError() => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(state.message),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _fetchReport,
                  child: Text(LocaleKeys.buttons_apply.tr()),
                ),
              ],
            ),
          ),
        };
      },
    );
  }

  Widget _buildReportContent(ReportModel report) {
    return RefreshIndicator(
      onRefresh: () async => _fetchReport(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16,
          children: [
            FinancialSummaryCard(report: report),
            PaymentMethodCard(report: report),
            if (report.reportByDateResponse != null)
              ReportSectionCard(
                title: LocaleKeys.report_appointments_summary.tr(),
                data: {
                  LocaleKeys.report_total_amount.tr():
                      report.reportByDateResponse!.appointment ?? '0',
                  LocaleKeys.report_invoices_issued.tr():
                      report.reportByDateResponse!.invoicesIssued ?? '0',
                  LocaleKeys.report_paid.tr():
                      report.reportByDateResponse!.paid ?? '0',
                  LocaleKeys.report_partly_paid.tr():
                      report.reportByDateResponse!.partly ?? '0',
                  LocaleKeys.report_not_paid.tr():
                      report.reportByDateResponse!.notPaid ?? '0',
                },
              ),
            if (report.reportDeptPaymentResponse != null)
              ReportSectionCard(
                title: LocaleKeys.report_debt_summary.tr(),
                data: {
                  LocaleKeys.report_debt_repayment.tr():
                      report.reportDeptPaymentResponse!.debtRepayment ?? '0',
                  LocaleKeys.report_discount.tr():
                      report.reportDeptPaymentResponse!.discount ?? '0',
                },
              ),
          ],
        ),
      ),
    );
  }
}
