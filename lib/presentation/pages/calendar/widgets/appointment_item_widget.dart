import 'package:dent_app_mobile/models/appointment/calendar_appointment_model.dart';
import 'package:dent_app_mobile/presentation/pages/calendar/widgets/calendar_view_widget.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/personal/core/util/appointment_status.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/personal/core/util/record_type.dart';
import 'package:dent_app_mobile/presentation/widgets/card/custom_card_decoration.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class AppointmentItemWidget extends StatelessWidget {
  final CalendarAppointmentModel appointment;
  final Function(BuildContext, CalendarAppointmentModel) onEdit;
  final Function(BuildContext, CalendarAppointmentModel) onDelete;
  final Function(BuildContext, Appointment) onTap;

  const AppointmentItemWidget({
    super.key,
    required this.appointment,
    required this.onEdit,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    String timeRange = '';

    if (appointment.startTime != null && appointment.endTime != null) {
      final startTime = DateTime.parse(appointment.startTime!);
      final endTime = DateTime.parse(appointment.endTime!);
      timeRange =
          '${DateFormat('HH:mm', context.locale.languageCode).format(startTime)} - ${DateFormat('HH:mm', context.locale.languageCode).format(endTime)}';
    }

    // Get patient name, handling null values
    String patientName = 'Patient';
    if (appointment.patientFirsName != null ||
        appointment.patientLastName != null) {
      patientName =
          '${appointment.patientFirsName ?? ''} ${appointment.patientLastName ?? ''}'
              .trim();
    }

    return CustomCardDecoration(
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 12),

        title: Text(
          patientName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              timeRange,
              style: TextStyle(
                fontSize: 12,
                color:
                    AppointmentStatus.fromKey(
                      appointment.appointmentStatus ?? '',
                    ).color,
              ),
            ),
            Text(
              RecordType.fromString(
                appointment.recordType ?? '',
              ).displayName.tr(),
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, size: 16),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () => onEdit(context, appointment),
            ),

            IconButton(
              icon: const Icon(Icons.delete, size: 16, color: Colors.red),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () => onDelete(context, appointment),
            ),
          ],
        ),
        onTap:
            () => onTap(
              context,
              Appointment(
                startTime:
                    appointment.startTime != null
                        ? DateTime.parse(appointment.startTime!)
                        : DateTime.now(),
                endTime:
                    appointment.endTime != null
                        ? DateTime.parse(appointment.endTime!)
                        : DateTime.now().add(const Duration(hours: 1)),
                subject: patientName,
                notes: appointment.description,
                color:
                    AppointmentStatus.fromKey(
                      appointment.appointmentStatus ?? '',
                    ).color,
                resourceIds: [appointment],
              ),
            ),
      ),
    );
  }
}
