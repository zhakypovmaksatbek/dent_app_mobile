import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/presentation/pages/calendar/bloc/calendar_appointments/calendar_appointments_cubit.dart';
import 'package:dent_app_mobile/presentation/widgets/card/custom_card_decoration.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class AppointmentSummaryWidget extends StatelessWidget {
  final CalendarAppointmentsState state;

  const AppointmentSummaryWidget({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    int todayCount = 0;
    int tomorrowCount = 0;
    int weekCount = 0;

    if (state is CalendarAppointmentsLoaded) {
      final DateTime today = DateTime.now();
      final DateTime tomorrow = today.add(const Duration(days: 1));
      final DateTime weekStart = today.subtract(
        Duration(days: today.weekday - 1),
      );
      final DateTime weekEnd = weekStart.add(const Duration(days: 7));

      for (var appointment
          in (state as CalendarAppointmentsLoaded).appointments) {
        if (appointment.startTime != null) {
          final appointmentDate = DateTime.parse(appointment.startTime!);

          if (appointmentDate.year == today.year &&
              appointmentDate.month == today.month &&
              appointmentDate.day == today.day) {
            todayCount++;
          }

          if (appointmentDate.year == tomorrow.year &&
              appointmentDate.month == tomorrow.month &&
              appointmentDate.day == tomorrow.day) {
            tomorrowCount++;
          }

          if (appointmentDate.isAfter(weekStart) &&
              appointmentDate.isBefore(weekEnd)) {
            weekCount++;
          }
        }
      }
    }

    return Row(
      spacing: 12,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildInfoCard(
          context,
          LocaleKeys.routes_appointments.tr(),
          LocaleKeys.date_range_today.tr(),
          todayCount.toString(),
        ),
        _buildInfoCard(
          context,
          LocaleKeys.routes_appointments.tr(),
          LocaleKeys.appointment_tomorrow.tr(),
          tomorrowCount.toString(),
        ),
        _buildInfoCard(
          context,
          LocaleKeys.routes_appointments.tr(),
          LocaleKeys.date_range_this_week.tr(),
          weekCount.toString(),
        ),
      ],
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    String title,
    String subtitle,
    String count,
  ) {
    return Expanded(
      child: CustomCardDecoration(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                count,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
