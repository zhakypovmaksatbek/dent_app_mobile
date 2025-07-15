import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/models/users/schedule_model.dart';
import 'package:dent_app_mobile/presentation/localization/app_localization.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/personal/core/bloc/personal_work_schedule/personal_work_schedule_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/personal/core/util/week.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/personal/widgets/create_schedule_content.dart';
import 'package:dent_app_mobile/presentation/theme/colors/color_constants.dart';
import 'package:dent_app_mobile/presentation/widgets/text/app_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WorkingScheduleViewer extends StatefulWidget {
  const WorkingScheduleViewer({
    super.key,
    required this.userId,
    this.isAdmin = false,
  });
  final bool isAdmin;
  final int userId;

  @override
  State<WorkingScheduleViewer> createState() => _WorkingScheduleViewerState();
}

class _WorkingScheduleViewerState extends State<WorkingScheduleViewer>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final currentWeekStart = today.subtract(Duration(days: today.weekday - 1));

    return Container(
      height: MediaQuery.of(context).size.height * 0.93,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: BlocProvider(
        create:
            (context) =>
                PersonalWorkScheduleCubit()
                  ..getDoctorSchedule(widget.userId, currentWeekStart),
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: BlocBuilder<
                PersonalWorkScheduleCubit,
                PersonalWorkScheduleState
              >(
                builder: (context, state) {
                  if (state is PersonalWorkScheduleLoading) {
                    return _buildLoadingState();
                  } else if (state is PersonalWorkScheduleError) {
                    return _buildErrorState(context, state);
                  } else if (state is PersonalWorkScheduleLoaded) {
                    return _buildScheduleContent(context, state);
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            children: [
              // Drag Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              // Header Content
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.schedule_outlined,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          LocaleKeys.general_working_schedule.tr(),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          LocaleKeys.general_your_weekly_working_hours.tr(),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 24,
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

  Widget _buildLoadingState() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 16),
            Text(
              'Loading schedule...',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    PersonalWorkScheduleError state,
  ) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Oops! Something went wrong',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                state.message,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleContent(
    BuildContext context,
    PersonalWorkScheduleLoaded state,
  ) {
    final days = state.schedule.dayScheduleResponses ?? [];
    final totalHours = _calculateTotalWorkingHours(days);

    if (days.isEmpty) {
      return _buildEmptyState(context);
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          children: [
            // Week Navigation
            _buildWeekNavigation(context, state),

            /// MARK: Total Hours Summary
            /// TODO: Implement this
            // _buildTotalHoursSummary(totalHours),

            // Days List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                itemCount: days.length,
                itemBuilder: (context, index) {
                  return AnimatedContainer(
                    duration: Duration(milliseconds: 100 + (index * 50)),
                    curve: Curves.easeOutCubic,
                    child: _buildDayCard(
                      context,
                      days[index],
                      index,
                      state.schedule,
                    ),
                  );
                },
              ),
            ),

            // Action Buttons
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.schedule_outlined,
                  size: 48,
                  color: Colors.grey[400],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'No Schedule Available',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Create your first schedule to get started',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => _showCreateSchedule(context),
                icon: const Icon(Icons.add),
                label: const Text('Create Schedule'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeekNavigation(
    BuildContext context,
    PersonalWorkScheduleLoaded state,
  ) {
    String dateRange = '';
    final startDate = state.schedule.startDate;
    final endDate = state.schedule.endDate;
    final locale = AppLocalization.getCurrentLanguageCode(context);
    if (startDate != null && endDate != null) {
      final start = DateFormat(
        'MMM d',
        locale,
      ).format(DateTime.parse(startDate));
      final end = DateFormat(
        'MMM d, yyyy',
        locale,
      ).format(DateTime.parse(endDate));
      dateRange = '$start - $end';
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              if (startDate != null) {
                final start = DateTime.parse(startDate);
                final prevWeek = start.subtract(const Duration(days: 7));
                context.read<PersonalWorkScheduleCubit>().getDoctorSchedule(
                  widget.userId,
                  prevWeek,
                );
              }
            },
            icon: Icon(Icons.chevron_left, color: AppColors.primary),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.all(6),
              minimumSize: const Size(32, 32),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  'Current Week',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  dateRange,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              if (startDate != null) {
                final start = DateTime.parse(startDate);
                final nextWeek = start.add(const Duration(days: 7));
                context.read<PersonalWorkScheduleCubit>().getDoctorSchedule(
                  widget.userId,
                  nextWeek,
                );
              }
            },
            icon: Icon(Icons.chevron_right, color: AppColors.primary),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.all(6),
              minimumSize: const Size(32, 32),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalHoursSummary(double totalHours) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.withValues(alpha: 0.1),
            Colors.green.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.access_time, color: Colors.green, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Working Hours',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatWorkingHours(totalHours),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayCard(
    BuildContext context,
    DayScheduleResponses day,
    int index,
    ScheduleModel schedule,
  ) {
    final isWorkingDay = day.workingDay ?? false;
    final weekDay = day.week ?? '';
    final today = DateTime.now();

    // Calculate the actual date for this day
    bool isToday = false;
    if (schedule.startDate != null) {
      try {
        final weekStart = DateTime.parse(schedule.startDate!);
        final dayIndex =
            _getWeekdayFromString(weekDay) - 1; // Convert to 0-based index
        final dayDate = weekStart.add(Duration(days: dayIndex));
        isToday =
            dayDate.year == today.year &&
            dayDate.month == today.month &&
            dayDate.day == today.day;
      } catch (e) {
        // Fallback to weekday comparison if date parsing fails
        isToday = today.weekday == _getWeekdayFromString(weekDay);
      }
    } else {
      // Fallback to weekday comparison if start date is not available
      isToday = today.weekday == _getWeekdayFromString(weekDay);
    }

    String timeString = LocaleKeys.general_day_off.tr();
    if (isWorkingDay && day.startTime != null && day.endTime != null) {
      final start = day.startTime!.split(':').sublist(0, 2).join(':');
      final end = day.endTime!.split(':').sublist(0, 2).join(':');
      timeString = '$start - $end';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8, top: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isToday
                  ? AppColors.primary.withValues(alpha: 0.3)
                  : Colors.grey.withValues(alpha: 0.1),
          width: isToday ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color:
                isToday
                    ? AppColors.primary.withValues(alpha: 0.08)
                    : Colors.grey.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            // Day Indicator
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color:
                    isWorkingDay
                        ? (isToday ? AppColors.primary : Colors.green)
                        : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: (isWorkingDay
                            ? (isToday ? AppColors.primary : Colors.green)
                            : Colors.grey)
                        .withValues(alpha: 0.15),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppText(
                    title: Week.fromString(
                      weekDay,
                    ).displayName.tr().substring(0, 3),
                    textType: TextType.description,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 1),
                  Icon(
                    isWorkingDay ? Icons.work : Icons.free_breakfast,
                    color: Colors.white,
                    size: 12,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Day Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      AppText(
                        title: Week.fromString(weekDay).displayName.tr(),
                        textType: TextType.subtitle,
                        color: isToday ? AppColors.primary : Colors.grey[800],
                        fontWeight: FontWeight.bold,
                      ),
                      if (isToday) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: AppText(
                            title: LocaleKeys.date_range_today.tr(),
                            textType: TextType.small,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  AppText(
                    title: timeString,
                    textType: TextType.subtitle,
                    color: isWorkingDay ? Colors.grey[800] : Colors.grey[600],
                  ),
                  if (day.breaks != null && day.breaks!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.coffee, size: 12, color: Colors.brown[600]),
                        const SizedBox(width: 3),
                        AppText(
                          title: '${day.breaks!.length} break(s)',
                          textType: TextType.small,
                          color: Colors.brown[600],
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            // Status Icon
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: (isWorkingDay ? Colors.green : Colors.grey).withValues(
                  alpha: 0.1,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                isWorkingDay ? Icons.check_circle : Icons.cancel,
                color: isWorkingDay ? Colors.green : Colors.grey,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      margin: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: OutlinedButton.icon(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.close),
        label: Text(LocaleKeys.buttons_close.tr()),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.grey[700],
          side: BorderSide(color: Colors.grey.shade300),
          minimumSize: const Size(double.infinity, 48),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  void _showCreateSchedule(BuildContext context) {
    Navigator.pop(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateScheduleContent(id: widget.userId),
    );
  }

  double _calculateTotalWorkingHours(List<DayScheduleResponses> days) {
    double totalHours = 0;

    for (final day in days) {
      if (day.workingDay == true &&
          day.startTime != null &&
          day.endTime != null) {
        final startTimeParts = day.startTime!.split(':');
        final startHour = int.tryParse(startTimeParts[0]) ?? 0;
        final startMinute =
            startTimeParts.length > 1
                ? (int.tryParse(startTimeParts[1]) ?? 0)
                : 0;

        final endTimeParts = day.endTime!.split(':');
        final endHour = int.tryParse(endTimeParts[0]) ?? 0;
        final endMinute =
            endTimeParts.length > 1 ? (int.tryParse(endTimeParts[1]) ?? 0) : 0;

        double hoursWorked =
            (endHour + endMinute / 60.0) - (startHour + startMinute / 60.0);

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

    return totalHours;
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
}
