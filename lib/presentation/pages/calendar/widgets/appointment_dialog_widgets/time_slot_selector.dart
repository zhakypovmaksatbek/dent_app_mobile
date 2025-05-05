import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/models/appointment/time_model.dart';
import 'package:dent_app_mobile/presentation/pages/calendar/bloc/free_time/free_time_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TimeSlotSelector extends StatelessWidget {
  final TimeModel? selectedTimeSlot;
  final Function(TimeModel, TimeOfDay, TimeOfDay) onTimeSelected;
  final VoidCallback onRefresh;

  const TimeSlotSelector({
    super.key,
    required this.selectedTimeSlot,
    required this.onTimeSelected,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FreeTimeCubit, FreeTimeState>(
      builder: (context, state) {
        if (state is FreeTimeLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 32.0),
              child: CircularProgressIndicator(),
            ),
          );
        } else if (state is FreeTimeError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Column(
                children: [
                  Text(
                    state.message,
                    style: TextStyle(color: Colors.red[700]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: onRefresh,
                    icon: const Icon(Icons.refresh),
                    label: Text(LocaleKeys.buttons_retry.tr()),
                  ),
                ],
              ),
            ),
          );
        } else if (state is FreeTimeLoaded) {
          if (state.times.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: Column(
                  children: [
                    Text(
                      LocaleKeys.notifications_no_data_found.tr(),
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Try selecting a different date.",
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ],
                ),
              ),
            );
          }

          // Using ListView with iOS-style design
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            height: 110, // Reduced height
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: state.times.length,
              itemBuilder: (context, index) {
                final timeSlot = state.times[index];
                final isSelected = selectedTimeSlot == timeSlot;

                // Format the time for display
                final startTimeStr = timeSlot.startTime?.substring(0, 5) ?? '';
                final endTimeStr = timeSlot.endTime?.substring(0, 5) ?? '';

                return Padding(
                  padding: const EdgeInsets.only(right: 10.0),
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

                      onTimeSelected(timeSlot, startTime, endTime);
                    },
                    child: Container(
                      width: 90, // Smaller width for cards
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? Theme.of(
                                  context,
                                ).primaryColor.withOpacity(0.1)
                                : Colors.grey[50],
                        borderRadius: BorderRadius.circular(
                          12,
                        ), // More rounded corners (iOS style)
                        border: Border.all(
                          color:
                              isSelected
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey[200]!,
                          width:
                              isSelected
                                  ? 1.5
                                  : 0.5, // Thinner border for iOS feel
                        ),
                        // iOS-style subtle shadow
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                              vertical: 10.0,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  startTimeStr,
                                  style: TextStyle(
                                    fontSize: 16, // Smaller font
                                    fontWeight:
                                        FontWeight
                                            .w500, // Medium weight (iOS style)
                                    color:
                                        isSelected
                                            ? Theme.of(context).primaryColor
                                            : Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  height: 1,
                                  width: 40, // Shorter divider
                                  color: Colors.grey[200],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  endTimeStr,
                                  style: TextStyle(
                                    fontSize: 16, // Smaller font
                                    fontWeight:
                                        FontWeight.w500, // Medium weight
                                    color:
                                        isSelected
                                            ? Theme.of(context).primaryColor
                                            : Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _getDurationText(startTimeStr, endTimeStr),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            Positioned(
                              top: 4,
                              right: 4,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  size: 12, // Smaller check icon
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }

        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Text(
              LocaleKeys.forms_select_date.tr(),
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        );
      },
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
