import 'package:dent_app_mobile/core/repo/url_launcher_repo/launcher_repo.dart';
import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/models/patient/patient_detail_model.dart';
import 'package:dent_app_mobile/presentation/constants/asset_constants.dart';
import 'package:dent_app_mobile/presentation/pages/patient/core/util/patient_info_util.dart';
import 'package:dent_app_mobile/presentation/pages/patient/view/create_patient.dart';
import 'package:dent_app_mobile/presentation/widgets/card/custom_card_decoration.dart';
import 'package:dent_app_mobile/presentation/widgets/image/custom_asset_image.dart';
import 'package:dent_app_mobile/presentation/widgets/snack_bars/app_snack_bar.dart';
import 'package:dent_app_mobile/presentation/widgets/text/app_text.dart';
import 'package:dent_app_mobile/presentation/widgets/text/price_convert_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class PersonalInfoCard extends StatelessWidget {
  const PersonalInfoCard({super.key, required this.patientDetail});
  final PatientDetailModel patientDetail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CustomCardDecoration(
      child: Padding(
        padding: const EdgeInsets.all(12), // Reduced from 16
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with patient name and attention indicator
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.green.withValues(alpha: 0.1),
                  radius: 24, // Reduced from 28
                  child: const Icon(
                    Icons.person,
                    color: Colors.green,
                    size: 24, // Reduced from 28
                  ),
                ),
                const SizedBox(width: 12), // Reduced from 16
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${patientDetail.firstName ?? ''} ${patientDetail.lastName ?? ''}'
                                  .trim(),
                              style: theme.textTheme.titleMedium?.copyWith(
                                // Changed from titleLarge
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (patientDetail.attention == true)
                            Container(
                              padding: const EdgeInsets.all(
                                4,
                              ), // Reduced from 6
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.priority_high,
                                color: Colors.red,
                                size: 16, // Reduced from 18
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12), // Reduced from 20
            // Personal Information Section
            _buildSectionHeader(
              context,
              LocaleKeys.general_personal_information.tr(),
              Icons.person_outline,
            ),
            const SizedBox(height: 8), // Reduced from 12
            // Combined Age, Gender, Patient Since in one row
            Row(
              children: [
                if (patientDetail.birthDate != null &&
                    patientDetail.birthDate!.isNotEmpty)
                  Expanded(
                    child: _buildInfoCard(
                      context,
                      icon: Icons.cake_outlined,
                      iconColor: Colors.blue,
                      label: LocaleKeys.forms_birthday.tr(),
                      value: _formatDate(patientDetail.birthDate!),
                    ),
                  ),
                if (patientDetail.birthDate != null &&
                    patientDetail.birthDate!.isNotEmpty &&
                    patientDetail.gender != null &&
                    patientDetail.gender!.isNotEmpty)
                  const SizedBox(width: 6),
                if (patientDetail.gender != null &&
                    patientDetail.gender!.isNotEmpty)
                  Expanded(
                    child: _buildInfoCard(
                      context,
                      icon: Icons.person_outline,
                      iconColor: Colors.purple,
                      label: LocaleKeys.general_gender.tr(),
                      value:
                          Gender.fromString(patientDetail.gender!).title.tr(),
                    ),
                  ),
                if (patientDetail.gender != null &&
                    patientDetail.gender!.isNotEmpty &&
                    patientDetail.createdAt != null &&
                    patientDetail.createdAt!.isNotEmpty)
                  const SizedBox(width: 6),
                if (patientDetail.createdAt != null &&
                    patientDetail.createdAt!.isNotEmpty)
                  Expanded(
                    child: _buildInfoCard(
                      context,
                      icon: Icons.calendar_today_outlined,
                      iconColor: Colors.orange,
                      label: LocaleKeys.general_registration_date.tr(),
                      value: _formatDate(patientDetail.createdAt!),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 10), // Reduced from 16
            // Contact Information Section
            _buildSectionHeader(
              context,
              LocaleKeys.forms_contact_info.tr(),
              Icons.contact_phone,
            ),
            const SizedBox(height: 8), // Reduced from 12
            FutureBuilder<bool?>(
              future: PatientInfoUtil.getVisibilityPhoneNumber(),
              builder: (context, asyncSnapshot) {
                if (asyncSnapshot.data == true) {
                  return _buildPhoneDetailRow(
                    context,
                    label: LocaleKeys.forms_phone.tr(),
                    phoneNumber: patientDetail.phoneNumber ?? "",
                    icon: Icons.phone,
                    iconColor: Colors.green,
                  );
                }
                return const AppText(
                  title: "********",
                  textType: TextType.subtitle,
                );
              },
            ),

            if (patientDetail.phoneNumber2 != null &&
                patientDetail.phoneNumber2!.isNotEmpty)
              _buildPhoneDetailRow(
                context,
                label: LocaleKeys.forms_secondary_phone_number.tr(),
                phoneNumber: patientDetail.phoneNumber2!,
                icon: Icons.phone_outlined,
                iconColor: Colors.teal,
              ),

            if (patientDetail.email != null && patientDetail.email!.isNotEmpty)
              _buildDetailRow(
                context,
                label: LocaleKeys.forms_email.tr(),
                value: patientDetail.email!,
                icon: Icons.email_outlined,
                iconColor: Colors.blue,
              ),

            const SizedBox(height: 10), // Reduced from 16
            // Financial Information Section
            _buildSectionHeader(
              context,
              LocaleKeys.general_financial_summary.tr(),
              Icons.account_balance_wallet,
            ),
            const SizedBox(height: 8), // Reduced from 12

            Row(
              children: [
                Expanded(
                  child: _buildFinancialCard(
                    context,
                    label: LocaleKeys.forms_debt.tr(),
                    amount: patientDetail.debt ?? 0,
                    color: Colors.red,
                    icon: Icons.trending_down,
                  ),
                ),
                const SizedBox(width: 8), // Reduced from 12
                Expanded(
                  child: _buildFinancialCard(
                    context,
                    label: LocaleKeys.forms_deposit.tr(),
                    amount: patientDetail.deposit ?? 0,
                    color: Colors.green,
                    icon: Icons.trending_up,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8), // Reduced from 12

            Row(
              children: [
                Expanded(
                  child: _buildFinancialCard(
                    context,
                    label: LocaleKeys.forms_payment.tr(),
                    amount: patientDetail.payment ?? 0,
                    color: Colors.blue,
                    icon: Icons.payment,
                  ),
                ),
                const SizedBox(width: 8), // Reduced from 12
                Expanded(
                  child: _buildStatCard(
                    context,
                    label: LocaleKeys.general_total_visits.tr(),
                    count: patientDetail.totalAppointment ?? 0,
                    color: Colors.purple,
                    icon: Icons.event,
                  ),
                ),
              ],
            ),

            // Additional Information
            if (patientDetail.fromWhere != null &&
                patientDetail.fromWhere!.isNotEmpty) ...[
              const SizedBox(height: 10), // Reduced from 16
              _buildSectionHeader(
                context,
                LocaleKeys.general_additional_information.tr(),
                Icons.info_outline,
              ),
              const SizedBox(height: 8), // Reduced from 12
              _buildDetailRow(
                context,
                label: LocaleKeys.general_source.tr(),
                value: _formatSource(patientDetail.fromWhere!),
                icon: Icons.source,
                iconColor: Colors.indigo,
              ),
            ],

            if (patientDetail.peculiarities != null &&
                patientDetail.peculiarities!.isNotEmpty) ...[
              const SizedBox(height: 6), // Reduced from 8
              _buildDetailRow(
                context,
                label: LocaleKeys.appointment_notes.tr(),
                value: patientDetail.peculiarities!,
                icon: Icons.note_outlined,
                iconColor: Colors.brown,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: theme.colorScheme.primary,
        ), // Reduced from 20
        const SizedBox(width: 6), // Reduced from 8
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            // Changed from titleMedium
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8), // Reduced from 12
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(4), // Reduced from 6
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6), // Reduced from 8
            ),
            child: Icon(icon, size: 14, color: iconColor), // Reduced from 16
          ),
          const SizedBox(width: 8), // Reduced from 12
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 1), // Reduced from 2
                Text(
                  value,
                  style: theme.textTheme.bodySmall?.copyWith(
                    // Changed from bodyMedium
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneDetailRow(
    BuildContext context, {
    required String label,
    required String phoneNumber,
    required IconData icon,
    required Color iconColor,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 14, color: iconColor),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  _formatPhoneNumber(phoneNumber),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Action buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Call button
              IconButton(
                onPressed: () => _makeCall(context, phoneNumber),
                icon: const Icon(Icons.call, size: 18),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.green.withValues(alpha: 0.1),
                  foregroundColor: Colors.green,
                  padding: const EdgeInsets.all(8),
                  minimumSize: const Size(32, 32),
                ),
                tooltip: LocaleKeys.buttons_call.tr(),
              ),
              const SizedBox(width: 4),
              // WhatsApp button
              IconButton(
                onPressed: () => _openWhatsApp(context, phoneNumber),
                icon: CustomAssetImage(
                  path: AssetConstants.whatsapp.svg,
                  isSvg: true,
                  height: 20,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.green.withValues(alpha: 0.1),
                  foregroundColor: Colors.green,
                  padding: const EdgeInsets.all(8),
                  minimumSize: const Size(32, 32),
                ),
                tooltip: 'WhatsApp',
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Call functionality
  void _makeCall(BuildContext context, String phoneNumber) async {
    try {
      await LauncherRepo().call(phoneNumber);
    } catch (e) {
      if (context.mounted) {
        AppSnackBar.showErrorSnackBar(context, e.toString());
      }
    }
  }

  // WhatsApp functionality
  void _openWhatsApp(BuildContext context, String phoneNumber) async {
    try {
      await LauncherRepo().whatsapp(
        phoneNumber,
        userName:
            '${patientDetail.firstName ?? ''} ${patientDetail.lastName ?? ''}'
                .trim(),
      );
    } catch (e) {
      if (context.mounted) {
        AppSnackBar.showErrorSnackBar(context, e.toString());
      }
    }
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: iconColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 16),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: iconColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialCard(
    BuildContext context, {
    required String label,
    required double amount,
    required Color color,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(8), // Reduced from 12
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8), // Reduced from 12
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 16), // Reduced from 20
          const SizedBox(height: 4), // Reduced from 8
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2), // Reduced from 4
          PriceConvertWidget(
            price: amount,
            textType: TextType.subtitle, // Changed from header
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String label,
    required int count,
    required Color color,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(8), // Reduced from 12
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8), // Reduced from 12
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 16), // Reduced from 20
          const SizedBox(height: 4), // Reduced from 8
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2), // Reduced from 4
          Text(
            count.toString(),
            style: theme.textTheme.bodyLarge?.copyWith(
              // Changed from titleSmall
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  String _formatPhoneNumber(String phoneNumber) {
    // Format phone number for display
    if (phoneNumber.startsWith('996')) {
      return '+$phoneNumber';
    }
    return phoneNumber;
  }

  String _formatSource(String source) {
    switch (source.toUpperCase()) {
      case 'INSTAGRAM':
        return 'Instagram';
      case 'FACEBOOK':
        return 'Facebook';
      case 'WHATSAPP':
        return 'WhatsApp';
      case 'TELEGRAM':
        return 'Telegram';
      case 'REFERRAL':
        return 'Referral';
      case 'WEBSITE':
        return 'Website';
      default:
        return source;
    }
  }
}
