import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/personal/core/util/appointment_status.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class SelectionAppointmentStatus extends StatelessWidget {
  const SelectionAppointmentStatus({
    super.key,
    required this.enabled,
    required this.onAppointmentStatusSelected,
  });
  final bool enabled;
  final Function(AppointmentStatus?) onAppointmentStatusSelected;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<AppointmentStatus>(
          decoration: InputDecoration(
            labelText: LocaleKeys.appointment_status_label.tr(),
            prefixIcon: const Icon(Icons.task_alt),
            border: const OutlineInputBorder(),
            enabled: enabled,
          ),
          initialValue: AppointmentStatus.notConfirmed,
          items:
              AppointmentStatus.values
                  .map(
                    (e) =>
                        DropdownMenuItem(value: e, child: Text(e.label.tr())),
                  )
                  .toList(),
          onChanged: onAppointmentStatusSelected,
        ),
      ],
    );
  }
}
