import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/models/appointment/time_model.dart';
import 'package:dent_app_mobile/presentation/pages/calendar/bloc/free_time/free_time_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CombinedTimeDurationSelector extends StatefulWidget {
  final TimeModel? selectedTimeSlot;
  final Function(TimeModel, TimeOfDay, TimeOfDay) onTimeSelected;
  final VoidCallback onRefresh;
  final List<int> minuteOptions;
  final int selectedMinute;
  final Function(int) onDurationSelected;

  const CombinedTimeDurationSelector({
    super.key,
    required this.selectedTimeSlot,
    required this.onTimeSelected,
    required this.onRefresh,
    required this.minuteOptions,
    required this.selectedMinute,
    required this.onDurationSelected,
  });

  @override
  State<CombinedTimeDurationSelector> createState() =>
      _CombinedTimeDurationSelectorState();
}

class _CombinedTimeDurationSelectorState
    extends State<CombinedTimeDurationSelector> {
  late FixedExtentScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    final initialIndex = widget.minuteOptions.indexOf(widget.selectedMinute);
    _scrollController = FixedExtentScrollController(
      initialItem: initialIndex >= 0 ? initialIndex : 0,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FreeTimeCubit, FreeTimeState>(
      listener: (context, state) {
        if (state is FreeTimeLoaded) {
          /// burada gelen bos vakitleri burada gosterilecek ve
          /// secilen bos vakit disariya aktarilmasi lazim mesela onChanged gibi methodlari burada kullanacagiz
        }
      },
      builder: (context, state) {
        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              // Left side - Time slots
              Expanded(
                flex: 3,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        LocaleKeys.appointment_time.tr(),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildTimeSlotsList(),
                    ],
                  ),
                ),
              ),

              // Divider
              Container(width: 1, height: 200, color: Colors.grey[300]),

              // Right side - Duration picker
              Expanded(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Text(
                        LocaleKeys.general_minutes.tr(),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildDurationPicker(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimeSlotsList() {
    return BlocBuilder<FreeTimeCubit, FreeTimeState>(
      builder: (context, state) {
        if (state is FreeTimeLoading) {
          return const SizedBox(
            height: 160,
            child: Center(child: CircularProgressIndicator()),
          );
        } else if (state is FreeTimeError) {
          return SizedBox(
            height: 160,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    state.message,
                    style: TextStyle(color: Colors.red[700]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: widget.onRefresh,
                    icon: const Icon(Icons.refresh),
                    label: Text(LocaleKeys.buttons_retry.tr()),
                  ),
                ],
              ),
            ),
          );
        } else if (state is FreeTimeLoaded) {
          if (state.times.isEmpty) {
            return SizedBox(
              height: 160,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      LocaleKeys.appointment_not_have_grafic.tr(),
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      LocaleKeys.appointment_not_have_grafic_content.tr(),
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ],
                ),
              ),
            );
          }

          return SizedBox(
            height: 160,
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                // Consume scroll notifications to prevent them from bubbling up
                return true;
              },
              child: ListView.builder(
                itemCount: state.times.length,
                itemBuilder: (context, index) {
                  final timeSlot = state.times[index];
                  final isSelected = widget.selectedTimeSlot == timeSlot;

                  // Format the time for display
                  final startTimeStr =
                      timeSlot.startTime?.substring(0, 5) ?? '';
                  final endTimeStr = timeSlot.endTime?.substring(0, 5) ?? '';

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: InkWell(
                      onTap: () {
                        // Parse the selected time
                        final startParts = startTimeStr.split(':');
                        final endParts = endTimeStr.split(':');

                        final startTime = TimeOfDay(
                          hour: int.parse(startParts[0]),
                          minute: int.parse(startParts[1]),
                        );

                        final endTime = TimeOfDay(
                          hour: int.parse(endParts[0]),
                          minute: int.parse(endParts[1]),
                        );

                        widget.onTimeSelected(timeSlot, startTime, endTime);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? Theme.of(
                                    context,
                                  ).primaryColor.withOpacity(0.1)
                                  : Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color:
                                isSelected
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey[200]!,
                            width: isSelected ? 1.5 : 0.5,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '$startTimeStr - $endTimeStr',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color:
                                        isSelected
                                            ? Theme.of(context).primaryColor
                                            : Colors.black87,
                                  ),
                                ),
                                Text(
                                  _getDurationText(startTimeStr, endTimeStr),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                            if (isSelected)
                              Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  size: 12,
                                  color: Colors.white,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        }

        return SizedBox(
          height: 160,
          child: Center(
            child: Text(
              LocaleKeys.forms_select_date.tr(),
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDurationPicker() {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          // Picker
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                // Consume scroll notifications to prevent them from bubbling up
                return true;
              },
              child: GestureDetector(
                onTap: () {
                  // Absorb tap events to prevent propagation
                },
                child: CupertinoPicker(
                  scrollController: _scrollController,
                  itemExtent: 40,
                  onSelectedItemChanged: (index) {
                    final selectedMinute = widget.minuteOptions[index];
                    widget.onDurationSelected(selectedMinute);
                  },
                  children:
                      widget.minuteOptions.map((minute) {
                        final isSelected = minute == widget.selectedMinute;
                        return Container(
                          alignment: Alignment.center,
                          child: Text(
                            '$minute',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight:
                                  isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                              color:
                                  isSelected
                                      ? Theme.of(context).primaryColor
                                      : Colors.black87,
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getDurationText(String startTimeStr, String endTimeStr) {
    final startParts = startTimeStr.split(':');
    final endParts = endTimeStr.split(':');
    final startDateTime = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
      int.parse(startParts[0]),
      int.parse(startParts[1]),
    );
    final endDateTime = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
      int.parse(endParts[0]),
      int.parse(endParts[1]),
    );
    final duration = endDateTime.difference(startDateTime);
    final minutes = duration.inMinutes;

    if (minutes < 60) {
      return '$minutes min';
    } else {
      final hours = duration.inHours;
      final remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return '${hours}h';
      } else {
        return '${hours}h ${remainingMinutes}m';
      }
    }
  }
}
