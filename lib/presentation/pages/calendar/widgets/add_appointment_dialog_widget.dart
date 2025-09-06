import 'dart:async';

import 'package:dent_app_mobile/core/data/app_data_service.dart';
import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/main.dart';
import 'package:dent_app_mobile/models/appointment/create_appointment_model.dart';
import 'package:dent_app_mobile/models/appointment/room_model.dart';
import 'package:dent_app_mobile/models/appointment/time_model.dart';
import 'package:dent_app_mobile/models/patient/patient_short_model.dart';
import 'package:dent_app_mobile/presentation/pages/calendar/bloc/calendar_action/appointment_action_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/calendar/bloc/calendar_appointments/calendar_appointments_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/calendar/bloc/doctor/doctor_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/calendar/bloc/free_time/free_time_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/calendar/bloc/room/room_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/calendar/bloc/search_patient/search_patient_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/calendar/widgets/appointment_dialog_widgets/index.dart';
import 'package:dent_app_mobile/presentation/pages/patient/view/create_patient.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/personal/core/util/appointment_status.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/personal/core/util/record_type.dart';
import 'package:dent_app_mobile/presentation/widgets/loading/loading_widget.dart';
import 'package:dent_app_mobile/presentation/widgets/snack_bars/app_snack_bar.dart';
import 'package:dent_app_mobile/presentation/widgets/text/app_text.dart';
import 'package:dent_app_mobile/router/app_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class AddAppointmentDialogWidget extends StatefulWidget {
  final DateTime? initialDate;
  final bool isAdmin;
  const AddAppointmentDialogWidget({
    super.key,
    this.initialDate,
    required this.isAdmin,
  });

  @override
  State<AddAppointmentDialogWidget> createState() =>
      _AddAppointmentDialogWidgetState();
}

