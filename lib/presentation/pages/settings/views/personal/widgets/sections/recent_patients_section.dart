import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/main.dart';
import 'package:dent_app_mobile/models/patient/visit_model.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/personal/core/bloc/personal_patient/personal_patient_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/personal/widgets/personal_patient_item.dart';
import 'package:dent_app_mobile/presentation/widgets/card/custom_card_decoration.dart';
import 'package:dent_app_mobile/router/app_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RecentPatientsSection extends StatelessWidget {
  const RecentPatientsSection({super.key, required this.userId});

  final int userId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PersonalPatientCubit, PersonalPatientState>(
      builder: (context, state) {
        if (state is PersonalPatientLoaded) {
          if (state.visits.content?.isNotEmpty == true) {
            return _buildRecentPatientsSection(
              context,
              state.visits.content ?? [],
              router,
            );
          }
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildRecentPatientsSection(
    BuildContext context,
    List<VisitModel> visits,
    AppRouter router,
  ) {
    final theme = Theme.of(context);

    return CustomCardDecoration(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.people_outline,
                        color: Colors.blue,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      LocaleKeys.routes_visits.tr(),
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (visits.length > 5)
                  TextButton.icon(
                    onPressed: () {
                      router.push(PersonalPatientsRoute(userId: userId));
                    },
                    icon: const Icon(Icons.arrow_forward, size: 16),
                    label: Text(LocaleKeys.buttons_view_all.tr()),
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.primary,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (visits.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No recent patients',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Column(
                children: visits
                    .take(5)
                    .map(
                      (patient) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: PersonalPatientItem(patient: patient),
                      ),
                    )
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }
}
