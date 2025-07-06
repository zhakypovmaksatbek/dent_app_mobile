import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/models/patient/patient_detail_model.dart';
import 'package:dent_app_mobile/presentation/pages/patient/core/util/patient_info_util.dart';
import 'package:dent_app_mobile/presentation/pages/patient/view/create_patient.dart';
import 'package:dent_app_mobile/presentation/widgets/card/custom_card_decoration.dart';
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with patient name and attention indicator
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.green.withValues(alpha: 0.1),
                  radius: 28,
                  child: const Icon(
                    Icons.person,
                    color: Colors.green,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
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
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (patientDetail.attention == true)
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.priority_high,
                                color: Colors.red,
                                size: 18,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      if (patientDetail.id != null)
                        Text(
                          'ID: ${patientDetail.id}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Personal Information Section
            _buildSectionHeader(
              context,
              'Personal Information',
              Icons.person_outline,
            ),
            const SizedBox(height: 12),

            if (patientDetail.birthDate != null &&
                patientDetail.birthDate!.isNotEmpty)
              _buildDetailRow(
                context,
                label: 'Age',
                value: _calculateAge(patientDetail.birthDate!),
                icon: Icons.cake_outlined,
                iconColor: Colors.blue,
              ),

            if (patientDetail.gender != null &&
                patientDetail.gender!.isNotEmpty)
              _buildDetailRow(
                context,
                label: LocaleKeys.forms_gender.tr(),
                value: Gender.fromString(patientDetail.gender!).title.tr(),
                icon: Icons.person_outline,
                iconColor: Colors.purple,
              ),

            if (patientDetail.createdAt != null &&
                patientDetail.createdAt!.isNotEmpty)
              _buildDetailRow(
                context,
                label: 'Patient Since',
                value: _formatDate(patientDetail.createdAt!),
                icon: Icons.calendar_today_outlined,
                iconColor: Colors.orange,
              ),

            const SizedBox(height: 16),

            // Contact Information Section
            _buildSectionHeader(
              context,
              'Contact Information',
              Icons.contact_phone,
            ),
            const SizedBox(height: 12),
            FutureBuilder<bool?>(
              future: PatientInfoUtil.getVisibilityPhoneNumber(),
              builder: (context, asyncSnapshot) {
                if (asyncSnapshot.data == true) {
                  return _buildDetailRow(
                    context,
                    label: 'Phone',
                    value: _formatPhoneNumber(patientDetail.phoneNumber ?? ""),
                    icon: Icons.phone,
                    iconColor: Colors.green,
                  );
                }
                return const SizedBox.shrink();
              },
            ),

            if (patientDetail.phoneNumber2 != null &&
                patientDetail.phoneNumber2!.isNotEmpty)
              _buildDetailRow(
                context,
                label: 'Secondary Phone',
                value: _formatPhoneNumber(patientDetail.phoneNumber2!),
                icon: Icons.phone_outlined,
                iconColor: Colors.teal,
              ),

            if (patientDetail.email != null && patientDetail.email!.isNotEmpty)
              _buildDetailRow(
                context,
                label: 'Email',
                value: patientDetail.email!,
                icon: Icons.email_outlined,
                iconColor: Colors.blue,
              ),

            const SizedBox(height: 16),

            // Financial Information Section
            _buildSectionHeader(
              context,
              'Financial Summary',
              Icons.account_balance_wallet,
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildFinancialCard(
                    context,
                    label: 'Debt',
                    amount: patientDetail.debt ?? 0,
                    color: Colors.red,
                    icon: Icons.trending_down,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildFinancialCard(
                    context,
                    label: 'Deposit',
                    amount: patientDetail.deposit ?? 0,
                    color: Colors.green,
                    icon: Icons.trending_up,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildFinancialCard(
                    context,
                    label: 'Payment',
                    amount: patientDetail.payment ?? 0,
                    color: Colors.blue,
                    icon: Icons.payment,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context,
                    label: 'Total Visits',
                    count: patientDetail.totalAppointment ?? 0,
                    color: Colors.purple,
                    icon: Icons.event,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Additional Information
            if (patientDetail.fromWhere != null &&
                patientDetail.fromWhere!.isNotEmpty) ...[
              _buildSectionHeader(
                context,
                'Additional Information',
                Icons.info_outline,
              ),
              const SizedBox(height: 12),
              _buildDetailRow(
                context,
                label: 'Source',
                value: _formatSource(patientDetail.fromWhere!),
                icon: Icons.source,
                iconColor: Colors.indigo,
              ),
            ],

            if (patientDetail.peculiarities != null &&
                patientDetail.peculiarities!.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildDetailRow(
                context,
                label: 'Notes',
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
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
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
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(width: 12),
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
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
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

  Widget _buildFinancialCard(
    BuildContext context, {
    required String label,
    required double amount,
    required Color color,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          PriceConvertWidget(
            price: amount,
            textType: TextType.header,
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            count.toString(),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _calculateAge(String birthDate) {
    try {
      final birth = DateTime.parse(birthDate);
      final now = DateTime.now();
      int age = now.year - birth.year;
      if (now.month < birth.month ||
          (now.month == birth.month && now.day < birth.day)) {
        age--;
      }
      return '$age years old';
    } catch (e) {
      return birthDate;
    }
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
