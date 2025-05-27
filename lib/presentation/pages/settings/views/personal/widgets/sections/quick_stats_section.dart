import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/personal/core/bloc/personal_patient/personal_patient_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/personal/widgets/common/stat_card_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class QuickStatsSection extends StatefulWidget {
  const QuickStatsSection({super.key, required this.userId});

  final int userId;

  @override
  State<QuickStatsSection> createState() => _QuickStatsSectionState();
}

class _QuickStatsSectionState extends State<QuickStatsSection> {
  final ValueNotifier<int> _patientsCount = ValueNotifier(0);

  @override
  void dispose() {
    _patientsCount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PersonalPatientCubit, PersonalPatientState>(
      listener: (context, state) {
        if (state is PersonalPatientLoaded) {
          _patientsCount.value = state.visits.totalElements ?? 0;
        }
      },
      child: Row(
        children: [
          Expanded(
            child: ValueListenableBuilder<int>(
              valueListenable: _patientsCount,
              builder: (context, value, child) {
                return StatCardWidget(
                  icon: Icons.people,
                  value: value.toString(),
                  label: LocaleKeys.general_count_patients.tr(),
                  color: Colors.blue,
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: StatCardWidget(
              icon: Icons.calendar_today,
              value: '36',
              label: LocaleKeys.general_count_appointments.tr(),
              color: Colors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: StatCardWidget(
              icon: Icons.medical_services,
              value: '57',
              label: LocaleKeys.general_count_services.tr(),
              color: Colors.purple,
            ),
          ),
        ],
      ),
    );
  }
}
