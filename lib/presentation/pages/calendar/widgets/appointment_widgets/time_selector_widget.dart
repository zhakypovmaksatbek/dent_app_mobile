import 'dart:async';

import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/models/appointment/time_model.dart';
import 'package:dent_app_mobile/presentation/pages/calendar/bloc/free_time/free_time_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TimeAndDurationPicker extends StatefulWidget {
  final int doctorId;
  final DateTime selectedDate;
  final void Function(TimeModel? timeSlot) onTimeSlotChanged;
  final List<int> minuteOptions;
  final int initialMinute;

  const TimeAndDurationPicker({
    super.key,
    required this.doctorId,
    required this.selectedDate,
    required this.onTimeSlotChanged,
    this.minuteOptions = const [10, 20, 30, 40, 50, 60],
    this.initialMinute = 30,
  });

  @override
  State<TimeAndDurationPicker> createState() => _TimeAndDurationPickerState();
}

class _TimeAndDurationPickerState extends State<TimeAndDurationPicker> {
  late int _selectedMinute;
  TimeModel? _selectedTimeSlot;
  Timer? _durationDebounceTimer;
  Timer? _debounceTimer;
  late FixedExtentScrollController _durationScrollController;
  late FixedExtentScrollController _timeScrollController;

  @override
  void initState() {
    super.initState();
    _selectedMinute = widget.initialMinute;

    final initialDurationIndex = widget.minuteOptions.indexOf(
      widget.initialMinute,
    );
    _durationScrollController = FixedExtentScrollController(
      initialItem: initialDurationIndex >= 0 ? initialDurationIndex : 0,
    );
    _timeScrollController = FixedExtentScrollController(initialItem: 0);

    // _loadFreeTimeSlots();
  }

  @override
  void dispose() {
    _durationScrollController.dispose();
    _timeScrollController.dispose();
    _debounceTimer?.cancel();
    _durationDebounceTimer?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant TimeAndDurationPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.doctorId != oldWidget.doctorId ||
        widget.selectedDate != oldWidget.selectedDate) {
      _resetAndLoad();
    }
  }

  void _onDurationChanged(int newDuration) {
    _durationDebounceTimer?.cancel();

    setState(() {
      _selectedMinute = newDuration;
      _selectedTimeSlot = null;
    });

    widget.onTimeSlotChanged(null);

    _durationDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      _loadFreeTimeSlots();
    });
  }

  void _handleTimeSelection(TimeModel? timeSlot) {
    // Debounce timer'ı sıfırla
    _durationDebounceTimer?.cancel();

    // Kullanıcı kaydırmayı bıraktığında ana widget'ı güncellemek için yeni bir timer başlat.
    _durationDebounceTimer = Timer(const Duration(milliseconds: 400), () {
      // Timer tetiklendiğinde, en son seçilen değeri ana widget'a gönder.
      if (timeSlot != null) {
        widget.onTimeSlotChanged(timeSlot);
      }
    });
  }

  void _loadFreeTimeSlots() {
    context.read<FreeTimeCubit>().getFreeTime(
      widget.doctorId,
      widget.selectedDate,
      _selectedMinute,
    );
  }

  void _resetAndLoad() {
    setState(() {
      _selectedMinute = widget.initialMinute;
      _selectedTimeSlot = null;

      final initialIndex = widget.minuteOptions.indexOf(widget.initialMinute);
      if (_durationScrollController.hasClients) {
        _durationScrollController.jumpToItem(
          initialIndex >= 0 ? initialIndex : 0,
        );
      }
      if (_timeScrollController.hasClients) {
        _timeScrollController.jumpToItem(0);
      }
    });
    widget.onTimeSlotChanged(null);
    _loadFreeTimeSlots();
  }

  void _onTimeSlotSelected(TimeModel timeSlot, {int? index}) {
    _selectedTimeSlot = timeSlot;
    widget.onTimeSlotChanged(timeSlot);

    if (index != null && _timeScrollController.hasClients) {
      _timeScrollController.animateToItem(
        index,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FreeTimeCubit, FreeTimeState>(
      listener: (context, state) {
        if (state is FreeTimeLoaded && state.times.isNotEmpty) {
          _onTimeSlotSelected(state.times.first, index: 0);

          if (_timeScrollController.hasClients) {
            _timeScrollController.animateToItem(
              0,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
            );
          }
        }
      },
      child: SizedBox(
        height: 180,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: _buildTimeSlotsPicker(),
                ),
              ),
              Container(width: 1, color: Theme.of(context).dividerColor),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: _buildDurationPicker(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeSlotsPicker() {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          LocaleKeys.appointment_time.tr(),
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: BlocBuilder<FreeTimeCubit, FreeTimeState>(
            builder: (context, state) {
              if (state is FreeTimeLoading) {
                return const Center(child: CupertinoActivityIndicator());
              } else if (state is FreeTimeError) {
                return Center(
                  child: Text(
                    state.message,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              } else if (state is FreeTimeLoaded) {
                if (state.times.isEmpty) {
                  return Center(
                    child: Text(
                      LocaleKeys.forms_no_free_time_available.tr(),
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                return CupertinoPicker(
                  scrollController: _timeScrollController,
                  itemExtent: 40,
                  onSelectedItemChanged: (index) {
                    final selectedValue = state.times[index];
                    _handleTimeSelection(selectedValue);
                  },

                  children:
                      state.times.map((timeSlot) {
                        final startTimeStr =
                            timeSlot.startTime?.substring(0, 5) ?? '';
                        final endTimeStr =
                            timeSlot.endTime?.substring(0, 5) ?? '';
                        return Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(startTimeStr),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6.0,
                                ),
                                child: Text(
                                  '→',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.5),
                                  ),
                                ),
                              ),
                              Text(
                                endTimeStr,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.7,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDurationPicker() {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          LocaleKeys.general_minutes.tr(),
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: CupertinoPicker(
            scrollController: _durationScrollController,
            itemExtent: 40,
            onSelectedItemChanged: (index) {
              _onDurationChanged(widget.minuteOptions[index]);
            },
            children:
                widget.minuteOptions.map((minute) {
                  final isSelected = minute == _selectedMinute;
                  return Center(
                    child: Text(
                      '$minute',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color:
                            isSelected
                                ? theme.primaryColor
                                : theme.colorScheme.onSurface,
                      ),
                    ),
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }
}
