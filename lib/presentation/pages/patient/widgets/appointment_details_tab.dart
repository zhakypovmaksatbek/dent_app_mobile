import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/models/appointment/appointment_model.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/personal/core/util/appointment_status.dart';
import 'package:dent_app_mobile/presentation/widgets/card/custom_card_decoration.dart';
import 'package:dent_app_mobile/presentation/widgets/text/app_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class AppointmentDetailsTab extends StatelessWidget {
  final AppointmentModel appointment;
  final Function(BuildContext, AppointmentModel) onShowCommentDialog;

  const AppointmentDetailsTab({
    super.key,
    required this.appointment,
    required this.onShowCommentDialog,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Format the date
    String formattedDate = '';
    if (appointment.startDate != null) {
      final dateTime = DateTime.parse(appointment.startDate!);
      formattedDate = DateFormat('dd MMMM yyyy, HH:mm').format(dateTime);
    }

    // Get status color

    final appointmentId = appointment.userResponse?.id;
    final canUpdate = appointmentId != null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Appointment header with basic info
          CustomCardDecoration(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: theme.colorScheme.primary.withOpacity(
                          0.1,
                        ),
                        radius: 24,
                        child: Icon(
                          Icons.calendar_today,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              title: formattedDate,
                              textType: TextType.body,
                              fontWeight: FontWeight.w600,
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppointmentStatus.fromKey(
                                  appointment.appointmentStatus ?? '',
                                ).color.withValues(alpha: .1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: AppText(
                                title: _formatStatus(
                                  appointment.appointmentStatus ?? '',
                                ),
                                textType: TextType.subtitle,
                                color:
                                    AppointmentStatus.fromKey(
                                      appointment.appointmentStatus ?? '',
                                    ).color,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (appointment.room != null) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.room, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          appointment.room!,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Doctor info
          if (appointment.userResponse != null)
            _buildPersonCard(
              context,
              title: LocaleKeys.report_doctor.tr(),
              name:
                  '${appointment.userResponse!.firstName ?? ''} ${appointment.userResponse!.lastName ?? ''}',
              id: appointment.userResponse!.id,
              icon: Icons.medical_services,
              iconColor: Colors.blue,
            ),

          const SizedBox(height: 16),

          // Patient info
          if (appointment.patientResponse != null)
            _buildPersonCard(
              context,
              title: LocaleKeys.appointment_patient.tr(),
              name:
                  '${appointment.patientResponse!.firstName ?? ''} ${appointment.patientResponse!.lastName ?? ''}',
              id: appointment.patientResponse!.id,
              icon: Icons.person,
              iconColor: Colors.green,
            ),

          const SizedBox(height: 16),

          // Medical details
          CustomCardDecoration(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppText(
                        title: LocaleKeys.appointment_medical_details.tr(),
                        textType: TextType.header,
                        fontWeight: FontWeight.bold,
                      ),

                      if (canUpdate)
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          onPressed:
                              () => onShowCommentDialog(context, appointment),
                          tooltip:
                              LocaleKeys.appointment_edit_medical_details.tr(),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  if (appointment.complaints != null &&
                      appointment.complaints!.isNotEmpty)
                    _buildInfoRow(
                      context,
                      label: LocaleKeys.appointment_complaints.tr(),
                      value: appointment.complaints!,
                      icon: Icons.warning_amber_rounded,
                      iconColor: Colors.orange,
                    ),

                  if (appointment.appDescription != null &&
                      appointment.appDescription!.isNotEmpty)
                    _buildInfoRow(
                      context,
                      label: LocaleKeys.appointment_diagnosis.tr(),
                      value: appointment.appDescription!,
                      icon: Icons.medical_information,
                      iconColor: Colors.purple,
                    ),

                  if (appointment.oldDiseases != null &&
                      appointment.oldDiseases!.isNotEmpty)
                    _buildInfoRow(
                      context,
                      label: LocaleKeys.appointment_medical_history.tr(),
                      value: appointment.oldDiseases!,
                      icon: Icons.history,
                      iconColor: Colors.brown,
                    ),

                  if (appointment.xRayDescription != null &&
                      appointment.xRayDescription!.isNotEmpty)
                    _buildInfoRow(
                      context,
                      label: LocaleKeys.appointment_x_ray_description.tr(),
                      value: appointment.xRayDescription!,
                      icon: Icons.image,
                      iconColor: Colors.teal,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonCard(
    BuildContext context, {
    required String title,
    required String name,
    required int? id,
    required IconData icon,
    required Color iconColor,
  }) {
    return CustomCardDecoration(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: iconColor.withOpacity(0.1),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(name, style: Theme.of(context).textTheme.titleMedium),
                  if (id != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      'ID: $id',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(value, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatStatus(String status) {
    // Convert from SNAKE_CASE to Title Case
    final words = AppointmentStatus.fromKey(status).label;
    return words.tr();
  }
}
