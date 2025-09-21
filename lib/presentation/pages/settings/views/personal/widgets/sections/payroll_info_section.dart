import 'package:dent_app_mobile/core/utils/salary_type.dart';
import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/models/users/user_detail_model.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/personal/widgets/common/info_row_widget.dart';
import 'package:dent_app_mobile/presentation/widgets/card/custom_card_decoration.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class PayrollInfoSection extends StatelessWidget {
  const PayrollInfoSection({super.key, required this.payroll});

  final PayrollCalculationsResponse payroll;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CustomCardDecoration(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.payments_outlined,
                    color: Colors.orange,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  LocaleKeys.forms_role_salary.tr(),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            InfoRowWidget(
              icon: Icons.attach_money_outlined,
              label: LocaleKeys.forms_salary.tr(),
              value: _formatSalary(payroll.salary),
            ),
            const SizedBox(height: 12),
            InfoRowWidget(
              icon: Icons.category_outlined,
              label: LocaleKeys.forms_salary_type.tr(),
              value:
                  SalaryType.fromString(
                    payroll.percentOrFixed ?? '',
                  ).displayName.tr(),
            ),
          ],
        ),
      ),
    );
  }

  String _formatSalary(double? salary) {
    if (salary == null) return '-';
    return NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(salary);
  }
}
