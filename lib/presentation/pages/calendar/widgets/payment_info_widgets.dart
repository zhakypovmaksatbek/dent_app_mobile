import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/presentation/theme/colors/color_constants.dart';
import 'package:dent_app_mobile/presentation/widgets/text/app_text.dart';
import 'package:dent_app_mobile/presentation/widgets/text/price_convert_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class PaymentInfoCard extends StatelessWidget {
  const PaymentInfoCard({super.key, required this.appointmentId});

  final int appointmentId;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppText(
          title: 'Информация о записи',
          textType: TextType.title,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
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
          child: Row(
            children: [
              const Icon(Icons.event, color: AppColors.primary, size: 24),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppText(
                    title: 'ID записи',
                    textType: TextType.description,
                    color: AppColors.textSecondary,
                  ),
                  AppText(
                    title: appointmentId.toString(),
                    textType: TextType.title,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class PaymentServicesListCard extends StatelessWidget {
  const PaymentServicesListCard({
    super.key,
    required this.services,
    required this.formatAmount,
  });

  final List services;
  final String Function(double) formatAmount;

  @override
  Widget build(BuildContext context) {
    if (services.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          title: LocaleKeys.routes_services.tr(),
          textType: TextType.title,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        const SizedBox(height: 12),
        Container(
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
          child: ListView.separated(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: services.length,
            separatorBuilder:
                (context, index) => Container(
                  height: 1,
                  color: AppColors.divider,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                ),
            itemBuilder: (context, index) {
              final service = services[index];
              return PaymentServiceItem(
                service: service,
                formatAmount: formatAmount,
              );
            },
          ),
        ),
      ],
    );
  }
}

class PaymentServiceItem extends StatelessWidget {
  const PaymentServiceItem({
    super.key,
    required this.service,
    required this.formatAmount,
  });

  final dynamic service;
  final String Function(double) formatAmount;

  @override
  Widget build(BuildContext context) {
    final serviceName = service.name ?? 'Unnamed Service';
    final servicePrice = service.price ?? 0;
    final serviceQuantity = service.quantity ?? 0;
    final serviceSum = service.sum ?? 0;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      title: serviceName,
                      textType: TextType.body,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.medical_services,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Row(
                          children: [
                            PriceConvertWidget(
                              price: servicePrice,
                              textType: TextType.description,
                              color: AppColors.textSecondary,
                            ),
                            AppText(
                              title: ' ×$serviceQuantity',
                              textType: TextType.description,
                              color: AppColors.textSecondary,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  PriceConvertWidget(
                    price: serviceSum,
                    textType: TextType.body,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
