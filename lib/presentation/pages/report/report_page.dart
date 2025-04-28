import 'package:auto_route/annotations.dart';
import 'package:dent_app_mobile/core/repo/report/report_repo.dart';
import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/presentation/pages/report/widgets/date_range_picker.dart';
import 'package:dent_app_mobile/presentation/pages/report/widgets/debtor_list.dart';
import 'package:dent_app_mobile/presentation/pages/report/widgets/deposit_list.dart';
import 'package:dent_app_mobile/presentation/pages/report/widgets/discount_list.dart';
import 'package:dent_app_mobile/presentation/pages/report/widgets/overview_tab.dart';
import 'package:dent_app_mobile/presentation/pages/report/widgets/payments_list.dart';
import 'package:dent_app_mobile/presentation/theme/colors/color_constants.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

@RoutePage(name: 'ReportRoute')
class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  final _datePickerKey = GlobalKey<DateRangePickerState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  void _handleDateRangeChanged(DateTime startDate, DateTime endDate) {
    setState(() {
      _startDate = startDate;
      _endDate = endDate;
    });
  }

  void _showDiscountBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder:
          (context) => SizedBox(
            height: MediaQuery.of(context).size.height * 0.8,
            child: DiscountList(startDate: _startDate, endDate: _endDate),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.routes_report.tr()),
        actions: [
          DateRangePicker(
            key: _datePickerKey,
            startDate: _startDate,
            endDate: _endDate,
            onDateRangeChanged: _handleDateRangeChanged,
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade300, width: 1),
              ),
            ),
            child: TabBar(
              isScrollable: true,
              controller: _tabController,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 14,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              labelPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              indicatorSize: TabBarIndicatorSize.label,
              indicatorWeight: 3,
              labelColor: ColorConstants.primary,
              unselectedLabelColor: Colors.grey.shade600,
              tabs: [
                Tab(text: LocaleKeys.report_overview.tr()),
                Tab(text: LocaleKeys.report_payments.tr()),
                Tab(text: LocaleKeys.report_deposits.tr()),
                Tab(text: LocaleKeys.report_discounts.tr()),
                Tab(text: LocaleKeys.report_debtors.tr()),
              ],
              indicatorColor: AppColors.primary,
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Overview
          OverviewTab(
            startDate: _startDate,
            endDate: _endDate,
            onDateRangeSelect: _openDateRangePicker,
          ),

          // Tab 2: Payments
          PaymentsList(startDate: _startDate, endDate: _endDate),

          // Tab 3: Deposits
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LocaleKeys.report_deposit_reports.tr(),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 24),

                // Make Deposit button
                _buildReportButton(
                  context: context,
                  icon: Icons.arrow_downward,
                  title: LocaleKeys.report_make_deposit.tr(),
                  description: LocaleKeys.report_view_deposit_reports.tr(),
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      useSafeArea: true,
                      builder:
                          (context) => SizedBox(
                            height: MediaQuery.of(context).size.height * 0.8,
                            child: DepositList(
                              startDate: _startDate,
                              endDate: _endDate,
                              depositType: DepositType.makeDeposit,
                            ),
                          ),
                    );
                  },
                ),

                const SizedBox(height: 16),

                // Payment by Deposit button
                _buildReportButton(
                  context: context,
                  icon: Icons.arrow_upward,
                  title: LocaleKeys.report_payment_by_deposit.tr(),
                  description: LocaleKeys.report_view_payments_reports.tr(),
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      useSafeArea: true,
                      builder:
                          (context) => SizedBox(
                            height: MediaQuery.of(context).size.height * 0.8,
                            child: DepositList(
                              startDate: _startDate,
                              endDate: _endDate,
                              depositType: DepositType.paymentByDeposit,
                            ),
                          ),
                    );
                  },
                ),

                const SizedBox(height: 16),

                // All Deposits button
                _buildReportButton(
                  context: context,
                  icon: Icons.swap_vert,
                  title: LocaleKeys.report_all_deposit_transactions.tr(),
                  description:
                      LocaleKeys.report_view_all_deposit_transactions.tr(),
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      useSafeArea: true,
                      builder:
                          (context) => SizedBox(
                            height: MediaQuery.of(context).size.height * 0.8,
                            child: DepositList(
                              startDate: _startDate,
                              endDate: _endDate,
                              depositType: null,
                            ),
                          ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Tab 4: Discounts
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LocaleKeys.report_discount_reports.tr(),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 24),

                _buildReportButton(
                  context: context,
                  icon: Icons.discount,
                  title: LocaleKeys.report_discount_transactions.tr(),
                  description:
                      LocaleKeys.report_view_all_discount_transactions.tr(),
                  onTap: () => _showDiscountBottomSheet(context),
                ),

                const SizedBox(height: 24),

                // Help text
                Card(
                  color: ColorConstants.primary.withValues(alpha: .1),
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: AppColors.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            LocaleKeys
                                .report_discount_are_applied_to_patient_invoices
                                .tr(),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Tab 5: Debtors
          DebtorList(startDate: _startDate, endDate: _endDate),
        ],
      ),
    );
  }

  Widget _buildReportButton({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      color: ColorConstants.primary.withValues(alpha: .08),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppColors.primary, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey.shade600,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openDateRangePicker() {
    // Use the key to access the DateRangePicker state and show the menu
    _datePickerKey.currentState?.showDateRangeMenu();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
