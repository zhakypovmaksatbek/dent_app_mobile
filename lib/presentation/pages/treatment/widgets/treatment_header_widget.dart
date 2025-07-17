import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/models/appointment/calendar_appointment_model.dart';
import 'package:dent_app_mobile/presentation/localization/app_localization.dart';
import 'package:dent_app_mobile/presentation/widgets/card/custom_card_decoration.dart';
import 'package:dent_app_mobile/presentation/widgets/text/app_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class TreatmentHeaderWidget extends StatelessWidget {
  const TreatmentHeaderWidget({super.key, required this.calendarAppointment});

  final CalendarAppointmentModel? calendarAppointment;

  @override
  Widget build(BuildContext context) {
    final startTime = calendarAppointment?.startTime;
    final endTime = calendarAppointment?.endTime;

    final locale = AppLocalization.getCurrentLanguageCode(context);
    final dateFormat = DateFormat('dd MMMM yyyy', locale);
    final timeFormat = DateFormat('HH:mm');

    // Parse the appointment times
    DateTime? appointmentStartTime;
    DateTime? appointmentEndTime;

    try {
      if (startTime != null) {
        appointmentStartTime = DateTime.parse(startTime);
      }
      if (endTime != null) {
        appointmentEndTime = DateTime.parse(endTime);
      }
    } catch (e) {
      debugPrint("Error parsing appointment times: $e");
    }

    return CustomCardDecoration(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              title:
                  '${calendarAppointment?.patientFirsName ?? ''} ${calendarAppointment?.patientLastName ?? ''}',
              textType: TextType.body,
              maxLines: 2,
              fontWeight: FontWeight.bold,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  appointmentStartTime != null
                      ? dateFormat.format(appointmentStartTime)
                      : LocaleKeys.diagnosis_date_not_available.tr(),
                  style: const TextStyle(color: Colors.black87),
                ),
                const SizedBox(width: 16),
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  appointmentStartTime != null && appointmentEndTime != null
                      ? '${timeFormat.format(appointmentStartTime)} - ${timeFormat.format(appointmentEndTime)}'
                      : appointmentStartTime != null
                      ? timeFormat.format(appointmentStartTime)
                      : LocaleKeys.diagnosis_time_not_available.tr(),
                  style: const TextStyle(color: Colors.black87),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
