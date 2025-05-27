import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/models/users/user_detail_model.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/personal/core/util/gender.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/personal/widgets/common/info_row_widget.dart';
import 'package:dent_app_mobile/presentation/widgets/card/custom_card_decoration.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class PersonalInfoSection extends StatelessWidget {
  const PersonalInfoSection({super.key, required this.user});

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
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.person_outline,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  LocaleKeys.forms_personal_info.tr(),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (user.patronymic != null && user.patronymic!.isNotEmpty)
              Column(
                children: [
                  InfoRowWidget(
                    icon: Icons.badge_outlined,
                    label: LocaleKeys.forms_patronymic.tr(),
                    value: user.patronymic!,
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            InfoRowWidget(
              icon: Icons.wc_outlined,
              label: LocaleKeys.forms_gender.tr(),
              value: Gender.fromString(user.gender ?? '-').displayName.tr(),
            ),
            if (user.birthDate != null) ...[
              const SizedBox(height: 12),
              InfoRowWidget(
                icon: Icons.cake_outlined,
                label: LocaleKeys.forms_birthday.tr(),
                value: _formatBirthDate(user.birthDate!),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatBirthDate(String birthDate) {
    try {
      final date = DateTime.parse(birthDate);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return birthDate;
    }
  }
}
