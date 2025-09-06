import 'dart:async';
import 'dart:developer';

import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/models/appointment/doctor_model.dart';
import 'package:dent_app_mobile/models/appointment/time_model.dart';
import 'package:dent_app_mobile/models/patient/patient_short_model.dart';
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
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateAppointmentView extends StatefulWidget {
  const CreateAppointmentView({super.key, required this.selectedDate});
  final DateTime selectedDate;
  @override
  State<CreateAppointmentView> createState() => _CreateAppointmentViewState();
}

class _CreateAppointmentViewState extends State<CreateAppointmentView> {
  final ScrollController _scrollController = ScrollController();

  DoctorModel? _selectedDoctor;
  PatientShortModel? _selectedPatient;
  DateTime? _selectedDate;
  TimeModel? _selectedTimeSlot;
  Timer? _roomLoadDebounceTimer;
  AppointmentStatus _selectedAppointmentStatus = AppointmentStatus.notConfirmed;
  RecordType? _selectedRecordType;

  bool get _isStep1Complete => _selectedDoctor != null;

  /// Adım 2'nin tamamlandığını belirtir: Tarih, Saat ve Hasta seçilmiş.
  bool get _isStep2Complete =>
      _selectedDate != null &&
      _selectedTimeSlot != null &&
      _selectedPatient != null;

  /// Tüm zorunlu alanların doldurulduğunu ve kaydedilebileceğini belirtir.
  bool get _canSave => _isStep1Complete && _isStep2Complete;
  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate;
  }

  void _clearSelection() {
    setState(() {
      _selectedDoctor = null;
      _selectedPatient = null;
      _selectedTimeSlot = null;
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    log('Doctor ID: ${_selectedDoctor?.id}');
    log('Selected Date: $_selectedDate');
    return Scaffold(
      appBar: AppBar(title: Text(LocaleKeys.appointment_new_appointment.tr())),
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
                      DoctorSelectionWidget(
                        scrollController: _scrollController,
                        initialValue: _selectedDoctor,
                        onDoctorSelected: (doctor) {
                          setState(() {
                            _selectedDoctor = doctor;

                            _selectedTimeSlot = null;
                            log('Seçilen doktor: ${doctor.fullName}');
                          });
                          _loadFreeTimeSlots();
                        },
                        onSelectionCleared: () {
                          _clearSelection();
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
                                  _roomLoadDebounceTimer?.cancel();
                                  _selectedTimeSlot = timeSlot;
                                  if (timeSlot != null) {
                                    _roomLoadDebounceTimer = Timer(
                                      const Duration(seconds: 1),
                                      () {
                                        log(
                                          "Debounce süresi doldu, odalar yükleniyor...",
                                        );
                                        _loadRooms();
                                      },
                                    );
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
                              enabled:
                                  _selectedDoctor != null &&
                                  _selectedPatient != null,
                              onAppointmentStatusSelected: (status) {
                                _selectedAppointmentStatus = status!;
                              },
                            ),
                            AppointmentTypeSelection(
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
                                log('Seçilen oda: $room');
                              },
                            ),
                            AppointmentNoteWidget(),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed:
                              (_selectedDoctor != null &&
                                      _selectedDate != null &&
                                      _selectedTimeSlot != null)
                                  ? () {
                                    log('KAYDET BUTONUNA BASILDI:');
                                    log('Doktor: ${_selectedDoctor?.fullName}');
                                    log('Tarih: $_selectedDate');
                                    log(
                                      'Saat: ${_selectedTimeSlot?.startTime}',
                                    );
                                  }
                                  : null,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text(LocaleKeys.buttons_save.tr()),
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
