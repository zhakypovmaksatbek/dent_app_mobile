// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/main.dart';
import 'package:dent_app_mobile/models/users/create_schedule_model.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/personal/core/bloc/create_schedule/create_schedule_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/personal/core/util/week.dart';
import 'package:dent_app_mobile/presentation/widgets/buttons/def_elevated_button.dart';
import 'package:dent_app_mobile/presentation/widgets/card/custom_card_decoration.dart';
import 'package:dent_app_mobile/presentation/widgets/snack_bars/app_snack_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateScheduleContent extends StatefulWidget {
  const CreateScheduleContent({super.key, required this.id});
  final int id;
  @override
  State<CreateScheduleContent> createState() => _CreateScheduleContentState();
}

class _CreateScheduleContentState extends State<CreateScheduleContent> {
  late final CreateScheduleCubit _createScheduleCubit;
  // Controllers
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  // Model
  late CreateScheduleModel _scheduleModel;

  // Performance optimized notifiers
  final ValueNotifier<String?> _startDateNotifier = ValueNotifier<String?>(
    null,
  );
  final ValueNotifier<String?> _endDateNotifier = ValueNotifier<String?>(null);
  final ValueNotifier<List<DayScheduleRequests>> _daySchedulesNotifier =
      ValueNotifier<List<DayScheduleRequests>>([]);
  final ValueNotifier<bool> _isLoadingNotifier = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _createScheduleCubit = CreateScheduleCubit();
    _initializeSchedule();
  }

  void _initializeSchedule() {
    final today = DateTime.now();

    _scheduleModel = CreateScheduleModel(
      startDate: DateFormat('yyyy-MM-dd').format(today),
      endDate: null, // End date is empty by default
      dayScheduleRequests:
          Week.values
              .map(
                (week) => DayScheduleRequests(
                  dayOfWeek: week.name.toUpperCase(),
                  workingDay: week != Week.saturday && week != Week.sunday,
                  startTime: '09:00',
                  endTime: '18:00',
                  breakPatternIds: [],
                ),
              )
              .toList(),
    );

    // Set initial values
    _startDateController.text = DateFormat('dd/MM/yyyy').format(today);
    _startDateNotifier.value = _scheduleModel.startDate;
    _daySchedulesNotifier.value = _scheduleModel.dayScheduleRequests ?? [];
  }

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    _startDateNotifier.dispose();
    _endDateNotifier.dispose();
    _daySchedulesNotifier.dispose();
    _isLoadingNotifier.dispose();
    _createScheduleCubit.close();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final now =
        DateTime.now(); // Use same instance for both initial and minimum
    DateTime selectedDate = now;

    // If editing end date and start date is selected, use start date as initial
    if (!isStartDate && _scheduleModel.startDate != null) {
      final startDateTime = DateTime.parse(_scheduleModel.startDate!);
      // Ensure the selected date is not before minimum date
      selectedDate = startDateTime.isAfter(now) ? startDateTime : now;
    }

    await showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) {
        return Material(
          child: Container(
            height: 400,
            padding: const EdgeInsets.only(top: 6.0),
            color: Colors.white,
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  // Header with Done and Cancel buttons
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        bottom: BorderSide(color: Colors.grey, width: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(
                            MaterialLocalizations.of(context).cancelButtonLabel,
                          ),
                        ),
                        Flexible(
                          child: Text(
                            isStartDate
                                ? LocaleKeys.date_range_select_start_date.tr()
                                : LocaleKeys.date_range_select_end_date.tr(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            final formattedDate = DateFormat(
                              'yyyy-MM-dd',
                            ).format(selectedDate);
                            final displayDate = DateFormat(
                              'dd/MM/yyyy',
                            ).format(selectedDate);

                            if (isStartDate) {
                              _scheduleModel.startDate = formattedDate;
                              _startDateController.text = displayDate;
                              _startDateNotifier.value = formattedDate;
                            } else {
                              _scheduleModel.endDate = formattedDate;
                              _endDateController.text = displayDate;
                              _endDateNotifier.value = formattedDate;
                            }

                            Navigator.of(context).pop();
                          },
                          child: Text(
                            MaterialLocalizations.of(context).saveButtonLabel,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Date picker
                  Expanded(
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.date,
                      initialDateTime: selectedDate,
                      minimumDate: now, // Use same instance
                      maximumDate: now.add(const Duration(days: 365)),
                      onDateTimeChanged: (DateTime newDate) {
                        selectedDate = newDate;
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _selectTime(
    BuildContext context,
    String dayOfWeek,
    bool isStartTime,
  ) async {
    final DayScheduleRequests? dayRequest = _scheduleModel.dayScheduleRequests
        ?.firstWhere((day) => day.dayOfWeek == dayOfWeek);

    if (dayRequest == null) return;

    // Parse current time or use default
    String currentTimeString =
        isStartTime
            ? (dayRequest.startTime ?? '09:00')
            : (dayRequest.endTime ?? '18:00');

    final timeParts = currentTimeString.split(':');
    final currentHour = int.tryParse(timeParts[0]) ?? 9;
    final currentMinute =
        timeParts.length > 1 ? (int.tryParse(timeParts[1]) ?? 0) : 0;

    Duration selectedDuration = Duration(
      hours: currentHour,
      minutes: currentMinute,
    );

    await showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) {
        return Material(
          child: Container(
            height: 400,
            padding: const EdgeInsets.only(top: 6.0),
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  // Header with Done and Cancel buttons
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        bottom: BorderSide(color: Colors.grey, width: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(
                            MaterialLocalizations.of(context).cancelButtonLabel,
                          ),
                        ),
                        Flexible(
                          child: Text(
                            isStartTime
                                ? LocaleKeys.date_range_select_start_time.tr()
                                : LocaleKeys.date_range_select_end_time.tr(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            final hours = selectedDuration.inHours;
                            final minutes = selectedDuration.inMinutes
                                .remainder(60);
                            final formattedTime =
                                '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';

                            if (isStartTime) {
                              dayRequest.startTime = formattedTime;
                            } else {
                              dayRequest.endTime = formattedTime;
                            }

                            // Update the notifier to trigger rebuild
                            _daySchedulesNotifier.value = List.from(
                              _scheduleModel.dayScheduleRequests ?? [],
                            );

                            Navigator.of(context).pop();
                          },
                          child: Text(
                            MaterialLocalizations.of(context).saveButtonLabel,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Time picker
                  Expanded(
                    child: CupertinoTimerPicker(
                      mode: CupertinoTimerPickerMode.hm,
                      initialTimerDuration: selectedDuration,
                      onTimerDurationChanged: (Duration newDuration) {
                        selectedDuration = newDuration;
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _toggleWorkingDay(String dayOfWeek, bool value) {
    final DayScheduleRequests? dayRequest = _scheduleModel.dayScheduleRequests
        ?.firstWhere((day) => day.dayOfWeek == dayOfWeek);

    if (dayRequest != null) {
      dayRequest.workingDay = value;
      // Update the notifier to trigger rebuild only for weekly schedule
      _daySchedulesNotifier.value = List.from(
        _scheduleModel.dayScheduleRequests ?? [],
      );
    }
  }

  void _saveSchedule() {
    // Validate required fields
    if (_scheduleModel.startDate == null || _scheduleModel.endDate == null) {
      AppSnackBar.showErrorSnackBar(
        context,
        LocaleKeys.date_range_select_start_date.tr(),
      );
      return;
    }
    _createScheduleCubit.createSchedule(widget.id, _scheduleModel);
    // TODO: Implement API call to save schedule
    debugPrint('Schedule Model: ${_scheduleModel.toJson()}');

    // Close modal after successful save
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.3,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return BlocProvider.value(
          value: _createScheduleCubit,
          child: BlocListener<CreateScheduleCubit, CreateScheduleState>(
            listener: (context, state) {
              if (state is CreateScheduleSuccess) {
                router.maybePop();
                AppSnackBar.showSuccessSnackBar(
                  context,
                  state.response.message ??
                      LocaleKeys.alerts_operation_successful.tr(),
                );
                _isLoadingNotifier.value = false;
              } else if (state is CreateScheduleLoading) {
                _isLoadingNotifier.value = true;
              } else if (state is CreateScheduleError) {
                _isLoadingNotifier.value = false;
                AppSnackBar.showErrorSnackBar(context, state.error);
              }
            },
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  _buildModalHeader(),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDateRangeSection(),
                          const SizedBox(height: 24),
                          ValueListenableBuilder<String?>(
                            valueListenable: _startDateNotifier,
                            builder: (context, startDate, child) {
                              return ValueListenableBuilder<String?>(
                                valueListenable: _endDateNotifier,
                                builder: (context, endDate, child) {
                                  final areDatesSelected =
                                      startDate != null && endDate != null;
                                  return AnimatedOpacity(
                                    opacity: areDatesSelected ? 1.0 : 0.3,
                                    duration: const Duration(milliseconds: 300),
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      child:
                                          areDatesSelected
                                              ? _buildWeeklyScheduleSection()
                                              : _buildDisabledWeeklyScheduleSection(),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                          const SizedBox(height: 32),
                          ValueListenableBuilder<String?>(
                            valueListenable: _startDateNotifier,
                            builder: (context, startDate, child) {
                              return ValueListenableBuilder<String?>(
                                valueListenable: _endDateNotifier,
                                builder: (context, endDate, child) {
                                  return _buildSaveButton(
                                    enabled:
                                        startDate != null && endDate != null,
                                  );
                                },
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildModalHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          // Header with title and close button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                LocaleKeys.buttons_create_schedule.tr(),
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
                splashRadius: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateRangeSection() {
    return CustomCardDecoration(
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
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.date_range,
                    color: Theme.of(context).primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  LocaleKeys.date_range_schedule_period.tr(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              spacing: 12,
              children: [
                ValueListenableBuilder<String?>(
                  valueListenable: _startDateNotifier,
                  builder: (context, startDate, child) {
                    return _buildCompactDateButton(
                      title: LocaleKeys.date_range_start_date.tr(),
                      value:
                          _startDateController.text.isEmpty
                              ? LocaleKeys.date_range_select_start_date.tr()
                              : _startDateController.text,
                      icon: Icons.calendar_today,
                      isSelected: _startDateController.text.isNotEmpty,
                      onTap: () => _selectDate(context, true),
                    );
                  },
                ),
                Divider(),
                ValueListenableBuilder<String?>(
                  valueListenable: _endDateNotifier,
                  builder: (context, endDate, child) {
                    return Column(
                      spacing: 4,
                      children: [
                        _buildCompactDateButton(
                          title: LocaleKeys.date_range_end_date.tr(),
                          value:
                              _endDateController.text.isEmpty
                                  ? LocaleKeys.date_range_select_end_date.tr()
                                  : _endDateController.text,
                          icon: Icons.event,
                          isSelected: _endDateController.text.isNotEmpty,
                          onTap: () => _selectDate(context, false),
                        ),
                        if (_startDateController.text.isNotEmpty &&
                            _endDateController.text.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: Theme.of(context).primaryColor,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    LocaleKeys
                                        .date_range_schedule_period_configured
                                        .tr(),
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactDateButton({
    required String title,
    required String value,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          child: Row(
            children: [
              Icon(
                icon,
                color:
                    isSelected
                        ? Theme.of(context).primaryColor
                        : Colors.grey[400],
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isSelected ? Colors.grey[800] : Colors.grey[500],
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklyScheduleSection() {
    return CustomCardDecoration(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  LocaleKeys.date_range_weekly_schedule.tr(),
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              LocaleKeys.date_range_set_working_hours.tr(),
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            ValueListenableBuilder<List<DayScheduleRequests>>(
              valueListenable: _daySchedulesNotifier,
              builder: (context, daySchedules, child) {
                return Column(
                  children:
                      daySchedules
                          .map(
                            (dayRequest) => _buildDayScheduleCard(dayRequest),
                          )
                          .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayScheduleCard(DayScheduleRequests dayRequest) {
    final isWorkingDay = dayRequest.workingDay ?? false;
    final week = Week.fromString(dayRequest.dayOfWeek ?? '');
    final dayName = week.displayName.tr();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isWorkingDay ? Colors.blue.shade50 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isWorkingDay ? Colors.blue.shade200 : Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                dayName,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              Switch(
                value: isWorkingDay,
                onChanged:
                    (value) => _toggleWorkingDay(dayRequest.dayOfWeek!, value),
                activeThumbColor: Theme.of(context).primaryColor,
              ),
            ],
          ),
          if (isWorkingDay) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTimeField(
                    label: LocaleKeys.date_range_start_time.tr(),
                    time: dayRequest.startTime ?? '09:00',
                    onTap:
                        () => _selectTime(context, dayRequest.dayOfWeek!, true),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTimeField(
                    label: LocaleKeys.date_range_end_time.tr(),
                    time: dayRequest.endTime ?? '18:00',
                    onTap:
                        () =>
                            _selectTime(context, dayRequest.dayOfWeek!, false),
                  ),
                ),
              ],
            ),
          ] else ...[
            const SizedBox(height: 8),
            Text(
              LocaleKeys.validation_non_working_day.tr(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeField({
    required String label,
    required String time,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(time, style: Theme.of(context).textTheme.bodyMedium),
                Icon(Icons.access_time, size: 18, color: Colors.grey[600]),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton({bool enabled = false}) {
    return ValueListenableBuilder<bool>(
      valueListenable: _isLoadingNotifier,
      builder: (context, isLoading, child) {
        return SizedBox(
          width: double.infinity,
          child: DefElevatedButton(
            title: LocaleKeys.buttons_create_schedule.tr(),
            onPressed: isLoading ? null : _saveSchedule,
          ),
        );
      },
    );
  }

  Widget _buildDisabledWeeklyScheduleSection() {
    return CustomCardDecoration(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    LocaleKeys.date_range_weekly_schedule.tr(),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              LocaleKeys.date_range_set_working_hours.tr(),
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            Text(
              LocaleKeys.date_range_please_select_dates.tr(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
