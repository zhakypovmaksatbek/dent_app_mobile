import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/personal/core/util/record_type.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class AppointmentTypeSelection extends StatelessWidget {
  const AppointmentTypeSelection({
    super.key,
    this.initialValue,
    required this.enabled,
    required this.onRecordTypeSelected,
  });
  final RecordType? initialValue;
  final bool enabled;
  final Function(RecordType?) onRecordTypeSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<RecordType>(
          initialValue: initialValue,
          decoration: InputDecoration(
            labelText: LocaleKeys.appointment_appointment_type_label.tr(),
            hintText: LocaleKeys.appointment_appointment_type_label.tr(),
            prefixIcon: const Icon(Icons.category_outlined),
            border: const OutlineInputBorder(),
            enabled: enabled,
          ),

          items:
              RecordType.values
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(e.displayName.tr()),
                    ),
                  )
                  .toList(),
          onChanged: onRecordTypeSelected,
        ),
      ],
    );
  }
}
