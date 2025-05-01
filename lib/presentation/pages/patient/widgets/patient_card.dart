import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/main.dart';
import 'package:dent_app_mobile/models/patient/patient_data_model.dart';
import 'package:dent_app_mobile/presentation/pages/patient/core/bloc/patient_bloc.dart';
import 'package:dent_app_mobile/presentation/pages/patient/view/create_patient.dart';
import 'package:dent_app_mobile/presentation/theme/colors/color_constants.dart';
import 'package:dent_app_mobile/presentation/widgets/card/custom_card_decoration.dart';
import 'package:dent_app_mobile/presentation/widgets/text/app_text.dart';
import 'package:dent_app_mobile/router/app_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class PatientCard extends StatelessWidget {
  final PatientModel patient;

  const PatientCard({super.key, required this.patient});

  void _showEditPatientDialog(PatientModel patient, BuildContext context) {
    // TODO: Implement edit patient dialog
    showCupertinoModalBottomSheet(
      context: context,
      builder: (context) => CreatePatientPage(isEdit: true, patient: patient),
    );
  }

  void _showDeleteConfirmationDialog(
    PatientModel patient,
    BuildContext context,
  ) {
    if (patient.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: AppText(
            title: " LocaleKeys.patients_invalid_id.tr()",
            textType: TextType.body,
          ),
        ),
      );
      return;
    }

    showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: AppText(
              title: LocaleKeys.buttons_delete.tr(),
              textType: TextType.title,
            ),
            content: AppText(
              title: LocaleKeys.notifications_delete_confirmation_patient.tr(
                namedArgs: {'name': patient.fullName ?? '-'},
              ),
              textType: TextType.body,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: AppText(
                  title: LocaleKeys.buttons_cancel.tr(),
                  textType: TextType.body,
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: AppText(
                  title: LocaleKeys.buttons_delete.tr(),
                  textType: TextType.body,
                  color: Colors.red,
                ),
              ),
            ],
          ),
    ).then((result) {
      if (result == true && context.mounted) {
        context.read<PatientBloc>().add(DeletePatient(patient.id!));
      }
    });
  }

  String dateFormat(String date) {
    final dateTime = DateTime.parse(date);
    return DateFormat('dd.MM.yyyy').format(dateTime);
  }

  static final AppRouter router = getIt<AppRouter>();
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => router.push(AppointmentDetailRoute(id: patient.id ?? 0)),
      child: CustomCardDecoration(
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: ColorConstants.primary,
              child: Text(
                patient.fullName?[0] ?? '?',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            visualDensity: VisualDensity.compact,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
            collapsedShape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            childrenPadding: EdgeInsets.zero,
            title: AppText(
              title: patient.fullName ?? 'Unknown',
              textType: TextType.subtitle,
            ),

            tilePadding: EdgeInsets.only(left: 8),
            subtitle: AppText(
              title: patient.phoneNumber ?? 'No phone',
              textType: TextType.body,
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    _showEditPatientDialog(patient, context);
                    break;
                  case 'delete':
                    _showDeleteConfirmationDialog(patient, context);
                    break;
                }
              },
              itemBuilder:
                  (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          const Icon(Icons.edit, size: 20),
                          const SizedBox(width: 8),
                          AppText(
                            title: LocaleKeys.buttons_edit.tr(),
                            textType: TextType.body,
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          const Icon(Icons.delete, size: 20, color: Colors.red),
                          const SizedBox(width: 8),
                          AppText(
                            title: LocaleKeys.buttons_delete.tr(),
                            textType: TextType.body,
                            color: Colors.red,
                          ),
                        ],
                      ),
                    ),
                  ],
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow(
                      LocaleKeys.forms_email.tr(),
                      patient.email ?? 'N/A',
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      LocaleKeys.forms_birthday.tr(),
                      dateFormat(patient.birthDate ?? ''),
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      LocaleKeys.forms_debt.tr(),
                      patient.debt?.toString() ?? 'N/A',
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      LocaleKeys.forms_deposit.tr(),
                      patient.deposit?.toString() ?? 'N/A',
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      LocaleKeys.forms_payment.tr(),
                      patient.payment?.toString() ?? 'N/A',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: AppText(title: "$label:", textType: TextType.subtitle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: AppText(
            title: value,
            textType: TextType.body,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
