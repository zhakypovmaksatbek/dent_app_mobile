import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/models/report/report_model.dart';
import 'package:dent_app_mobile/presentation/theme/colors/color_constants.dart';
import 'package:dent_app_mobile/presentation/widgets/card/custom_card_decoration.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class PaymentMethodCard extends StatelessWidget {
  final ReportModel report;

  const PaymentMethodCard({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return CustomCardDecoration(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LocaleKeys.report_payment_method.tr(),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: ColorConstants.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildPaymentMethodItem(
              context,
              LocaleKeys.report_cash.tr(),
              report.cash ?? '0',
              AppColors.cash,
              Icons.payments_outlined,
            ),
            const Divider(),
            _buildPaymentMethodItem(
              context,
              LocaleKeys.report_without_cash.tr(),
              report.withoutCash ?? '0',
              AppColors.card,
              Icons.credit_card,
            ),
            const Divider(),
            _buildPaymentMethodItem(
              context,
              LocaleKeys.report_mbank.tr(),
              report.mbank ?? '0',
              AppColors.mbank,
              Icons.account_balance,
            ),
            const Divider(),
            _buildPaymentMethodItem(
              context,
              LocaleKeys.report_optima.tr(),
              report.optima ?? '0',
              AppColors.optima,
              Icons.account_balance_wallet,
            ),
            if (_isGreaterThanZero(report.discount)) ...[
              const Divider(),
              _buildPaymentMethodItem(
                context,
                LocaleKeys.report_discount.tr(),
                report.discount ?? '0',
                AppColors.warning,
                Icons.local_offer,
              ),
            ],
            if (_isGreaterThanZero(report.paymentByDeposit)) ...[
              const Divider(),
              _buildPaymentMethodItem(
                context,
                LocaleKeys.report_payment_by_deposit.tr(),
                report.paymentByDeposit ?? '0',
                AppColors.accent,
                Icons.savings,
              ),
            ],
            if (_isGreaterThanZero(report.makeDeposit)) ...[
              const Divider(),
              _buildPaymentMethodItem(
                context,
                LocaleKeys.report_make_deposit.tr(),
                report.makeDeposit ?? '0',
                AppColors.secondary,
                Icons.savings_outlined,
              ),
            ],
          ],
        ),
      ),
    );
  }

  bool _isGreaterThanZero(String? value) {
    if (value == null) return false;
    final numValue = double.tryParse(value);
    return numValue != null && numValue > 0;
  }

  Widget _buildPaymentMethodItem(
    BuildContext context,
    String title,
    String amount,
    Color color,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withValues(alpha: .3)),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: AppColors.textPrimary),
            ),
          ),
          Text(
            amount,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
