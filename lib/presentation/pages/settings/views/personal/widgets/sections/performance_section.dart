import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/personal/core/bloc/personal_patient/personal_patient_cubit.dart';
import 'package:dent_app_mobile/presentation/widgets/card/custom_card_decoration.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PerformanceSection extends StatefulWidget {
  const PerformanceSection({
    super.key,
    required this.userId,
    required this.totalWorkingHours,
  });

  final int userId;
  final ValueNotifier<double> totalWorkingHours;

  @override
  State<PerformanceSection> createState() => _PerformanceSectionState();
}

class _PerformanceSectionState extends State<PerformanceSection> {
  final ValueNotifier<int> _patientsCount = ValueNotifier(0);

  @override
  void dispose() {
    _patientsCount.dispose();
    super.dispose();
  }

  String _formatWorkingHours(double hours) {
    final wholeHours = hours.floor();
    final minutes = ((hours - wholeHours) * 60).round();

    if (minutes > 0) {
      return '$wholeHours h $minutes m';
    } else {
      return '$wholeHours h';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<PersonalPatientCubit, PersonalPatientState>(
      listener: (context, state) {
        if (state is PersonalPatientLoaded) {
          _patientsCount.value = state.visits.totalElements ?? 0;
        }
      },
      child: CustomCardDecoration(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.indigo.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.insert_chart_outlined,
                      color: Colors.indigo,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    LocaleKeys.general_staff_statistics.tr(),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ValueListenableBuilder<int>(
                      valueListenable: _patientsCount,
                      builder: (context, value, child) {
                        return _buildPerformanceItem(
                          context: context,
                          value: value.toString(),
                          label: LocaleKeys.general_quantity_of_visits.tr(),
                          icon: Icons.people_outline,
                          color: Colors.blue,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildPerformanceItem(
                      context: context,
                      value: '57',
                      label: LocaleKeys.general_quantity_of_services.tr(),
                      icon: Icons.medical_services_outlined,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildPerformanceItem(
                      context: context,
                      value: '98.5%',
                      label: 'Satisfaction Rate',
                      icon: Icons.thumb_up_outlined,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ValueListenableBuilder<double>(
                      valueListenable: widget.totalWorkingHours,
                      builder: (context, hours, child) {
                        return _buildPerformanceItem(
                          context: context,
                          value: _formatWorkingHours(hours),
                          label: LocaleKeys.general_hours_worked.tr(),
                          icon: Icons.access_time_outlined,
                          color: Colors.purple,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPerformanceItem({
    required BuildContext context,
    required String value,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Tooltip(
      message: '$label: $value',
      showDuration: const Duration(seconds: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.3),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      textStyle: TextStyle(color: theme.colorScheme.onSurface, fontSize: 14),
      preferBelow: false,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
