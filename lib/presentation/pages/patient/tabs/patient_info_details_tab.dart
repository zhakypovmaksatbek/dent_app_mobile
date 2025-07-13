import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/models/appointment/appointment_detail_model.dart';
import 'package:dent_app_mobile/models/patient/patient_detail_model.dart';
import 'package:dent_app_mobile/models/patient/visit_model.dart';
import 'package:dent_app_mobile/presentation/pages/patient/content/patient_appointments_content.dart';
import 'package:dent_app_mobile/presentation/pages/patient/widgets/personal_info_card.dart';
import 'package:dent_app_mobile/presentation/widgets/card/custom_card_decoration.dart';
import 'package:dent_app_mobile/presentation/widgets/text/app_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class PatientInfoDetailsTab extends StatefulWidget {
  final AppointmentDetailModel appointment;
  final int patientId;
  final Function(BuildContext, AppointmentDetailModel) onShowCommentDialog;
  final PatientDetailModel patientDetail;
  const PatientInfoDetailsTab({
    super.key,
    required this.appointment,
    required this.patientId,
    required this.onShowCommentDialog,
    required this.patientDetail,
    required this.visits,
  });

  final List<VisitModel> visits;

  @override
  State<PatientInfoDetailsTab> createState() => _PatientInfoDetailsTabState();
}

class _PatientInfoDetailsTabState extends State<PatientInfoDetailsTab>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    final appointmentId = widget.appointment.userResponse?.id;
    final canUpdate = appointmentId != null;
    super.build(context);
    return SingleChildScrollView(
      child: Column(
        spacing: 16,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PersonalInfoCard(patientDetail: widget.patientDetail),

          CustomCardDecoration(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppText(
                        title: LocaleKeys.appointment_medical_details.tr(),
                        textType: TextType.header,
                        fontWeight: FontWeight.bold,
                      ),

                      if (canUpdate)
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          onPressed:
                              () => widget.onShowCommentDialog(
                                context,
                                widget.appointment,
                              ),
                          tooltip:
                              LocaleKeys.appointment_edit_medical_details.tr(),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  if (widget.appointment.complaints != null &&
                      widget.appointment.complaints!.isNotEmpty)
                    _buildInfoRow(
                      context,
                      label: LocaleKeys.appointment_complaints.tr(),
                      value: widget.appointment.complaints!,
                      icon: Icons.warning_amber_rounded,
                      iconColor: Colors.orange,
                    ),

                  if (widget.appointment.appDescription != null &&
                      widget.appointment.appDescription!.isNotEmpty)
                    _buildInfoRow(
                      context,
                      label: LocaleKeys.appointment_diagnosis.tr(),
                      value: widget.appointment.appDescription!,
                      icon: Icons.medical_information,
                      iconColor: Colors.purple,
                    ),

                  if (widget.appointment.oldDiseases != null &&
                      widget.appointment.oldDiseases!.isNotEmpty)
                    _buildInfoRow(
                      context,
                      label: LocaleKeys.appointment_medical_history.tr(),
                      value: widget.appointment.oldDiseases!,
                      icon: Icons.history,
                      iconColor: Colors.brown,
                    ),

                  if (widget.appointment.xRayDescription != null &&
                      widget.appointment.xRayDescription!.isNotEmpty)
                    _buildInfoRow(
                      context,
                      label: LocaleKeys.appointment_x_ray_description.tr(),
                      value: widget.appointment.xRayDescription!,
                      icon: Icons.image,
                      iconColor: Colors.teal,
                    ),
                ],
              ),
            ),
          ),
          PatientAppointments(patientId: widget.patientId),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(value, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
