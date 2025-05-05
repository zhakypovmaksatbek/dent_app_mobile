import 'package:dent_app_mobile/models/appointment/calendar_appointment_model.dart';
import 'package:dent_app_mobile/presentation/pages/calendar/widgets/calendar_view_widget.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/personal/core/util/appointment_status.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppointmentDataSourceUtil {
  // Convert backend appointment model to calendar appointments
  static AppointmentDataSource getAppointmentDataSource(
    List<CalendarAppointmentModel> appointments,
  ) {
    List<Appointment> calendarAppointments = [];
    if (kDebugMode) {
      print('Processing ${appointments.length} appointments for calendar');
    }

    for (var appointment in appointments) {
      if (appointment.startTime != null && appointment.endTime != null) {
        try {
          DateTime startTime = DateTime.parse(appointment.startTime!);
          DateTime endTime = DateTime.parse(appointment.endTime!);

          // Get patient name, handling null values
          String patientName = 'Patient';
          if (appointment.patientFirsName != null ||
              appointment.patientLastName != null) {
            patientName =
                '${appointment.patientFirsName ?? ''} ${appointment.patientLastName ?? ''}'
                    .trim();
          }

          // Get record type for display
          String description = appointment.recordType ?? 'Consultation';
          if (appointment.description != null &&
              appointment.description!.isNotEmpty) {
            description = appointment.description!;
          }

          // Get color based on appointment status
          Color appointmentColor =
              AppointmentStatus.fromKey(
                appointment.appointmentStatus ?? '',
              ).color;
          if (kDebugMode) {
            print(
              'Adding appointment: $patientName, Start: $startTime, End: $endTime',
            );
          }

          // Explicitly cast each appointment as Object when adding to the resourceIds list
          List<Object> resources = [appointment as Object];

          calendarAppointments.add(
            Appointment(
              startTime: startTime,
              endTime: endTime,
              subject: patientName,
              notes: description,
              color: appointmentColor,
              resourceIds: resources,
            ),
          );
        } catch (e) {
          if (kDebugMode) {
            print('Error processing appointment: $e');
          }
        }
      }
    }

    if (kDebugMode) {
      print('Created ${calendarAppointments.length} calendar appointments');
    }
    return AppointmentDataSource(calendarAppointments);
  }

  // Helper function to determine appointment color based on status
}
