import 'package:dent_app_mobile/core/utils/payment_types.dart';
import 'package:dent_app_mobile/core/utils/salary_type.dart';
import 'package:dent_app_mobile/presentation/pages/calendar/bloc/pay_appointment/pay_appointment_cubit.dart';
import 'package:dent_app_mobile/presentation/theme/colors/color_constants.dart';
import 'package:dent_app_mobile/presentation/widgets/image/custom_asset_image.dart';
import 'package:dent_app_mobile/presentation/widgets/text/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PaymentTypeSelection extends StatelessWidget {
  const PaymentTypeSelection({super.key, required this.selectedPaymentType});

  final ValueNotifier<PaymentType> selectedPaymentType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppText(
          title: 'Способ оплаты',
          textType: TextType.body,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        const SizedBox(height: 12),
        ValueListenableBuilder<PaymentType>(
          valueListenable: selectedPaymentType,
          builder: (context, selectedType, child) {
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children:
                  PaymentType.values.map((type) {
                    final isSelected = selectedType == type;
                    return GestureDetector(
                      onTap: () => selectedPaymentType.value = type,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? type.color.withValues(alpha: 0.1)
                                  : AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? type.color : AppColors.divider,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomAssetImage(path: type.icon),
                            const SizedBox(width: 8),
                            AppText(
                              title: type.title,
                              textType: TextType.body,
                              fontWeight:
                                  isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                              color:
                                  isSelected
                                      ? type.color
                                      : AppColors.textPrimary,
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
            );
          },
        ),
      ],
    );
  }
}

class PaymentAmountInput extends StatelessWidget {
  const PaymentAmountInput({
    super.key,
    required this.controller,
    required this.maxAmount,
    required this.formatAmount,
  });

  final TextEditingController controller;
  final double maxAmount;
  final String Function(double) formatAmount;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const AppText(
              title: 'Сумма оплаты',
              textType: TextType.body,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => controller.text = maxAmount.toInt().toString(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: AppText(
                  title: 'макс. ${formatAmount(maxAmount)} сом',
                  textType: TextType.description,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Введите сумму',
            suffixText: 'сом',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
      ],
    );
  }
}

class PaymentDiscountInput extends StatelessWidget {
  const PaymentDiscountInput({
    super.key,
    required this.controller,
    required this.discountType,
  });

  final TextEditingController controller;
  final ValueNotifier<SalaryType> discountType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppText(
          title: 'Скидка (необязательно)',
          textType: TextType.body,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ValueListenableBuilder<SalaryType>(
                valueListenable: discountType,
                builder: (context, discountTypeValue, child) {
                  return TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: '0',
                      border: const OutlineInputBorder(),
                      suffixText:
                          discountTypeValue == SalaryType.percent ? '%' : 'сом',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (value) {
                      // If percentage and value > 100, set to 1
                      if (discountTypeValue == SalaryType.percent &&
                          value.isNotEmpty) {
                        final numValue = int.tryParse(value) ?? 0;
                        if (numValue > 100) {
                          controller.text = '1';
                          controller.selection = TextSelection.fromPosition(
                            TextPosition(offset: controller.text.length),
                          );
                        }
                      }
                    },
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            ValueListenableBuilder<SalaryType>(
              valueListenable: discountType,
              builder: (context, selectedType, child) {
                return Row(
                  children:
                      SalaryType.values.map((type) {
                        final isSelected = selectedType == type;
                        return GestureDetector(
                          onTap: () => discountType.value = type,
                          child: Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? AppColors.primary
                                      : AppColors.cardBackground,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color:
                                    isSelected
                                        ? AppColors.primary
                                        : AppColors.divider,
                              ),
                            ),
                            child: AppText(
                              title: type == SalaryType.percent ? '%' : 'сом',
                              textType: TextType.body,
                              fontWeight: FontWeight.w500,
                              color:
                                  isSelected
                                      ? AppColors.white
                                      : AppColors.textPrimary,
                            ),
                          ),
                        );
                      }).toList(),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}

class PaymentButton extends StatelessWidget {
  const PaymentButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PayAppointmentCubit, PayAppointmentState>(
      builder: (context, state) {
        final isLoading = state is PayAppointmentLoading;

        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child:
                isLoading
                    ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.white,
                        ),
                      ),
                    )
                    : const AppText(
                      title: 'Оплатить',
                      textType: TextType.body,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
          ),
        );
      },
    );
  }
}
