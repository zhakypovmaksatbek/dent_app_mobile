import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/models/users/schedule_model.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/personal/core/bloc/personal_work_schedule/personal_work_schedule_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/personal/core/util/week.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/personal/widgets/create_schedule_content.dart';
import 'package:dent_app_mobile/presentation/widgets/card/custom_card_decoration.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WorkingHoursSection extends StatefulWidget {
  const WorkingHoursSection({
    super.key,
    required this.userId,
    this.onTotalHoursChanged,
  });

  final int userId;
  final ValueChanged<double>? onTotalHoursChanged;

  @override
  State<WorkingHoursSection> createState() => _WorkingHoursSectionState();
}

class _WorkingHoursSectionState extends State<WorkingHoursSection> {
  final ValueNotifier<double> totalWorkingHours = ValueNotifier(0);

  @override
  void dispose() {
    totalWorkingHours.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final currentWeekStart = today.subtract(Duration(days: today.weekday - 1));

    return BlocProvider(
      create:
          (context) =>
              PersonalWorkScheduleCubit()
                ..getDoctorSchedule(widget.userId, currentWeekStart),
      child: BlocConsumer<PersonalWorkScheduleCubit, PersonalWorkScheduleState>(
        listener: (context, state) {
          if (state is PersonalWorkScheduleLoaded) {
            final hours = _calculateTotalWorkingHours(
              state.schedule.dayScheduleResponses ?? [],
            );
            totalWorkingHours.value = hours;
            widget.onTotalHoursChanged?.call(hours);
          }
        },
        builder: (context, state) {
          return CustomCardDecoration(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildScheduleHeader(context, state),
                  const SizedBox(height: 20),
                  if (state is PersonalWorkScheduleLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 32),
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
    final theme = Theme.of(context);
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
        Expanded(
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.schedule_outlined,
                  color: Colors.purple,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LocaleKeys.general_working_schedule.tr(),
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (dateRange.isNotEmpty)
                      Text(
                        dateRange,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.secondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
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
        IconButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              isDismissible: true,
              enableDrag: true,
              backgroundColor: Colors.transparent,
              builder: (context) => CreateScheduleContent(id: widget.userId),
            );
          },
          icon: const Icon(Icons.edit_outlined),
          tooltip: LocaleKeys.notifications_add_schedule.tr(),
          style: IconButton.styleFrom(
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
            foregroundColor: theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleError(
    BuildContext context,
    PersonalWorkScheduleError state,
  ) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(
              state.message,
              style: TextStyle(color: theme.colorScheme.error, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
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
      ),
    );
  }

  Widget _buildScheduleContent(BuildContext context, ScheduleModel schedule) {
    final theme = Theme.of(context);
    final days = schedule.dayScheduleResponses ?? [];

    if (days.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.schedule_outlined, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                LocaleKeys.notifications_no_schedule_available.tr(),
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        ...days.map((day) => _buildDayScheduleItem(context, day)),
        const SizedBox(height: 16),
        ValueListenableBuilder<double>(
          valueListenable: totalWorkingHours,
          builder: (context, hours, child) {
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.access_time,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      LocaleKeys.general_total_working_hours.tr(),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(
                    _formatWorkingHours(hours),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDayScheduleItem(BuildContext context, DayScheduleResponses day) {
    final theme = Theme.of(context);
    final isWorkingDay = day.workingDay ?? false;
    final weekDay = day.week ?? '';
    final today = DateTime.now();
    final isToday = today.weekday == _getWeekdayFromString(weekDay);

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
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            isToday
                ? theme.colorScheme.primary.withValues(alpha: 0.1)
                : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isToday
                  ? theme.colorScheme.primary.withValues(alpha: 0.3)
                  : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color:
                  isWorkingDay
                      ? (isToday ? theme.colorScheme.primary : Colors.green)
                      : Colors.grey.shade400,
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 100,
            child: Text(
              Week.fromString(weekDay).displayName.tr(),
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: isToday ? FontWeight.bold : FontWeight.w600,
                color: isToday ? theme.colorScheme.primary : null,
              ),
            ),
          ),
          Expanded(
            child: Text(
              isWorkingDay ? timeString : LocaleKeys.general_day_off.tr(),
              style: theme.textTheme.bodyMedium?.copyWith(
                color:
                    isWorkingDay
                        ? (isToday
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface)
                        : Colors.grey.shade600,
                fontWeight: isToday ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
          if (day.breaks != null && day.breaks!.isNotEmpty)
            Tooltip(
              message: _formatBreaks(day.breaks!),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.brown.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.coffee, size: 16, color: Colors.brown),
              ),
            ),
        ],
      ),
    );
  }

  double _calculateTotalWorkingHours(List<DayScheduleResponses> days) {
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

    return totalHours;
  }

  String _formatWorkingHours(double hours) {
    final wholeHours = hours.floor();
    final minutes = ((hours - wholeHours) * 60).round();

    if (minutes > 0) {
      return '$wholeHours ч $minutes мин';
    } else {
      return '$wholeHours ч';
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
}
