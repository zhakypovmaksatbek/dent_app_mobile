import 'package:dent_app_mobile/main.dart';
import 'package:dent_app_mobile/models/patient/visit_model.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/personal/core/util/record_type.dart';
import 'package:dent_app_mobile/router/app_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class PersonalPatientItem extends StatelessWidget {
  const PersonalPatientItem({super.key, required this.patient});
  final VisitModel patient;
  static final AppRouter router = getIt<AppRouter>();
  @override
  Widget build(BuildContext context) {
    final namePart = patient.appointment?.split(',').elementAtOrNull(1)?.trim();
    final firstLetter = namePart?.isNotEmpty == true ? namePart![0] : '';
    final recordType =
        RecordType.fromString(patient.recordType ?? '').displayName.tr();
    final services =
        patient.appointmentServiceToPatientResponses
            ?.map((e) => e.name)
            .join(', ') ??
        '';

    return Tooltip(
      message: '${patient.appointment ?? ''}\n$services\n$recordType',
      showDuration: const Duration(seconds: 3),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.3),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      textStyle: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
        fontSize: 14,
      ),
      child: InkWell(
        onTap: () {
          router.push(AppointmentDetailRoute(id: patient.appointmentId ?? 0));
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(
                backgroundColor: Colors.grey.shade200,
                child: Text(
                  firstLetter,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patient.appointment ?? '',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Text(
                      services,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                flex: 1,
                child: Text(
                  recordType,
                  textAlign: TextAlign.end,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
