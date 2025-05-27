import 'package:auto_route/annotations.dart';
import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/models/users/user_detail_model.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/personal/core/bloc/personal_detail/personal_detail_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/personal/core/bloc/personal_patient/personal_patient_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/personal/core/bloc/personal_specialty/personal_specialty_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/personal/widgets/sections/contact_info_section.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/personal/widgets/sections/payroll_info_section.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/personal/widgets/sections/performance_section.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/personal/widgets/sections/personal_info_section.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/personal/widgets/sections/profile_header_section.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/personal/widgets/sections/quick_stats_section.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/personal/widgets/sections/recent_patients_section.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/personal/widgets/sections/specialties_section.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/personal/widgets/sections/working_hours_section.dart';
import 'package:dent_app_mobile/presentation/widgets/loading/loading_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage(name: 'personalDetailRoute')
class PersonalDetailPage extends StatefulWidget {
  const PersonalDetailPage({super.key, required this.userId});
  final int userId;

  @override
  State<PersonalDetailPage> createState() => _PersonalDetailPageState();
}

class _PersonalDetailPageState extends State<PersonalDetailPage> {
  late final PersonalDetailCubit _personalDetailCubit;
  late final PersonalPatientCubit _personalPatientCubit;
  late final PersonalSpecialtyCubit _personalSpecialtyCubit;
  final ValueNotifier<double> totalWorkingHours = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    _personalDetailCubit = PersonalDetailCubit();
    _personalPatientCubit = PersonalPatientCubit();
    _personalSpecialtyCubit = PersonalSpecialtyCubit();
    _loadUserData();
  }

  void _loadUserData() async {
    await _personalDetailCubit.getUserDetail(widget.userId);
    await _personalPatientCubit.getVisits(userId: widget.userId, page: 1);
    await _personalSpecialtyCubit.getSpecialties(userId: widget.userId);
  }

  @override
  void dispose() {
    _personalDetailCubit.close();
    _personalPatientCubit.close();
    _personalSpecialtyCubit.close();
    totalWorkingHours.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.routes_personal_detail.tr()),
        elevation: 0,
      ),
      body: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => _personalDetailCubit),
          BlocProvider(create: (context) => _personalPatientCubit),
          BlocProvider(create: (context) => _personalSpecialtyCubit),
        ],
        child: BlocBuilder<PersonalDetailCubit, PersonalDetailState>(
          builder: (context, state) {
            if (state is PersonalDetailLoading) {
              return const Center(child: LoadingWidget());
            } else if (state is PersonalDetailLoaded) {
              return _buildUserProfileView(state.user);
            } else if (state is PersonalDetailError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      state.message,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadUserData,
                      child: Text(LocaleKeys.buttons_refresh.tr()),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildUserProfileView(UserDetailModel user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 24,
        children: [
          ProfileHeaderSection(user: user),
          QuickStatsSection(userId: widget.userId),
          SpecialtiesSection(userId: user.id ?? 0),
          RecentPatientsSection(userId: widget.userId),
          WorkingHoursSection(
            userId: widget.userId,
            onTotalHoursChanged: (hours) {
              totalWorkingHours.value = hours;
            },
          ),
          PersonalInfoSection(user: user),
          ContactInfoSection(user: user),
          if (user.payrollCalculationsResponse != null)
            PayrollInfoSection(payroll: user.payrollCalculationsResponse!),
          PerformanceSection(
            userId: widget.userId,
            totalWorkingHours: totalWorkingHours,
          ),
          const SizedBox(height: 34),
        ],
      ),
    );
  }
}
