import 'package:cherry_toast/cherry_toast.dart';
import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/models/appointment/calendar_appointment_model.dart';
import 'package:dent_app_mobile/presentation/pages/calendar/services/add_appointment_service.dart';
import 'package:dent_app_mobile/presentation/pages/calendar/widgets/calendar_view_widget.dart';
import 'package:dent_app_mobile/presentation/pages/calendar/widgets/edit_appointment_dialog_widget.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/personal/core/util/appointment_status.dart';
import 'package:dent_app_mobile/presentation/theme/colors/color_constants.dart';
import 'package:dent_app_mobile/presentation/widgets/text/app_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class AppointmentDialogService {
  // Show appointment details dialog
  void showAppointmentDetails(BuildContext context, Appointment appointment) {
    // Extract the CalendarAppointmentModel from resourceIds
    CalendarAppointmentModel? calendarAppointment;

    if (appointment.resourceIds != null &&
        appointment.resourceIds!.isNotEmpty) {
      // Safely cast from Object to CalendarAppointmentModel
      if (appointment.resourceIds!.first is CalendarAppointmentModel) {
        calendarAppointment =
            appointment.resourceIds!.first as CalendarAppointmentModel;
      }
    }

    if (calendarAppointment == null) {
      // If we couldn't get the appointment details, show an error

      CherryToast.error(
        title: Text(
          LocaleKeys.notifications_could_not_load_appointment_details.tr(),
        ),
      ).show(context);

      return;
    }

    // Non-null assertion is safe here because we've checked calendarAppointment is not null
    final appointmentModel = calendarAppointment;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      LocaleKeys.routes_appointment_detail.tr(),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          Navigator.pop(context);
                          showEditAppointmentDialog(context, appointmentModel);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          Navigator.pop(context);
                          showDeleteConfirmationDialog(
                            context,
                            appointmentModel,
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(),
              _buildDetailRow(
                LocaleKeys.forms_name.tr(),
                '${appointmentModel.patientFirsName ?? ''} ${appointmentModel.patientLastName ?? ''}',
              ),
              _buildDetailRow(
                LocaleKeys.roles_doctor.tr(),
                '${appointmentModel.doctorFirsName ?? ''} ${appointmentModel.doctorLastName ?? ''}',
              ),
              _buildDetailRow(
                LocaleKeys.appointment_time.tr(),
                appointmentModel.startTime != null &&
                        appointmentModel.endTime != null
                    ? '${DateFormat('HH:mm', context.locale.languageCode).format(DateTime.parse(appointmentModel.startTime!))} - ${DateFormat('HH:mm', context.locale.languageCode).format(DateTime.parse(appointmentModel.endTime!))}'
                    : 'Not specified',
              ),
              _buildDetailRow(
                LocaleKeys.appointment_status_label.tr(),
                AppointmentStatus.fromKey(
                  appointmentModel.appointmentStatus ?? '',
                ).label.tr(),
              ),
              _buildDetailRow(
                LocaleKeys.appointment_appointment_type_label.tr(),
                appointmentModel.recordType ?? 'N/A',
              ),
              _buildDetailRow(
                LocaleKeys.appointment_room.tr(),
                appointmentModel.room ?? 'N/A',
              ),
              if (appointmentModel.description != null &&
                  appointmentModel.description!.isNotEmpty)
                _buildDetailRow(
                  LocaleKeys.appointment_notes.tr(),
                  appointmentModel.description!,
                ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                spacing: 12,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Add call functionality
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.phone),
                      label: AppText(
                        title: LocaleKeys.buttons_call_patient.tr(),
                        textType: TextType.description,
                        fontWeight: FontWeight.bold,
                        color: ColorConstants.white,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 12,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 12,
                        ),
                        backgroundColor: ColorConstants.black,
                      ),
                      icon: const Icon(Icons.close),
                      label: AppText(
                        title: LocaleKeys.buttons_close.tr(),
                        textType: TextType.description,
                        fontWeight: FontWeight.bold,
                        color: ColorConstants.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // Add appointment dialog - now using the extracted widget
  static void showAddAppointmentDialog(
    BuildContext context, {
    required DateTime initialDate,
  }) {
    AddAppointmentService.showAddAppointmentDialog(
      context,
      initialDate: initialDate,
    );
  }

  // Edit appointment dialog
  void showEditAppointmentDialog(
    BuildContext context,
    CalendarAppointmentModel appointment,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Material(
          child: EditAppointmentDialogWidget(appointment: appointment),
        );
      },
    );
  }

  // Delete confirmation dialog
  Future<bool> showDeleteConfirmationDialog(
    BuildContext context,
    CalendarAppointmentModel appointment,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(LocaleKeys.appointment_delete_appointment.tr()),
          content: Text(LocaleKeys.appointment_delete_appointment_content.tr()),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(LocaleKeys.buttons_cancel.tr()),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
                if (appointment.appointmentId != null) {
                  // context.read<AppointmentActionCubit>().deleteAppointment(
                  //   appointment.appointmentId!,
                  // );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Could not delete appointment (missing ID)',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text(LocaleKeys.buttons_delete.tr()),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  // Helper method to build a detail row in the appointment details bottom sheet
  static Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
