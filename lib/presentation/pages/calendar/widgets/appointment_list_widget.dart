import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/models/appointment/calendar_appointment_model.dart';
import 'package:dent_app_mobile/presentation/pages/calendar/widgets/appointment_item_widget.dart';
import 'package:dent_app_mobile/presentation/pages/calendar/widgets/calendar_view_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class AppointmentListWidget extends StatelessWidget {
  final List<CalendarAppointmentModel> appointments;
  final DateTime selectedDate;
  final Function(BuildContext, CalendarAppointmentModel) onEdit;
  final Function(BuildContext, CalendarAppointmentModel) onDelete;
  final Function(BuildContext, Appointment) onTap;
  final Function(BuildContext, {DateTime? initialDate}) onAddAppointment;

  const AppointmentListWidget({
    super.key,
    required this.appointments,
    required this.selectedDate,
    required this.onEdit,
    required this.onDelete,
    required this.onTap,
    required this.onAddAppointment,
  });

  @override
  Widget build(BuildContext context) {
    if (appointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              LocaleKeys.appointment_no_appointments_for_date.tr(
                namedArgs: {
                  'date': DateFormat(
                    'EEEE,d MMMM',
                    context.locale.languageCode,
                  ).format(selectedDate),
                },
              ),
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            TextButton.icon(
              onPressed:
                  () => onAddAppointment(context, initialDate: selectedDate),
              icon: const Icon(Icons.add),
              label: Text(LocaleKeys.buttons_add_appointment.tr()),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
          child: Text(
            LocaleKeys.appointment_appointments_for_date.tr(
              namedArgs: {
                'date': DateFormat(
                  'EEEE,d MMMM',
                  context.locale.languageCode,
                ).format(selectedDate),
              },
            ),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
        Expanded(
          child: ListView.separated(
            itemCount: appointments.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final appointment = appointments[index];
              return AppointmentItemWidget(
                appointment: appointment,
                onEdit: onEdit,
                onDelete: onDelete,
                onTap: onTap,
              );
            },
          ),
        ),
      ],
    );
  }
}
