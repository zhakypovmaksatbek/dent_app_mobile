import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/presentation/pages/calendar/bloc/calendar_appointments/calendar_appointments_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/calendar/widgets/animated_digit.dart';
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
      final DateTime now = DateTime.now();

      // Saat bilgisini sıfırlayarak "Bugün 00:00:00"ı elde ediyoruz
      final DateTime today = DateTime(now.year, now.month, now.day);
      final DateTime tomorrow = today.add(const Duration(days: 1));

      // Haftanın başı: Pazartesi 00:00:00
      // (now.weekday 1=Pazartesi, 7=Pazar)
      final DateTime weekStart = today.subtract(
        Duration(days: now.weekday - 1),
      );

      // Haftanın sonu: Gelecek Pazartesi 00:00:00 (Bu sayede Pazar 23:59'a kadar olanları kapsarız)
      final DateTime weekEnd = weekStart.add(const Duration(days: 7));

      for (var appointment
          in (state as CalendarAppointmentsLoaded).appointments) {
        if (appointment.startTime != null) {
          final appointmentDate = DateTime.parse(appointment.startTime!);

          // Bugün kontrolü
          if (appointmentDate.year == today.year &&
              appointmentDate.month == today.month &&
              appointmentDate.day == today.day) {
            todayCount++;
          }

          // Yarın kontrolü
          if (appointmentDate.year == tomorrow.year &&
              appointmentDate.month == tomorrow.month &&
              appointmentDate.day == tomorrow.day) {
            tomorrowCount++;
          }

          // Bu hafta kontrolü (Pazartesi 00:00 dahil, Gelecek Pazartesi 00:00 hariç)
          // isAtSameMomentAs: Tam başlangıç anını kapsar (Pazartesi 00:00)
          // isAfter: Başlangıçtan sonrasını kapsar
          // isBefore: Bitişten öncesini kapsar
          if ((appointmentDate.isAtSameMomentAs(weekStart) ||
                  appointmentDate.isAfter(weekStart)) &&
              appointmentDate.isBefore(weekEnd)) {
            weekCount++;
          }
        }
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Row(
        spacing: 12,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildInfoCard(
            context,
            LocaleKeys.routes_appointments.tr(),
            LocaleKeys.date_range_today.tr(),
            todayCount,
          ),
          _buildInfoCard(
            context,
            LocaleKeys.routes_appointments.tr(),
            LocaleKeys.appointment_tomorrow.tr(),
            tomorrowCount,
          ),
          _buildInfoCard(
            context,
            LocaleKeys.routes_appointments.tr(),
            LocaleKeys.date_range_this_week.tr(),
            weekCount,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    String title,
    String subtitle,
    int count,
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
              AnimatedDigit(
                digit: count,
                textStyle: TextStyle(
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
