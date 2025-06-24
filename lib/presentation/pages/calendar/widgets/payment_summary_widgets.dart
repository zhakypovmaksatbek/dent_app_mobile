import 'package:dent_app_mobile/core/utils/salary_type.dart';
import 'package:dent_app_mobile/presentation/theme/colors/color_constants.dart';
import 'package:dent_app_mobile/presentation/widgets/text/app_text.dart';
import 'package:flutter/material.dart';

class PaymentCalculationSummary extends StatelessWidget {
  const PaymentCalculationSummary({
    super.key,
    required this.calculatedDiscount,
    required this.finalAmount,
    required this.amountController,
    required this.discountController,
    required this.discountType,
    required this.formatAmount,
  });

  final ValueNotifier<double> calculatedDiscount;
  final ValueNotifier<double> finalAmount;
  final TextEditingController amountController;
  final TextEditingController discountController;
  final ValueNotifier<SalaryType> discountType;
  final String Function(double) formatAmount;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: calculatedDiscount,
      builder: (context, discount, child) {
        return ValueListenableBuilder<double>(
          valueListenable: finalAmount,
          builder: (context, finalAmount, child) {
            final amountText = amountController.text.trim();
            final originalAmount = double.tryParse(amountText) ?? 0.0;

            // Only show summary if there's an amount entered
            if (originalAmount <= 0) {
              return const SizedBox.shrink();
            }

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider, width: 0.5),
              ),
              child: Column(
                children: [
                  // Original Amount
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const AppText(
                        title: 'Сумма к оплате:',
                        textType: TextType.body,
                        color: AppColors.textSecondary,
                      ),
                      AppText(
                        title: '${formatAmount(originalAmount)} сом',
                        textType: TextType.body,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ],
                  ),

                  // Discount (only show if discount > 0)
                  if (discount > 0) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AppText(
                          title:
                              'Скидка ${discountType.value == SalaryType.percent ? '(${discountController.text}%)' : ''}:',
                          textType: TextType.body,
                          color: AppColors.textSecondary,
                        ),
                        AppText(
                          title: '- ${formatAmount(discount)} сом',
                          textType: TextType.body,
                          fontWeight: FontWeight.w500,
                          color: AppColors.success,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(height: 1, color: AppColors.divider),
                    const SizedBox(height: 12),
                  ],

                  // Final Amount
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const AppText(
                        title: 'Итого к оплате:',
                        textType: TextType.title,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      AppText(
                        title: '${formatAmount(finalAmount)} сом',
                        textType: TextType.title,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class ReceiptPaymentSummary extends StatelessWidget {
  const ReceiptPaymentSummary({
    super.key,
    required this.receipt,
    required this.formatAmount,
  });

  final dynamic receipt;
  final String Function(double) formatAmount;

  @override
  Widget build(BuildContext context) {
    final totalAmount = receipt.totalAmount ?? 0;
    final additionalDiscount = receipt.additionalDiscount ?? 0;
    final totalAmountPayable = receipt.totalAmountPayable ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppText(
          title: 'Сводка по оплате',
          textType: TextType.title,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildSummaryRow('Общая сумма:', totalAmount.toDouble(), false),
              if (additionalDiscount > 0) ...[
                const SizedBox(height: 8),
                _buildSummaryRow(
                  'Дополнительная скидка:',
                  -additionalDiscount.toDouble(),
                  false,
                  isDiscount: true,
                ),
              ],
              const SizedBox(height: 12),
              Container(height: 1, color: AppColors.divider),
              const SizedBox(height: 12),
              _buildSummaryRow(
                'К оплате:',
                totalAmountPayable.toDouble(),
                true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(
    String label,
    double amount,
    bool isTotal, {
    bool isDiscount = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppText(
          title: label,
          textType: isTotal ? TextType.title : TextType.body,
          fontWeight: isTotal ? FontWeight.w600 : FontWeight.w400,
          color: AppColors.textPrimary,
        ),
        AppText(
          title: '${isDiscount ? '-' : ''}${formatAmount(amount)} сом',
          textType: isTotal ? TextType.title : TextType.body,
          fontWeight: FontWeight.w600,
          color:
              isDiscount
                  ? AppColors.success
                  : (isTotal ? AppColors.primary : AppColors.textPrimary),
        ),
      ],
    );
  }
}

class PaymentStatusCards extends StatelessWidget {
  const PaymentStatusCards({
    super.key,
    required this.receipt,
    required this.formatAmount,
  });

  final dynamic receipt;
  final String Function(double) formatAmount;

  @override
  Widget build(BuildContext context) {
    final paid = receipt.paid ?? 0;
    final debt = receipt.debt ?? 0;
    final balance = receipt.balance ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppText(
          title: 'Статус оплаты',
          textType: TextType.title,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: PaymentStatusCard(
                title: 'Оплачено',
                amount: paid.toDouble(),
                color: AppColors.success,
                icon: Icons.check_circle,
                formatAmount: formatAmount,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: PaymentStatusCard(
                title: 'Долг',
                amount: debt.toDouble(),
                color: debt > 0 ? AppColors.error : AppColors.textSecondary,
                icon: debt > 0 ? Icons.error : Icons.check_circle_outline,
                formatAmount: formatAmount,
              ),
            ),
          ],
        ),
        if (balance > 0) ...[
          const SizedBox(height: 12),
          PaymentStatusCard(
            title: 'Баланс',
            amount: balance.toDouble(),
            color: AppColors.warning,
            icon: Icons.account_balance_wallet,
            formatAmount: formatAmount,
            isFullWidth: true,
          ),
        ],
      ],
    );
  }
}

class PaymentStatusCard extends StatelessWidget {
  const PaymentStatusCard({
    super.key,
    required this.title,
    required this.amount,
    required this.color,
    required this.icon,
    required this.formatAmount,
    this.isFullWidth = false,
  });

  final String title;
  final double amount;
  final Color color;
  final IconData icon;
  final String Function(double) formatAmount;
  final bool isFullWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              AppText(
                title: title,
                textType: TextType.description,
                color: AppColors.textSecondary,
              ),
            ],
          ),
          const SizedBox(height: 4),
          AppText(
            title: '${formatAmount(amount)} сом',
            textType: TextType.title,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ],
      ),
    );
  }
}
