import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/personal/core/util/appointment_status.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class StatusSectionWidget extends StatelessWidget {
  const StatusSectionWidget({
    super.key,
    required this.appointmentStatus,
    required this.onChanged,
  });

  final AppointmentStatus? appointmentStatus;
  final ValueChanged<AppointmentStatus?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 12.0,
      children: [
        Text(
          LocaleKeys.appointment_status_label.tr(),
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        DropdownButtonFormField<AppointmentStatus>(
          decoration: InputDecoration(
            labelText: LocaleKeys.appointment_appointment_type_label.tr(),
            prefixIcon: const Icon(Icons.adjust_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          initialValue: appointmentStatus,
          items:
              AppointmentStatus.values
                  .map(
                    (e) =>
                        DropdownMenuItem(value: e, child: Text(e.label.tr())),
                  )
                  .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