class _AddAppointmentDialogWidgetState
    extends State<AddAppointmentDialogWidget> {
  late DateTime selectedDate;
  late TimeOfDay startTime;
  late TimeOfDay endTime;
  late final GlobalKey<FormState> formKey;
  late final SearchPatientCubit _searchPatientCubit;
  late final FreeTimeCubit _freeTimeCubit;
  late final DoctorCubit _doctorCubit;
  late final AppointmentActionCubit _appointmentActionCubit;
  late final RoomCubit _roomCubit;

  final TextEditingController _patientController = TextEditingController();
  final TextEditingController _doctorController = TextEditingController();
  final FocusNode _patientFocusNode = FocusNode();
  final FocusNode _doctorFocusNode = FocusNode();
  final List<PatientShortModel> _patientSuggestions = [];

  String? patientName;
  String? doctorName;
  String? description;
  int? patientId;
  int? doctorId;
  RecordType? recordType = RecordType.treatment;
  AppointmentStatus? appointmentStatus = AppointmentStatus.notConfirmed;
  int? roomId;
  int minute = 30;

  final List<int> _minuteOptions = [10, 20, 30, 40, 50, 60];

  TimeModel? _selectedTimeSlot;
  bool _showNoPatientResults = false;
  bool _showAdvancedOptions = false;
  String? _pendingPatientName; // Yeni eklenen patient'in tam ismi

  final List<RoomModel> _rooms = [];

  // Timer for debouncing duration selection
  Timer? _durationSelectionTimer;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialDate ?? DateTime.now();
    startTime = TimeOfDay(hour: selectedDate.hour, minute: 0);
    endTime = TimeOfDay(hour: selectedDate.hour + 1, minute: 0);
    formKey = GlobalKey<FormState>();
    _searchPatientCubit = SearchPatientCubit();
    _freeTimeCubit = FreeTimeCubit();
    _doctorCubit = DoctorCubit();
    _appointmentActionCubit = AppointmentActionCubit();
    _roomCubit = RoomCubit();
    _searchPatientCubit.searchPatients(" ");
    _loadRole();
  }

  void _loadRooms() {
    _roomCubit.getRoomListByDate(selectedDate, startTime, endTime);
  }

  void _loadFreeTimeSlots() {
    if (doctorId != null) {
      _freeTimeCubit.getFreeTime(doctorId!, selectedDate, minute);
    }
  }

  Future<void> _loadRole() async {
    if (!widget.isAdmin) {
      final currentUserId = await AppDataService.instance.getUserId();
      if (currentUserId != null) {
        doctorId = currentUserId;
      }
    } else {
      _doctorCubit.getDoctors();
    }
  }

  // Debounced method for loading free time slots
  void _debouncedLoadFreeTimeSlots() {
    _durationSelectionTimer?.cancel();
    _durationSelectionTimer = Timer(const Duration(seconds: 1), () {
      _loadFreeTimeSlots();
    });
  }

  @override
  void dispose() {
    _searchPatientCubit.close();
    _freeTimeCubit.close();
    _doctorCubit.close();
    _patientController.dispose();
    _doctorController.dispose();
    _patientFocusNode.dispose();
    _doctorFocusNode.dispose();
    _appointmentActionCubit.close();
    _roomCubit.close();
    _durationSelectionTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SearchPatientCubit>(
          create: (context) => _searchPatientCubit,
        ),
        BlocProvider<FreeTimeCubit>(create: (context) => _freeTimeCubit),
        BlocProvider<DoctorCubit>(create: (context) => _doctorCubit),
        BlocProvider<AppointmentActionCubit>(
          create: (context) => _appointmentActionCubit,
        ),
        BlocProvider<RoomCubit>(create: (context) => _roomCubit),
      ],
      child: BlocListener<RoomCubit, RoomState>(
        listener: (context, state) {
          if (state is RoomLoaded) {
            setState(() {
              _rooms.clear();
              _rooms.addAll(state.rooms);

              // Set default room to first room in the list if available
              if (_rooms.isNotEmpty &&
                  (roomId == null ||
                      !_rooms.any((room) => room.id == roomId))) {}
            });
          }
        },
        child: Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,

            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 16,
                children: [
                  _buildHeader(),
                  if (widget.isAdmin) _buildDoctorSection(),
                  _buildDateSection(),
                  _buildCombinedTimeAndDurationSection(),

                  _buildPatientSection(),
                  _buildStatusSection(),

                  _buildAdvancedOptionsToggle(),

                  if (_showAdvancedOptions) ...[
                    _buildTypeSection(),
                    _buildRoomSection(),
                  ],
                  _buildNotesSection(),
                  const SizedBox(height: 8),
                  _buildSaveButton(),
                  // Add an extra SizedBox to ensure there's room when the keyboard appears
                  SizedBox(height: MediaQuery.of(context).padding.bottom),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: AppText(
            title: LocaleKeys.appointment_new_appointment.tr(),
            textType: TextType.title,
          ),
        ),
        IconButton.filled(
          icon: const Icon(Icons.close),
          onPressed: () => router.maybePop(),
        ),
      ],
    );
  }

  Widget _buildDoctorSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BlocConsumer<DoctorCubit, DoctorState>(
          listener: (context, state) {
            if (state is DoctorError) {
              // Show error message if needed
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            return DoctorSearchField(
              controller: _doctorController,
              focusNode: _doctorFocusNode,
              doctorId: doctorId,
              onDoctorSelected: (doctor) {
                setState(() {
                  doctorId = doctor.id;
                  doctorName = doctor.fullName;
                  _selectedTimeSlot = null;
                });
                _loadFreeTimeSlots();
              },
              onDoctorCleared: () {
                setState(() {
                  _doctorController.clear();
                  doctorId = null;
                  doctorName = null;
                  _selectedTimeSlot = null;
                });
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildPatientSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BlocConsumer<SearchPatientCubit, SearchPatientState>(
          listener: (context, state) {
            if (state is SearchPatientLoaded) {
              setState(() {
                _showNoPatientResults =
                    state.patients.isEmpty &&
                    _patientController.text.isNotEmpty &&
                    _patientController.text.length >= 2;

                _patientSuggestions.clear();
                _patientSuggestions.addAll(state.patients);

                // Yeni eklenen patient'i otomatik seç
                if (_pendingPatientName != null) {
                  try {
                    // Eşleşen patient'i bul
                    PatientShortModel? matchingPatient;

                    for (final patient in state.patients) {
                      if (patient.fullName != null &&
                          patient.fullName!.trim().toLowerCase() ==
                              _pendingPatientName!.trim().toLowerCase()) {
                        matchingPatient = patient;
                        break;
                      }
                    }

                    if (matchingPatient?.id != null) {
                      patientId = matchingPatient!.id;
                      patientName = matchingPatient.fullName;
                      _patientController.text = matchingPatient.fullName ?? '';
                      _showNoPatientResults = false;
                    }
                  } catch (e) {
                    // Hata durumunda sadece log'la, kullanıcıya hata gösterme
                    debugPrint('Auto-select patient error: $e');
                  }

                  // Pending patient name'i temizle
                  _pendingPatientName = null;
                }
              });
            }
          },
          builder: (context, state) {
            return PatientSearchField(
              controller: _patientController,
              focusNode: _patientFocusNode,
              suggestions: _patientSuggestions,
              patientId: patientId,
              enabled: doctorId != null,
              showNoPatientResults: _showNoPatientResults,
              onPatientSelected: (patient) {
                setState(() {
                  patientId = patient.id;
                  patientName = patient.fullName;
                  _showNoPatientResults = false;
                });
              },
              onPatientCleared: () {
                setState(() {
                  _patientController.clear();
                  patientId = null;
                  patientName = null;
                  _showNoPatientResults = false;
                });
              },
              onAddPatient: () async {
                final result = await showCupertinoModalBottomSheet(
                  context: context,
                  builder:
                      (context) => CreatePatientPage(
                        isEdit: false,

                        patientName: _patientController.text,
                      ),
                );
                if (result != null) {
                  setState(() {
                    final firstWord = result.split(" ")[0];

                    // Yeni eklenen patient'in tam ismini sakla
                    _pendingPatientName = result;

                    _patientController.text = firstWord;
                    context.read<SearchPatientCubit>().searchPatients(
                      firstWord,
                    );
                  });
                }
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildDateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap:
              doctorId == null
                  ? null
                  : () async {
                    // Ensure initialDate is not before firstDate
                    final DateTime today = DateTime.now();
                    final DateTime firstDate = today;
                    final DateTime initialDate =
                        selectedDate.isBefore(today) ? today : selectedDate;

                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: initialDate,
                      firstDate: firstDate,
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null && picked != selectedDate) {
                      setState(() {
                        selectedDate = DateTime(
                          picked.year,
                          picked.month,
                          picked.day,
                          selectedDate.hour,
                          selectedDate.minute,
                        );
                        _selectedTimeSlot = null;
                      });
                      _loadFreeTimeSlots();
                    }
                  },
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: "* ${LocaleKeys.forms_select_date.tr()}",
              prefixIcon: const Icon(Icons.calendar_today),
              border: const OutlineInputBorder(),
              enabled: doctorId != null,
            ),
            child: AppText(
              title: DateFormat(
                'EEE, MMM d, yyyy',
                context.locale.languageCode,
              ).format(selectedDate),
              textType: TextType.body,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCombinedTimeAndDurationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        doctorId == null
            ? const SelectDoctorMessage()
            : CombinedTimeDurationSelector(
              selectedTimeSlot: _selectedTimeSlot,
              onTimeSelected: (timeSlot, startTimeOfDay, endTimeOfDay) {
                setState(() {
                  _selectedTimeSlot = timeSlot;
                  startTime = startTimeOfDay;
                  endTime = endTimeOfDay;
                  _loadRooms();
                });
              },
              onRefresh: _loadFreeTimeSlots,
              minuteOptions: _minuteOptions,
              selectedMinute: minute,
              onDurationSelected: (duration) {
                setState(() {
                  minute = duration;
                  _selectedTimeSlot = null;
                });
                _debouncedLoadFreeTimeSlots();
              },
            ),
      ],
    );
  }

  Widget _buildTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<RecordType>(
          decoration: InputDecoration(
            labelText: LocaleKeys.appointment_appointment_type_label.tr(),
            prefixIcon: const Icon(Icons.category),
            border: const OutlineInputBorder(),
            enabled: doctorId != null && patientId != null,
          ),
          items:
              RecordType.values
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(e.displayName.tr()),
                    ),
                  )
                  .toList(),
          onChanged:
              doctorId != null && patientId != null
                  ? (value) => setState(() => recordType = value)
                  : null,
        ),
      ],
    );
  }

  Widget _buildStatusSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<AppointmentStatus>(
          decoration: InputDecoration(
            labelText: LocaleKeys.appointment_status_label.tr(),
            prefixIcon: const Icon(Icons.flag),
            border: const OutlineInputBorder(),
            enabled: doctorId != null && patientId != null,
          ),
          initialValue: appointmentStatus,
          items:
              AppointmentStatus.values
                  .map(
                    (e) =>
                        DropdownMenuItem(value: e, child: Text(e.label.tr())),
                  )
                  .toList(),
          onChanged:
              doctorId != null && patientId != null
                  ? (value) => setState(() => appointmentStatus = value)
                  : null,
        ),
      ],
    );
  }

  Widget _buildRoomSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _rooms.isEmpty
            ? DropdownButtonFormField<int>(
              decoration: InputDecoration(
                labelText: LocaleKeys.appointment_room.tr(),
                prefixIcon: const Icon(Icons.meeting_room),
                hintText: LocaleKeys.appointment_no_rooms_available.tr(),
                border: const OutlineInputBorder(),
                enabled: doctorId != null && patientId != null,
              ),
              initialValue: roomId,
              items: const [],

              onChanged:
                  doctorId != null && patientId != null
                      ? (value) => setState(() => roomId = value)
                      : null,
            )
            : DropdownButtonFormField<int>(
              decoration: InputDecoration(
                labelText: LocaleKeys.appointment_room.tr(),
                prefixIcon: const Icon(Icons.meeting_room),
                hintText: LocaleKeys.appointment_select_room.tr(),
                border: const OutlineInputBorder(),
                enabled: doctorId != null && patientId != null,
              ),
              initialValue: roomId,
              items:
                  _rooms.map((room) {
                    return DropdownMenuItem<int>(
                      value: room.id,
                      child: Text(room.name ?? 'Unknown Room'),
                    );
                  }).toList(),
              onChanged:
                  doctorId != null && patientId != null
                      ? (value) => setState(() => roomId = value)
                      : null,
            ),
      ],
    );
  }

  Widget _buildAdvancedOptionsToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap:
            doctorId != null && patientId != null
                ? () {
                  setState(() {
                    _showAdvancedOptions = !_showAdvancedOptions;
                  });
                }
                : null,
        child: Row(
          children: [
            Icon(
              _showAdvancedOptions
                  ? Icons.keyboard_arrow_up
                  : Icons.keyboard_arrow_down,
              color:
                  doctorId != null && patientId != null
                      ? Theme.of(context).primaryColor
                      : Colors.grey,
            ),
            const SizedBox(width: 8),
            Text(
              _showAdvancedOptions
                  ? LocaleKeys.appointment_hide_advanced_options.tr()
                  : LocaleKeys.appointment_show_advanced_options.tr(),
              style: TextStyle(
                color:
                    doctorId != null && patientId != null
                        ? Theme.of(context).primaryColor
                        : Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: LocaleKeys.appointment_notes.tr(),
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.note_add_outlined),
        enabled: doctorId != null && patientId != null,
      ),
      onTapOutside: (event) => FocusScope.of(context).unfocus(),
      maxLines: 3,
      minLines: 1,
      onChanged: (value) => description = value,
    );
  }

  // Load appointments for the current month or visible date range
  void _loadAppointmentsForDateRange() {
    // Determine start and end date based on month view
    final DateTime today = DateTime.now();
    final DateTime monthStart = DateTime(today.year, today.month, 1);
    final DateTime monthEnd = DateTime(today.year, today.month + 1, 0);
    if (kDebugMode) {
      print('Loading appointments from $monthStart to $monthEnd');
    }
    // Fetch appointments using the cubit
    context.read<CalendarAppointmentsCubit>().getCalendarAppointments(
      monthStart,
      monthEnd,
      userIds: widget.isAdmin ? null : [doctorId!],
    );
  }

  Widget _buildSaveButton() {
    final bool canSave =
        doctorId != null && patientId != null && _selectedTimeSlot != null;

    return BlocConsumer<AppointmentActionCubit, AppointmentActionState>(
      listener: (context, state) {
        if (state is AppointmentActionSuccess) {
          router.maybePop();
          _loadAppointmentsForDateRange();
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
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: canSave ? _saveAppointment : null,
            child: Text(LocaleKeys.buttons_save.tr()),
          ),
        );
      },
    );
  }

  void _saveAppointment() {
    if (formKey.currentState!.validate() &&
        _selectedTimeSlot != null &&
        doctorId != null &&
        patientId != null) {
      // Create dateTime objects
      final startDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        startTime.hour,
        startTime.minute,
      );

      final endDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        endTime.hour,
        endTime.minute,
      );

      // Create appointment model
      var appointment = CreateAppointmentModel(
        patientId: patientId,
        userId: doctorId,
        startDate: DateFormat('yyyy-MM-dd').format(selectedDate),
        startTime:
            _selectedTimeSlot!.startTime?.substring(0, 5) ??
            DateFormat('HH:mm').format(startDateTime),
        endTime:
            _selectedTimeSlot!.endTime?.substring(0, 5) ??
            DateFormat('HH:mm').format(endDateTime),
        recordType: recordType?.key,
        appointmentStatus: appointmentStatus?.key.toUpperCase(),
        description: description,
        roomId: roomId,
      );

      // Call the cubit to create appointment
      _appointmentActionCubit.createAppointment(appointment);
    }
  }

  final router = getIt<AppRouter>();
}
