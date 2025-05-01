import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/models/appointment/appointment_model.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/personal/core/util/appointment_status.dart';
import 'package:dent_app_mobile/presentation/widgets/text/app_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class AppointmentCommentDialog extends StatefulWidget {
  final AppointmentModel appointment;
  final Function(
    String comment,
    AppointmentStatus status,
    String? complaints,
    String? history,
    String? xRayDescription,
  )
  onSave;

  const AppointmentCommentDialog({
    super.key,
    required this.appointment,
    required this.onSave,
  });

  @override
  State<AppointmentCommentDialog> createState() =>
      _AppointmentCommentDialogState();
}

class _AppointmentCommentDialogState extends State<AppointmentCommentDialog> {
  late final TextEditingController textController;
  late final TextEditingController complaintsController;
  late final TextEditingController historyController;
  late final TextEditingController xrayController;
  late AppointmentStatus status;

  @override
  void initState() {
    super.initState();
    textController = TextEditingController(
      text: widget.appointment.appDescription,
    );
    complaintsController = TextEditingController(
      text: widget.appointment.complaints,
    );
    historyController = TextEditingController(
      text: widget.appointment.oldDiseases,
    );
    xrayController = TextEditingController(
      text: widget.appointment.xRayDescription,
    );
    status = AppointmentStatus.fromKey(
      widget.appointment.appointmentStatus ?? '',
    );
  }

  @override
  void dispose() {
    textController.dispose();
    complaintsController.dispose();
    historyController.dispose();
    xrayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 5,
      backgroundColor: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header section with colored status bar
          Container(
            decoration: BoxDecoration(
              color: status.color,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Row(
              children: [
                Icon(Icons.medical_information, color: Colors.white, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: AppText(
                    title: LocaleKeys.appointment_update_medical_details.tr(),
                    textType: TextType.header,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ),

          // Content section with scrolling
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status dropdown
                  _buildFormField(
                    LocaleKeys.appointment_status_label.tr(),
                    Icons.flag_rounded,
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                        color: Colors.grey.shade50,
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<AppointmentStatus>(
                          value: status,
                          isExpanded: true,
                          borderRadius: BorderRadius.circular(12),
                          icon: const Icon(Icons.arrow_drop_down),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          items:
                              AppointmentStatus.values.map((status) {
                                final color = status.color;
                                return DropdownMenuItem<AppointmentStatus>(
                                  value: status,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: color,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Flexible(
                                        child: AppText(
                                          title: status.label.tr(),
                                          textType: TextType.body,
                                          color: color,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                          onChanged: (newValue) {
                            if (newValue != null) {
                              setState(() {
                                status = newValue;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ),

                  // Diagnosis field
                  _buildTextField(
                    label: LocaleKeys.appointment_diagnosis.tr(),
                    icon: Icons.medical_information,
                    controller: textController,
                    hintText: LocaleKeys.appointment_enter_diagnosis.tr(),
                    maxLines: 3,
                    focusedBorderColor: Theme.of(context).primaryColor,
                  ),

                  // Complaints field
                  _buildTextField(
                    label: LocaleKeys.appointment_complaints.tr(),
                    icon: Icons.warning_amber_rounded,
                    controller: complaintsController,
                    hintText: LocaleKeys.appointment_enter_complaints.tr(),
                    maxLines: 2,
                    focusedBorderColor: Colors.orange,
                  ),

                  // Medical History field
                  _buildTextField(
                    label: LocaleKeys.appointment_medical_history.tr(),
                    icon: Icons.history,
                    controller: historyController,
                    hintText: LocaleKeys.appointment_enter_medical_history.tr(),
                    maxLines: 2,
                    focusedBorderColor: Colors.brown,
                  ),

                  // X-Ray Description field
                  _buildTextField(
                    label: LocaleKeys.appointment_x_ray_description.tr(),
                    icon: Icons.image,
                    controller: xrayController,
                    hintText:
                        LocaleKeys.appointment_enter_x_ray_description.tr(),
                    maxLines: 2,
                    focusedBorderColor: Colors.teal,
                  ),
                ],
              ),
            ),
          ),

          // Action buttons section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey[700],
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  child: Text(LocaleKeys.buttons_cancel.tr()),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    widget.onSave(
                      textController.text,
                      status,
                      complaintsController.text,
                      historyController.text,
                      xrayController.text,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: status.color,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  child: Text(LocaleKeys.buttons_save.tr()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method for creating text field with common decoration
  Widget _buildTextField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
    Color? focusedBorderColor,
  }) {
    return _buildFormField(
      label,
      icon,
      TextField(
        controller: controller,
        decoration: _getInputDecoration(
          hintText: hintText,
          focusedBorderColor: focusedBorderColor,
        ),
        maxLines: maxLines,
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  // Common input decoration builder
  InputDecoration _getInputDecoration({
    required String hintText,
    Color? focusedBorderColor,
  }) {
    return InputDecoration(
      hintText: hintText,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: focusedBorderColor ?? Theme.of(context).primaryColor,
        ),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding: const EdgeInsets.all(16),
    );
  }

  // Helper method for form fields in dialog
  Widget _buildFormField(String label, IconData icon, Widget field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8, top: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: Colors.grey[700]),
              const SizedBox(width: 8),
              Flexible(
                child: AppText(
                  title: label,
                  textType: TextType.body,
                  color: Colors.grey[800],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        field,
      ],
    );
  }
}
