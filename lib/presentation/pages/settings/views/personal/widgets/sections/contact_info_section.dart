import 'package:dent_app_mobile/core/utils/format_utils.dart';
import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/models/users/user_detail_model.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/personal/widgets/common/info_row_widget.dart';
import 'package:dent_app_mobile/presentation/widgets/card/custom_card_decoration.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class ContactInfoSection extends StatelessWidget {
  const ContactInfoSection({super.key, required this.user});

  final UserDetailModel user;

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
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.contact_phone_outlined,
                    color: Colors.green,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  LocaleKeys.forms_contact_info.tr(),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            InfoRowWidget(
              icon: Icons.phone_outlined,
              label: LocaleKeys.forms_phone.tr(),
              value: FormatUtils.formatPhoneNumber(user.phoneNumber ?? '-'),
              showVisibilityStatus: true,
              isVisible: user.isVisibilityPhoneNumber ?? false,
            ),
            if (user.phoneNumber2 != null && user.phoneNumber2!.isNotEmpty) ...[
              const SizedBox(height: 12),
              InfoRowWidget(
                icon: Icons.phone_iphone_outlined,
                label: LocaleKeys.forms_alternative_phone.tr(),
                value: FormatUtils.formatPhoneNumber(user.phoneNumber2!),
              ),
            ],
            const SizedBox(height: 12),
            InfoRowWidget(
              icon: Icons.email_outlined,
              label: LocaleKeys.forms_email.tr(),
              value: user.email ?? '-',
            ),
          ],
        ),
      ),
    );
  }
}
