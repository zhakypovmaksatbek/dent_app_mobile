import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/models/appointment/calendar_appointment_model.dart';
import 'package:dent_app_mobile/presentation/widgets/card/custom_card_decoration.dart';
import 'package:dent_app_mobile/presentation/widgets/text/app_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class DoctorInfoWidget extends StatelessWidget {
  const DoctorInfoWidget({super.key, required this.calendarAppointment});

  final CalendarAppointmentModel? calendarAppointment;

  @override
  Widget build(BuildContext context) {
    final doctorName =
        '${calendarAppointment?.doctorFirsName ?? ''} '
        '${calendarAppointment?.doctorLastName ?? ''}';

    return CustomCardDecoration(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          spacing: 12.0,
          children: [
            Row(
              children: [
                Icon(
                  Icons.person,
                  size: 24,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    LocaleKeys.report_treatment_doctor.tr(),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            AppText(
              title: doctorName.trim().isEmpty ? 'Not assigned' : doctorName,
              textType: TextType.body,
            ),
          ],
        ),
      ),
    );
  }
}
