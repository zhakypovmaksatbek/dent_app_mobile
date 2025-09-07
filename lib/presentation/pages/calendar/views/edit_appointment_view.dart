import 'dart:async';
import 'dart:developer';

import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/main.dart';
import 'package:dent_app_mobile/models/appointment/calendar_appointment_model.dart';
import 'package:dent_app_mobile/models/appointment/create_appointment_model.dart';
import 'package:dent_app_mobile/models/appointment/doctor_model.dart';
import 'package:dent_app_mobile/models/appointment/room_model.dart';
import 'package:dent_app_mobile/models/appointment/time_model.dart';
import 'package:dent_app_mobile/models/patient/patient_short_model.dart';
import 'package:dent_app_mobile/presentation/pages/calendar/bloc/calendar_action/appointment_action_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/calendar/bloc/free_time/free_time_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/calendar/bloc/room/room_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/calendar/widgets/appointment_widgets/appointment_date_selection_widget.dart';
import 'package:dent_app_mobile/presentation/pages/calendar/widgets/appointment_widgets/appointment_note_widget.dart';
import 'package:dent_app_mobile/presentation/pages/calendar/widgets/appointment_widgets/appointment_type_selection.dart';
import 'package:dent_app_mobile/presentation/pages/calendar/widgets/appointment_widgets/doctor_selection_widget.dart';
import 'package:dent_app_mobile/presentation/pages/calendar/widgets/appointment_widgets/patient_selection_widget.dart';
import 'package:dent_app_mobile/presentation/pages/calendar/widgets/appointment_widgets/selection_appointment_status.dart';
import 'package:dent_app_mobile/presentation/pages/calendar/widgets/appointment_widgets/selection_room_widget.dart';
import 'package:dent_app_mobile/presentation/pages/calendar/widgets/appointment_widgets/time_selector_widget.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/personal/core/util/appointment_status.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/personal/core/util/record_type.dart';
import 'package:dent_app_mobile/presentation/widgets/loading/loading_widget.dart';
import 'package:dent_app_mobile/presentation/widgets/snack_bars/app_snack_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditAppointmentView extends StatefulWidget {
  const EditAppointmentView({super.key, required this.appointment});
  final CalendarAppointmentModel appointment;
  @override
  State<EditAppointmentView> createState() => _EditAppointmentViewState();
}

class _EditAppointmentViewState extends State<EditAppointmentView> {
  final ScrollController _scrollController = ScrollController();
  late final AppointmentActionCubit _appointmentActionCubit;

  // State'i tutacak değişkenler
  late DoctorModel _selectedDoctor;
  late PatientShortModel _selectedPatient;
  late DateTime _selectedDate;
  TimeModel? _selectedTimeSlot;
  RoomModel? _selectedRoom;
  late AppointmentStatus _selectedAppointmentStatus;
  RecordType? _selectedRecordType;
  String? _description;

  Timer? _roomLoadDebounceTimer;

