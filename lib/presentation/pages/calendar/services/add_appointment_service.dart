import 'package:dent_app_mobile/presentation/pages/calendar/widgets/add_appointment_dialog_widget.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class AddAppointmentService {
  /// Shows the add appointment dialog using the extracted widget
  static void showAddAppointmentDialog(
    BuildContext context, {
    required DateTime initialDate,
  }) {
    showCupertinoModalBottomSheet(
      context: context,

      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      useRootNavigator: true,

      builder: (context) {
        return Material(
          child: AddAppointmentDialogWidget(initialDate: initialDate),
        );
      },
    );
  }
}
