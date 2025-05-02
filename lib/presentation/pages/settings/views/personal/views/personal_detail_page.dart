import 'package:auto_route/annotations.dart';
import 'package:dent_app_mobile/core/utils/format_utils.dart';
import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/main.dart';
import 'package:dent_app_mobile/models/patient/visit_model.dart';
import 'package:dent_app_mobile/models/users/personal_model.dart';
import 'package:dent_app_mobile/models/users/schedule_model.dart';
import 'package:dent_app_mobile/models/users/specialty_model.dart';
import 'package:dent_app_mobile/models/users/user_detail_model.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/personal/core/bloc/personal_detail/personal_detail_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/personal/core/bloc/personal_patient/personal_patient_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/personal/core/bloc/personal_specialty/personal_specialty_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/personal/core/bloc/personal_work_schedule/personal_work_schedule_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/personal/core/util/chart_constants.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/personal/core/util/gender.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/personal/core/util/week.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/personal/widgets/personal_patient_item.dart';
import 'package:dent_app_mobile/presentation/widgets/card/custom_card_decoration.dart';
import 'package:dent_app_mobile/presentation/widgets/loading/loading_widget.dart';
import 'package:dent_app_mobile/router/app_router.dart';
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

class _PersonalDetailPageState extends State<PersonalDetailPage>
    with SingleTickerProviderStateMixin {
  late final PersonalDetailCubit _personalDetailCubit;
  late final PersonalPatientCubit _personalPatientCubit;
  late final PersonalSpecialtyCubit _personalSpecialtyCubit;
  final ValueNotifier<int> quantityOfVisits = ValueNotifier(0);
  final ChartConstants chartConstants = ChartConstants();
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

  final AppRouter router = getIt<AppRouter>();
  @override
  void dispose() {
    _personalDetailCubit.close();
    _personalPatientCubit.close();
    _personalSpecialtyCubit.close();
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
          _buildProfileHeader(user),
          _buildQuickStatsSection(),

          _buildSpecialtiesSection(user.id ?? 0),
          BlocConsumer<PersonalPatientCubit, PersonalPatientState>(
            listener: (context, state) {
              if (state is PersonalPatientLoaded) {
                quantityOfVisits.value = state.visits.totalElements ?? 0;
              }
            },
            builder: (context, state) {
              if (state is PersonalPatientLoaded) {
                if (state.visits.content?.isNotEmpty == true) {
                  return _buildRecentPatientsSection(
                    state.visits.content ?? [],
                  );
                }
              }
              return const SizedBox.shrink();
            },
          ),
          _buildPersonalInfoSection(user),
          _buildContactInfoSection(user),
          if (user.payrollCalculationsResponse != null) ...[
            _buildPayrollInfoSection(user.payrollCalculationsResponse!),
          ],
          _buildWorkingHoursSection(),
          _buildPerformanceSection(),

          const SizedBox(height: 34),
        ],
      ),
    );
  }

  List<SpecialtyModel> userSpecialist = [];
  List<SpecialtyModel> anotherSpecialist = [];
  Widget _buildSpecialtiesSection(int userId) {
    return BlocConsumer<PersonalSpecialtyCubit, PersonalSpecialtyState>(
      listener: (context, state) {
        if (state is PersonalSpecialtyLoaded) {
          userSpecialist = state.userSpecialties;
          anotherSpecialist = state.specialties;
        }
      },
      builder: (context, state) {
        if (state is PersonalSpecialtyError) {
          return CustomCardDecoration(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    LocaleKeys.general_specialties.tr(),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Error loading specialties: ${state.message}",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      _personalSpecialtyCubit.getSpecialties(userId: userId);
                    },
                    child: Text(LocaleKeys.buttons_retry.tr()),
                  ),
                ],
              ),
            ),
          );
        } else {
          return CustomCardDecoration(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        LocaleKeys.general_specialties.tr(),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      if (_userCanEditSpecialties())
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            _showEditSpecialtiesDialog(
                              userId,
                              userSpecialist,
                              anotherSpecialist,
                            );
                          },
                          tooltip: LocaleKeys.general_edit_specialties.tr(),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (userSpecialist.isEmpty)
                    Text(
                      LocaleKeys.notifications_no_specialties_assigned.tr(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          userSpecialist.map((specialty) {
                            return _buildSpecialtyChip(userId, specialty);
                          }).toList(),
                    ),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildSpecialtyChip(int userId, SpecialtyModel specialty) {
    return Tooltip(
      message: specialty.name ?? '',
      showDuration: const Duration(seconds: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: .9),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: .3),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Chip(
        label: Text(specialty.name ?? ''),
        backgroundColor: Theme.of(
          context,
        ).colorScheme.primary.withValues(alpha: .1),
        deleteIcon:
            _userCanEditSpecialties()
                ? const Icon(Icons.close, size: 16)
                : null,
        onDeleted:
            _userCanEditSpecialties()
                ? () => _confirmDeleteSpecialty(userId, specialty)
                : null,
      ),
    );
  }

  bool _userCanEditSpecialties() {
    return true;
  }

  void _confirmDeleteSpecialty(int userId, SpecialtyModel specialty) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(LocaleKeys.alerts_delete_specialty.tr()),
            content: Text(
              LocaleKeys.notifications_delete_specialty_confirmation.tr(
                namedArgs: {'name': specialty.name ?? ''},
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(LocaleKeys.buttons_cancel.tr()),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _personalSpecialtyCubit.deleteSpecialty(
                    userId: userId,
                    specialtyId: specialty.id ?? 0,
                  );
                },
                child: Text(
                  LocaleKeys.buttons_delete.tr(),
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ],
          ),
    );
  }

  void _showEditSpecialtiesDialog(
    int userId,
    List<SpecialtyModel> userSpecialties,
    List<SpecialtyModel> anotherSpecialist,
  ) {
    final userSpecialtiesIds = userSpecialist.map((e) => e.id).toSet();
    final availableSpecialties =
        anotherSpecialist
            .where((specialty) => !userSpecialtiesIds.contains(specialty.id))
            .toList();

    if (availableSpecialties.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            LocaleKeys.notifications_no_more_specialties_available.tr(),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        final selectedSpecialties = <SpecialtyModel>[];

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(LocaleKeys.forms_add_specialty.tr()),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children:
                      availableSpecialties.map((specialty) {
                        final isSelected = selectedSpecialties.contains(
                          specialty,
                        );
                        return CheckboxListTile(
                          title: Text(specialty.name ?? ''),
                          value: isSelected,
                          onChanged: (value) {
                            setState(() {
                              if (value == true) {
                                selectedSpecialties.add(specialty);
                              } else {
                                selectedSpecialties.remove(specialty);
                              }
                            });
                          },
                        );
                      }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(LocaleKeys.buttons_cancel.tr()),
                ),
                TextButton(
                  onPressed:
                      selectedSpecialties.isEmpty
                          ? null
                          : () {
                            Navigator.pop(context);
                            final selectedIds =
                                selectedSpecialties
                                    .map((e) => e.id)
                                    .whereType<int>()
                                    .toList();
                            _personalSpecialtyCubit.addSpecialty(
                              userId: userId,
                              specialtyIds: selectedIds,
                            );
                          },
                  child: Text(LocaleKeys.buttons_add.tr()),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildProfileHeader(UserDetailModel user) {
    final theme = Theme.of(context);
    final fullName = [
      user.firstName ?? '',
      user.lastName ?? '',
    ].where((e) => e.isNotEmpty).join(' ');

    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: theme.primaryColor.withValues(alpha: .1),
            backgroundImage:
                user.doctorAvatar != "no image" && user.doctorAvatar != null
                    ? NetworkImage(user.doctorAvatar!) as ImageProvider
                    : null,
            child:
                user.doctorAvatar == "no image" || user.doctorAvatar == null
                    ? Icon(Icons.person, size: 50, color: theme.primaryColor)
                    : null,
          ),
          const SizedBox(height: 16),
          Text(
            fullName,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          if (user.email != null) ...[
            const SizedBox(height: 4),
            Text(
              user.email!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickStatsSection() {
    return Row(
      children: [
        Expanded(
          child: ValueListenableBuilder<int>(
            valueListenable: quantityOfVisits,
            builder: (context, value, child) {
              return _buildStatCard(
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
          child: _buildStatCard(
            icon: Icons.calendar_today,
            value: '36',
            label: LocaleKeys.general_count_appointments.tr(),
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.medical_services,
            value: '57',
            label: LocaleKeys.general_count_services.tr(),
            color: Colors.purple,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Tooltip(
      message: '$label: $value',
      showDuration: const Duration(seconds: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: .9),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: .3),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      textStyle: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
        fontSize: 14,
      ),
      preferBelow: false,
      verticalOffset: 20,
      triggerMode: TooltipTriggerMode.tap,
      child: CustomCardDecoration(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalInfoSection(UserDetailModel user) {
    return CustomCardDecoration(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LocaleKeys.forms_personal_info.tr(),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            if (user.patronymic != null && user.patronymic!.isNotEmpty)
              _buildInfoRow(
                icon: Icons.person,
                label: LocaleKeys.forms_patronymic.tr(),
                value: user.patronymic!,
              ),
            _buildInfoRow(
              icon: Icons.male,
              label: LocaleKeys.forms_gender.tr(),
              value: Gender.fromString(user.gender ?? '-').displayName.tr(),
            ),
            if (user.birthDate != null)
              _buildInfoRow(
                icon: Icons.cake,
                label: LocaleKeys.forms_birthday.tr(),
                value: user.birthDate!,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfoSection(UserDetailModel user) {
    return CustomCardDecoration(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LocaleKeys.forms_contact_info.tr(),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              icon: Icons.phone,
              label: LocaleKeys.forms_phone.tr(),
              value: FormatUtils.formatPhoneNumber(user.phoneNumber ?? ''),
              showVisibilityStatus: true,
              isVisible: user.isVisibilityPhoneNumber ?? false,
            ),
            if (user.phoneNumber2 != null)
              _buildInfoRow(
                icon: Icons.phone_iphone,
                label: LocaleKeys.forms_alternative_phone.tr(),
                value: user.phoneNumber2!,
              ),
            _buildInfoRow(
              icon: Icons.email,
              label: LocaleKeys.forms_email.tr(),
              value: user.email ?? '-',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPayrollInfoSection(PayrollCalculationsResponse payroll) {
    return CustomCardDecoration(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LocaleKeys.forms_role_salary.tr(),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              icon: Icons.payments,
              label: LocaleKeys.forms_salary.tr(),
              value: payroll.salary?.toString() ?? '-',
            ),
            _buildInfoRow(
              icon: Icons.monetization_on,
              label: LocaleKeys.forms_salary_type.tr(),
              value:
                  SalaryType.fromString(
                    payroll.percentOrFixed ?? '-',
                  ).displayName.tr(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkingHoursSection() {
    final today = DateTime.now();
    // Find the Monday of current week
    final currentWeekStart = today.subtract(Duration(days: today.weekday - 1));

    return BlocProvider(
      create:
          (context) =>
              PersonalWorkScheduleCubit()
                ..getDoctorSchedule(widget.userId, currentWeekStart),
      child: BlocConsumer<PersonalWorkScheduleCubit, PersonalWorkScheduleState>(
        listener: (context, state) {
          if (state is PersonalWorkScheduleLoaded) {
            _calculateTotalWorkingHours(
              state.schedule.dayScheduleResponses ?? [],
            );
          }
        },
        builder: (context, state) {
          return CustomCardDecoration(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildScheduleHeader(context, state),
                  const SizedBox(height: 16),
                  if (state is PersonalWorkScheduleLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (state is PersonalWorkScheduleError)
                    _buildScheduleError(context, state)
                  else if (state is PersonalWorkScheduleLoaded)
                    _buildScheduleContent(context, state.schedule)
                  else
                    const SizedBox.shrink(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildScheduleHeader(
    BuildContext context,
    PersonalWorkScheduleState state,
  ) {
    String dateRange = '';
    bool canNavigate = state is PersonalWorkScheduleLoaded;

    if (state is PersonalWorkScheduleLoaded) {
      final startDate = state.schedule.startDate;
      final endDate = state.schedule.endDate;
      if (startDate != null && endDate != null) {
        final start = DateFormat('MMM d').format(DateTime.parse(startDate));
        final end = DateFormat('MMM d, yyyy').format(DateTime.parse(endDate));
        dateRange = '$start - $end';
      }
    }

    return Row(
      children: [
        Icon(
          Icons.calendar_month,
          color: Theme.of(context).colorScheme.primary,
          size: 24,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                LocaleKeys.general_working_schedule.tr(),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              if (dateRange.isNotEmpty)
                Text(
                  dateRange,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ),
        if (canNavigate)
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, size: 18),
                onPressed: () {
                  if (state.schedule.startDate != null) {
                    final startDate = DateTime.parse(state.schedule.startDate!);
                    final prevWeek = startDate.subtract(
                      const Duration(days: 7),
                    );
                    context.read<PersonalWorkScheduleCubit>().getDoctorSchedule(
                      widget.userId,
                      prevWeek,
                    );
                  }
                },
                tooltip: LocaleKeys.general_previous_week.tr(),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios, size: 18),
                onPressed: () {
                  if (state.schedule.startDate != null) {
                    final startDate = DateTime.parse(state.schedule.startDate!);
                    final nextWeek = startDate.add(const Duration(days: 7));
                    context.read<PersonalWorkScheduleCubit>().getDoctorSchedule(
                      widget.userId,
                      nextWeek,
                    );
                  }
                },
                tooltip: LocaleKeys.general_next_week.tr(),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildScheduleError(
    BuildContext context,
    PersonalWorkScheduleError state,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 40,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 8),
          Text(
            state.message,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () {
              final today = DateTime.now();
              final currentWeekStart = today.subtract(
                Duration(days: today.weekday - 1),
              );
              context.read<PersonalWorkScheduleCubit>().getDoctorSchedule(
                widget.userId,
                currentWeekStart,
              );
            },
            icon: const Icon(Icons.refresh),
            label: Text(LocaleKeys.buttons_retry.tr()),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleContent(BuildContext context, ScheduleModel schedule) {
    final days = schedule.dayScheduleResponses ?? [];
    if (days.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Text(
            LocaleKeys.notifications_no_schedule_available.tr(),
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(fontStyle: FontStyle.italic),
          ),
        ),
      );
    }

    // Calculate and update total working hours

    return Column(
      children: days.map((day) => _buildDayScheduleItem(context, day)).toList(),
    );
  }

  // Store total working hours for the week
  final ValueNotifier<double> totalWorkingHours = ValueNotifier(0);

  void _calculateTotalWorkingHours(List<DayScheduleResponses> days) {
    double totalHours = 0;

    for (final day in days) {
      if (day.workingDay == true &&
          day.startTime != null &&
          day.endTime != null) {
        // Parse start time
        final startTimeParts = day.startTime!.split(':');
        final startHour = int.tryParse(startTimeParts[0]) ?? 0;
        final startMinute =
            startTimeParts.length > 1
                ? (int.tryParse(startTimeParts[1]) ?? 0)
                : 0;

        // Parse end time
        final endTimeParts = day.endTime!.split(':');
        final endHour = int.tryParse(endTimeParts[0]) ?? 0;
        final endMinute =
            endTimeParts.length > 1 ? (int.tryParse(endTimeParts[1]) ?? 0) : 0;

        // Calculate hours worked
        double hoursWorked =
            (endHour + endMinute / 60.0) - (startHour + startMinute / 60.0);

        // Subtract breaks if any
        if (day.breaks != null && day.breaks!.isNotEmpty) {
          for (final breakItem in day.breaks!) {
            if (breakItem.startTime != null && breakItem.endTime != null) {
              final breakStartParts = breakItem.startTime!.split(':');
              final breakStartHour = int.tryParse(breakStartParts[0]) ?? 0;
              final breakStartMinute =
                  breakStartParts.length > 1
                      ? (int.tryParse(breakStartParts[1]) ?? 0)
                      : 0;

              final breakEndParts = breakItem.endTime!.split(':');
              final breakEndHour = int.tryParse(breakEndParts[0]) ?? 0;
              final breakEndMinute =
                  breakEndParts.length > 1
                      ? (int.tryParse(breakEndParts[1]) ?? 0)
                      : 0;

              double breakHours =
                  (breakEndHour + breakEndMinute / 60.0) -
                  (breakStartHour + breakStartMinute / 60.0);
              hoursWorked -= breakHours;
            }
          }
        }

        if (hoursWorked > 0) {
          totalHours += hoursWorked;
        }
      }
    }

    totalWorkingHours.value = totalHours;
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

  Widget _buildDayScheduleItem(BuildContext context, DayScheduleResponses day) {
    final theme = Theme.of(context);
    final isWorkingDay = day.workingDay ?? false;
    final weekDay = day.week ?? '';
    final today = DateTime.now();
    final isToday = today.weekday == _getWeekdayFromString(weekDay);

    // Format the time
    String timeString = '-';
    if (isWorkingDay && day.startTime != null && day.endTime != null) {
      final start =
          day.startTime!.split(':').length > 1
              ? day.startTime!.split(':').sublist(0, 2).join(':')
              : day.startTime!;

      final end =
          day.endTime!.split(':').length > 1
              ? day.endTime!.split(':').sublist(0, 2).join(':')
              : day.endTime!;

      timeString = '$start - $end';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color:
            isToday ? theme.colorScheme.primary.withValues(alpha: 0.1) : null,
        borderRadius: BorderRadius.circular(8),
        border:
            isToday
                ? Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                )
                : null,
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color:
                  isWorkingDay
                      ? theme.colorScheme.primary
                      : theme.colorScheme.error,
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 100,
            child: Text(
              Week.fromString(weekDay).displayName.tr(),
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Expanded(
            child: Text(
              isWorkingDay ? timeString : LocaleKeys.general_day_off.tr(),
              style: TextStyle(
                color:
                    isWorkingDay
                        ? theme.colorScheme.onSurface
                        : theme.colorScheme.error,
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          if (day.breaks != null && day.breaks!.isNotEmpty)
            Tooltip(
              message: _formatBreaks(day.breaks!),
              child: const Icon(Icons.coffee, size: 18, color: Colors.brown),
            ),
        ],
      ),
    );
  }

  int _getWeekdayFromString(String weekday) {
    switch (weekday.toUpperCase()) {
      case 'MONDAY':
        return 1;
      case 'TUESDAY':
        return 2;
      case 'WEDNESDAY':
        return 3;
      case 'THURSDAY':
        return 4;
      case 'FRIDAY':
        return 5;
      case 'SATURDAY':
        return 6;
      case 'SUNDAY':
        return 7;
      default:
        return 0;
    }
  }

  String _formatBreaks(List<Breaks> breaks) {
    if (breaks.isEmpty) return '';

    final breaksList = breaks
        .map((breakItem) {
          final start =
              breakItem.startTime?.split(':').sublist(0, 2).join(':') ?? '';
          final end =
              breakItem.endTime?.split(':').sublist(0, 2).join(':') ?? '';
          final title =
              breakItem.title != null && breakItem.title!.isNotEmpty
                  ? '${breakItem.title}: '
                  : '';

          return '$title$start - $end';
        })
        .join('\n');

    return 'Breaks:\n$breaksList';
  }

  Widget _buildPerformanceSection() {
    return CustomCardDecoration(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.insert_chart,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  LocaleKeys.general_staff_statistics.tr(),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ValueListenableBuilder<int>(
                    valueListenable: quantityOfVisits,
                    builder: (context, value, child) {
                      return _buildPerformanceItem(
                        value: value.toString(),
                        label: LocaleKeys.general_quantity_of_visits.tr(),
                        icon: Icons.people,
                        color: Colors.blue,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildPerformanceItem(
                    value: '57',
                    label: LocaleKeys.general_quantity_of_services.tr(),
                    icon: Icons.medical_services,
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
                    value: '98.5%',
                    label: 'Satisfaction',
                    icon: Icons.thumb_up,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ValueListenableBuilder<double>(
                    valueListenable: totalWorkingHours,
                    builder: (context, hours, child) {
                      return _buildPerformanceItem(
                        value: _formatWorkingHours(hours),
                        label: LocaleKeys.general_hours_worked.tr(),
                        icon: Icons.access_time,
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
    );
  }

  Widget _buildPerformanceItem({
    required String value,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Tooltip(
      message: '$label: $value',
      showDuration: const Duration(seconds: 2),
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
      preferBelow: false,
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.1),
            radius: 20,
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentPatientsSection(List<VisitModel> visits) {
    return CustomCardDecoration(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.people,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      LocaleKeys.routes_visits.tr(),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                if (visits.length > 5)
                  TextButton(
                    onPressed: () {
                      router.push(PersonalPatientsRoute(userId: widget.userId));
                    },
                    child: Text(LocaleKeys.buttons_view_all.tr()),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            ...visits
                .take(5)
                .map((patient) => PersonalPatientItem(patient: patient)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    bool showVisibilityStatus = false,
    bool isVisible = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        value,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                    if (showVisibilityStatus)
                      Icon(
                        isVisible ? Icons.visibility : Icons.visibility_off,
                        size: 16,
                        color: isVisible ? Colors.green : Colors.grey,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Class for chart data
class ChartData {
  ChartData(this.x, this.y);
  final String x;
  final double y;
}