  @override
  void initState() {
    super.initState();
    _appointmentActionCubit = AppointmentActionCubit();

    _selectedDoctor = DoctorModel(
      fullName: widget.appointment.doctorFirsName ?? '',
      id: widget.appointment.doctorId,
    );
    _selectedPatient = PatientShortModel(
      id: widget.appointment.patientId,
      fullName: widget.appointment.patientFirsName ?? '',
    );
    _selectedDate = DateTime.parse(widget.appointment.startTime ?? '');

    _selectedRoom = RoomModel(
      id: widget.appointment.roomId,
      name: widget.appointment.room,
    );
    _selectedAppointmentStatus = AppointmentStatus.fromKey(
      widget.appointment.appointmentStatus ?? '',
    );
    _selectedRecordType = RecordType.fromString(
      widget.appointment.recordType ?? '',
    );
    _description = widget.appointment.description;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadFreeTimeSlots();
        _loadRooms();
      }
    });
  }

  void _loadRooms() {
    if (_selectedTimeSlot != null) {
      final startTime = parseSimpleTime(_selectedTimeSlot!.startTime ?? '');
      final endTime = parseSimpleTime(_selectedTimeSlot!.endTime ?? '');

      if (startTime != null && endTime != null) {
        context.read<RoomCubit>().getRoomListByDate(
          _selectedDate,
          startTime,
          endTime,
        );
      }
    }
  }

  void _loadFreeTimeSlots() {
    if (_selectedTimeSlot != null) {
      context.read<FreeTimeCubit>().getFreeTime(
        _selectedDoctor.id!,
        _selectedDate,
        calculateDurationInMinutes(
          _selectedTimeSlot?.startTime ?? '',
          _selectedTimeSlot?.endTime ?? '',
        ),
      );
    }
  }

  int calculateDurationInMinutes(String startTimeStr, String endTimeStr) {
    try {
      final DateTime startDateTime = DateTime.parse(startTimeStr);
      final DateTime endDateTime = DateTime.parse(endTimeStr);

      final Duration duration = endDateTime.difference(startDateTime);

      if (duration.isNegative) {
        return 0;
      }

      return duration.inMinutes;
    } catch (e) {
      return 0;
    }
  }

  @override
  void dispose() {
    _roomLoadDebounceTimer?.cancel();
    _scrollController.dispose();
    _appointmentActionCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final duration = calculateDurationInMinutes(
      widget.appointment.startTime ?? '',
      widget.appointment.endTime ?? '',
    );

    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(LocaleKeys.buttons_update.tr())),
      bottomNavigationBar: BottomAppBar(
        color: theme.scaffoldBackgroundColor,
        child: _createButton(),
      ),
      body: BlocProvider(
        create: (context) => FreeTimeCubit(),
        child: SafeArea(
          child: CustomScrollView(
            controller: _scrollController,
            slivers: <Widget>[
              SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 12,
                    children: [
                      AbsorbPointer(
                        absorbing: false,
                        child: DoctorSelectionWidget(
                          scrollController: _scrollController,
                          initialValue: _selectedDoctor,
                          onDoctorSelected: (doctor) {},
                          onSelectionCleared: () {},
                          enabled: false,
                        ),
                      ),

                      AbsorbPointer(
                        absorbing: false,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 12,
                          children: [
                            AppointmentDateSelectionWidget(
                              initialDate: _selectedDate,
                              onDateChanged: (date) {
                                _selectedDate = date;
                                _loadFreeTimeSlots();
                              },
                            ),

                            TimeAndDurationPicker(
                              doctorId: _selectedDoctor.id ?? 0,
                              selectedDate: _selectedDate,
                              initialMinute: duration,
                              onTimeSlotChanged: (timeSlot) {
                                _roomLoadDebounceTimer?.cancel();
                                _selectedRoom = null;
                                _selectedTimeSlot = timeSlot;
                                if (timeSlot != null) {
                                  _roomLoadDebounceTimer = Timer(
                                    const Duration(seconds: 1),
                                    () {
                                      _loadRooms();
                                    },
                                  );
                                }
                              },
                            ),
                            PatientSelectionWidget(
                              initialValue: _selectedPatient,
                              onPatientSelected: (patient) {
                                _selectedPatient = patient;
                                setState(() {});
                              },
                              onSelectionCleared: () {},
                              scrollController: _scrollController,
                              enabled: false,
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 12,
                        children: [
                          SelectionAppointmentStatus(
                            enabled: true,
                            initialValue: _selectedAppointmentStatus,
                            onAppointmentStatusSelected: (status) {
                              _selectedAppointmentStatus = status!;
                            },
                          ),
                          AppointmentTypeSelection(
                            enabled: true,
                            initialValue: _selectedRecordType,
                            onRecordTypeSelected: (recordType) {
                              _selectedRecordType = recordType;
                            },
                          ),

                          SelectionRoomWidget(
                            enabled: true,
                            // initialValue: _selectedRoom,
                            onRoomSelected: (room) {
                              _selectedRoom = room;
                            },
                          ),
                          AppointmentNoteWidget(
                            onNoteChanged: (note) {
                              _description = note;
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  SizedBox _createButton() {
    return SizedBox(
      width: double.infinity,
      child: BlocConsumer<AppointmentActionCubit, AppointmentActionState>(
        bloc: _appointmentActionCubit,
        listener: (context, state) {
          if (state is AppointmentActionSuccess) {
            router.pop(true);
            AppSnackBar.showSuccessSnackBar(
              context,
              LocaleKeys.alerts_operation_successful.tr(),
            );
          } else if (state is AppointmentActionFailure) {
            AppSnackBar.showErrorSnackBar(context, state.message);
          }
        },
        builder: (context, state) {
          if (state is AppointmentActionLoading) {
            return const LoadingWidget();
          }
          return ElevatedButton(
            onPressed: () {
              _appointmentActionCubit.createAppointment(
                CreateAppointmentModel(
                  appointmentStatus:
                      _selectedAppointmentStatus.key.toUpperCase(),
                  recordType: _selectedRecordType?.key,
                  roomId: _selectedRoom?.id,
                  description: _description,
                  userId: _selectedDoctor.id!,
                  patientId: _selectedPatient.id!,
                  startTime:
                      _selectedTimeSlot?.startTime != null
                          ? _selectedTimeSlot!.startTime
                          : parseTime(widget.appointment.startTime ?? ''),
                  endTime:
                      _selectedTimeSlot?.endTime != null
                          ? _selectedTimeSlot!.endTime
                          : parseTime(widget.appointment.endTime ?? ''),
                  startDate: DateFormat('yyyy-MM-dd').format(_selectedDate),
                ),
              );
            },
            child: Text(LocaleKeys.buttons_save.tr()),
          );
        },
      ),
    );
  }

  TimeOfDay? parseSimpleTime(String timeString) {
    try {
      final parts = timeString.split(':');

      final int hour = int.parse(parts[0]);
      final int minute = int.parse(parts[1]);

      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      log('Time parsing error: $e');
      return null;
    }
  }

  String parseTime(String dateTimeString) {
    try {
      final DateTime dateTime = DateTime.parse(dateTimeString);

      final String hour = dateTime.hour.toString().padLeft(2, '0');
      final String minute = dateTime.minute.toString().padLeft(2, '0');
      final String second = dateTime.second.toString().padLeft(2, '0');

      return '$hour:$minute:$second';
    } catch (e) {
      log('Time parsing error: $e');
      return '';
    }
  }
}
