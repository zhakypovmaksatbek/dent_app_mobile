import 'dart:async';
import 'dart:developer';

import 'package:dent_app_mobile/core/data/app_data_service.dart';
import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/main.dart';
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
import 'package:dent_app_mobile/presentation/pages/settings/views/personal/core/util/roles.dart';
import 'package:dent_app_mobile/presentation/widgets/loading/loading_widget.dart';
import 'package:dent_app_mobile/presentation/widgets/snack_bars/app_snack_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateAppointmentView extends StatefulWidget {
  const CreateAppointmentView({
    super.key,
    required this.selectedDate,
    required this.isAdmin,
  });
  final DateTime selectedDate;
  final bool isAdmin;
  @override
  State<CreateAppointmentView> createState() => _CreateAppointmentViewState();
}

class _CreateAppointmentViewState extends State<CreateAppointmentView> {
  final ScrollController _scrollController = ScrollController();
  late final AppointmentActionCubit _appointmentActionCubit;
  DoctorModel? _selectedDoctor;
  PatientShortModel? _selectedPatient;
  DateTime? _selectedDate;
  TimeModel? _selectedTimeSlot;
  Timer? _roomLoadDebounceTimer;
  AppointmentStatus _selectedAppointmentStatus = AppointmentStatus.notConfirmed;
  RecordType? _selectedRecordType = RecordType.treatment;
  RoomModel? _selectedRoomId;
  String? _description;

  bool get _isStep1Complete => widget.isAdmin ? true : _selectedDoctor != null;

  bool get _isStep2Complete =>
      _selectedDate != null &&
      _selectedTimeSlot != null &&
      _selectedPatient != null;

