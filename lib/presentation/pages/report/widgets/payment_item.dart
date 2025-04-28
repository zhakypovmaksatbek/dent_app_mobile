import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/models/report/payment_report_model.dart';
import 'package:dent_app_mobile/presentation/theme/colors/color_constants.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class PaymentItem extends StatelessWidget {
  final PaymentReportModel payment;

  const PaymentItem({super.key, required this.payment});

  @override
  Widget build(BuildContext context) {
    final dateTime =
        payment.appointmentDateTime != null
            ? DateFormat(
              'dd MMM yyyy, HH:mm',
            ).format(DateTime.parse(payment.appointmentDateTime!))
            : 'N/A';

    final paymentDate =
        payment.payedDate != null
            ? DateFormat(
              'dd MMM yyyy',
            ).format(DateTime.parse(payment.payedDate!))
            : 'N/A';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
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
                        payment.patientFullName ??
                            LocaleKeys.report_unknown_patient.tr(),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${LocaleKeys.report_doctor.tr()}: ${payment.doctorFullName ?? LocaleKeys.report_unknown_doctor.tr()}',
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    '${payment.payed ?? 0}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoItem(
                  context,
                  LocaleKeys.report_appointment.tr(),
                  dateTime,
                ),
                _buildInfoItem(
                  context,
                  LocaleKeys.report_payment_date.tr(),
                  paymentDate,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoItem(
                  context,
                  LocaleKeys.report_payment_method.tr(),
                  payment.typeOfPayment ?? 'N/A',
                ),
                _buildInfoItem(
                  context,
                  'ID',
                  '#${payment.appointmentId?.toString().padLeft(4, '0') ?? 'N/A'}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, String label, String value) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: ColorConstants.textSecondary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
