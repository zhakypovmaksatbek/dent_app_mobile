import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/models/appointment/appointment_model.dart';
import 'package:dent_app_mobile/presentation/widgets/text/app_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class DeleteAppointmentDialog extends StatelessWidget {
  final AppointmentModel appointment;
  final VoidCallback onConfirm;

  const DeleteAppointmentDialog({
    super.key,
    required this.appointment,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: AppText(
        title: LocaleKeys.appointment_delete_appointment.tr(),
        textType: TextType.header,
      ),
      content: AppText(
        title: LocaleKeys.appointment_delete_appointment_content.tr(
          namedArgs: {
            'name':
                '${appointment.patientResponse?.firstName ?? ''} ${appointment.patientResponse?.lastName ?? ''}',
          },
        ),
        textType: TextType.body,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(LocaleKeys.buttons_cancel.tr()),
        ),
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.error,
          ),
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm();
          },
          child: Text(LocaleKeys.buttons_delete.tr()),
        ),
      ],
    );
  }
}