  bool get _canSave => _isStep1Complete && _isStep2Complete;
  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate;
    _appointmentActionCubit = AppointmentActionCubit();
    _loadRole();
  }

  Future<void> _loadRole() async {
    if (!widget.isAdmin) {
      final currentUserId = await AppDataService.instance.getUserId();
      if (currentUserId != null) {
        _selectedDoctor = DoctorModel(id: currentUserId, fullName: '');
        setState(() {});
      }
    }
  }

  void _clearSelection() {
    setState(() {
      _selectedDoctor = null;
      // _selectedPatient = null;
      _selectedTimeSlot = null;
      // _selectedRoomId = null;
    });
  }

  void _loadRooms() {
    if (_selectedDate != null && _selectedTimeSlot != null) {
      final startTime = parseSimpleTime(_selectedTimeSlot!.startTime ?? '');
      final endTime = parseSimpleTime(_selectedTimeSlot!.endTime ?? '');

      if (startTime != null && endTime != null) {
        context.read<RoomCubit>().getRoomListByDate(
          _selectedDate!,
          startTime,
          endTime,
        );
      }
    }
  }

  void _loadFreeTimeSlots() {
    context.read<FreeTimeCubit>().getFreeTime(
      _selectedDoctor!.id!,
      widget.selectedDate,
      30,
    );
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
    log('Doctor ID: ${_selectedDoctor?.id}');
    log('Selected Date: $_selectedDate');
    log('Selected Patient: ${_selectedPatient?.fullName}');
    log('Selected Patient ID: ${_selectedPatient?.id}');
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(LocaleKeys.appointment_new_appointment.tr())),
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
                      FutureBuilder<Role>(
                        future: AppDataService.instance.getRole(),
                        builder: (context, asyncSnapshot) {
                          if (asyncSnapshot.hasError) {
                            return Center(
                              child: Text('Error: ${asyncSnapshot.error}'),
                            );
                          }
                          final role = asyncSnapshot.data;
                          if (role == Role.admin) {
                            return DoctorSelectionWidget(
                              scrollController: _scrollController,
                              initialValue: _selectedDoctor,
                              onDoctorSelected: (doctor) {
                                setState(() {
                                  _selectedDoctor = doctor;
                                  _selectedTimeSlot = null;
                                  // _selectedRoomId = null;
                                });
                                _loadFreeTimeSlots();
                              },
                              onSelectionCleared: () {
                                _clearSelection();
                              },
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),

                      AbsorbPointer(
                        absorbing: !_isStep1Complete,
                        child: Opacity(
                          opacity: _isStep1Complete ? 1 : 0.5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 12,
                            children: [
                              AppointmentDateSelectionWidget(
                                initialDate: widget.selectedDate,
                                onDateChanged: (date) {
                                  _selectedDate = date;
                                  if (_selectedDoctor != null &&
                                      _selectedDate != null) {
                                    _loadFreeTimeSlots();
                                  }
                                },
                              ),

                              TimeAndDurationPicker(
                                doctorId: _selectedDoctor?.id ?? 0,
                                selectedDate:
                                    _selectedDate ?? widget.selectedDate,
                                onTimeSlotChanged: (timeSlot) {
                                  WidgetsBinding.instance.addPostFrameCallback((
                                    _,
                                  ) {
                                    if (mounted) {
                                      // Widget'ın hala ekranda olduğundan emin ol
                                      setState(() {
                                        _selectedTimeSlot = timeSlot;
                                        _selectedRoomId =
                                            null; // Zaman değiştiği için oda seçimi sıfırlanmalı
                                      });
                                    }
                                  });

                                  _roomLoadDebounceTimer?.cancel();
                                  if (timeSlot != null) {
                                    _roomLoadDebounceTimer = Timer(
                                      const Duration(seconds: 1),
                                      () {
                                        if (mounted) {
                                          _loadRooms();
                                        }
                                      },
                                    );
                                  } else {
                                    if (mounted) {
                                      context.read<RoomCubit>().clearRooms();
                                    }
                                  }
                                },
                              ),

                              PatientSelectionWidget(
                                onPatientSelected: (patient) {
                                  _selectedPatient = patient;
                                  setState(() {});
                                },
                                onSelectionCleared: () {
                                  _selectedPatient = null;
                                },
                                scrollController: _scrollController,
                              ),
                            ],
                          ),
                        ),
                      ),
                      AbsorbPointer(
                        absorbing: !_isStep2Complete,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 12,
                          children: [
                            SelectionAppointmentStatus(
                              initialValue: _selectedAppointmentStatus,
                              enabled:
                                  _selectedDoctor != null &&
                                  _selectedPatient != null,
                              onAppointmentStatusSelected: (status) {
                                _selectedAppointmentStatus = status!;
                              },
                            ),
                            AppointmentTypeSelection(
                              initialValue: _selectedRecordType,
                              enabled:
                                  _selectedDoctor != null &&
                                  _selectedPatient != null,
                              onRecordTypeSelected: (recordType) {
                                _selectedRecordType = recordType;
                              },
                            ),

                            SelectionRoomWidget(
                              enabled: _selectedTimeSlot != null,
                              onRoomSelected: (room) {
                                _selectedRoomId = room;
                              },
                            ),
                            AppointmentNoteWidget(
                              onNoteChanged: (note) {
                                _description = note;
                              },
                            ),
                          ],
                        ),
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
            onPressed:
                _canSave
                    ? () {
                      _appointmentActionCubit.createAppointment(
                        CreateAppointmentModel(
                          appointmentStatus:
                              _selectedAppointmentStatus.key.toUpperCase(),
                          recordType: _selectedRecordType?.key,
                          roomId: _selectedRoomId?.id,
                          description: _description,
                          userId: _selectedDoctor!.id!,
                          patientId: _selectedPatient!.id!,
                          startTime: _selectedTimeSlot!.startTime,
                          endTime: _selectedTimeSlot!.endTime,
                          startDate: DateFormat(
                            'yyyy-MM-dd',
                          ).format(_selectedDate!),
                        ),
                      );
                    }
                    : null,
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
      log('Zaman ayrıştırma hatası: $e');
      return null;
    }
  }
}
