import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/main.dart';
import 'package:dent_app_mobile/models/appointment/create_appointment_model.dart';
import 'package:dent_app_mobile/models/appointment/room_model.dart';
import 'package:dent_app_mobile/models/appointment/time_model.dart';
import 'package:dent_app_mobile/models/patient/patient_short_model.dart';
import 'package:dent_app_mobile/models/users/user_model.dart';
import 'package:dent_app_mobile/presentation/pages/calendar/bloc/calendar_action/appointment_action_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/calendar/bloc/calendar_appointments/calendar_appointments_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/calendar/bloc/free_time/free_time_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/calendar/bloc/room/room_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/calendar/bloc/search_patient/search_patient_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/calendar/widgets/appointment_dialog_widgets/index.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/personal/core/bloc/personal/personal_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/personal/core/util/appointment_status.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/personal/core/util/record_type.dart';
import 'package:dent_app_mobile/presentation/widgets/snack_bars/app_snack_bar.dart';
import 'package:dent_app_mobile/presentation/widgets/text/app_text.dart';
import 'package:dent_app_mobile/router/app_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddAppointmentDialogWidget extends StatefulWidget {
  final DateTime? initialDate;

  const AddAppointmentDialogWidget({super.key, this.initialDate});

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
  late final PersonalCubit _personalCubit;
  late final AppointmentActionCubit _appointmentActionCubit;
  late final RoomCubit _roomCubit;

  final TextEditingController _patientController = TextEditingController();
  final TextEditingController _doctorController = TextEditingController();
  final FocusNode _patientFocusNode = FocusNode();
  final FocusNode _doctorFocusNode = FocusNode();
  final List<PatientShortModel> _patientSuggestions = [];
  final List<UserModel> _doctorSuggestions = [];

  String? patientName;
  String? doctorName;
  String? description;
  int? patientId;
  int? doctorId;
  RecordType? recordType = RecordType.consultation;
  AppointmentStatus? appointmentStatus = AppointmentStatus.confirmed;
  int? roomId = 1;
  int minute = 30;

  final List<int> _minuteOptions = [30, 40, 50, 60];

  TimeModel? _selectedTimeSlot;
  bool _showNoPatientResults = false;

  final List<RoomModel> _rooms = [];

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialDate ?? DateTime.now();
    startTime = TimeOfDay(hour: selectedDate.hour, minute: 0);
    endTime = TimeOfDay(hour: selectedDate.hour + 1, minute: 0);
    formKey = GlobalKey<FormState>();
    _searchPatientCubit = SearchPatientCubit();
    _freeTimeCubit = FreeTimeCubit();
    _personalCubit = PersonalCubit();
    _appointmentActionCubit = AppointmentActionCubit();
    _roomCubit = RoomCubit();

    // Load rooms when the widget initializes
    _loadRooms();
  }

  void _loadRooms() {
    _roomCubit.getRoomList();
  }

  void _loadFreeTimeSlots() {
    if (doctorId != null) {
      _freeTimeCubit.getFreeTime(doctorId!, selectedDate, minute);
    }
  }

  @override
  void dispose() {
    _searchPatientCubit.close();
    _freeTimeCubit.close();
    _personalCubit.close();
    _patientController.dispose();
    _doctorController.dispose();
    _patientFocusNode.dispose();
    _doctorFocusNode.dispose();
    _appointmentActionCubit.close();
    _roomCubit.close();
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
        BlocProvider<PersonalCubit>(create: (context) => _personalCubit),
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
                      !_rooms.any((room) => room.id == roomId))) {
                roomId = _rooms.first.id;
              }
            });
          }
        },
        child: Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _buildHeader(),
                  const Divider(),
                  _buildDoctorSection(),
                  const SizedBox(height: 16),
                  _buildDurationSection(),
                  const SizedBox(height: 16),
                  _buildPatientSection(),
                  const SizedBox(height: 16),
                  _buildDateSection(),
                  const SizedBox(height: 16),
                  _buildTimeSection(),
                  const SizedBox(height: 16),
                  _buildTypeSection(),
                  const SizedBox(height: 16),
                  _buildStatusSection(),
                  const SizedBox(height: 16),
                  _buildRoomSection(),
                  const SizedBox(height: 16),
                  _buildNotesSection(),
                  const SizedBox(height: 24),
                  _buildSaveButton(),
                  // Add an extra SizedBox to ensure there's room when the keyboard appears
                  SizedBox(
                    height:
                        MediaQuery.of(context).viewInsets.bottom > 0 ? 150 : 16,
                  ),
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
            textType: TextType.header,
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
        SectionTitle(
          number: "1",
          title: LocaleKeys.report_doctor.tr(),
          isActive: true,
        ),
        const SizedBox(height: 8),
        BlocConsumer<PersonalCubit, PersonalState>(
          listener: (context, state) {
            if (state is PersonalLoaded) {
              setState(() {
                _doctorSuggestions.clear();
                _doctorSuggestions.addAll(state.personalData.content ?? []);
              });
            }
          },
          builder: (context, state) {
            return DoctorSearchField(
              controller: _doctorController,
              focusNode: _doctorFocusNode,
              suggestions: _doctorSuggestions,
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
                _personalCubit.emit(PersonalInitial());
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildDurationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          number: "2",
          title: LocaleKeys.appointment_time.tr(),
          isActive: doctorId != null,
        ),
        const SizedBox(height: 8),
        DurationSelector(
          minuteOptions: _minuteOptions,
          selectedMinute: minute,
          enabled: doctorId != null,
          onDurationSelected: (duration) {
            setState(() {
              minute = duration;
              _selectedTimeSlot = null;
            });
            _loadFreeTimeSlots();
          },
        ),
      ],
    );
  }

  Widget _buildPatientSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          number: "3",
          title: LocaleKeys.appointment_patient.tr(),
          isActive: doctorId != null,
        ),
        const SizedBox(height: 8),
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
                _searchPatientCubit.emit(SearchPatientInitial());
              },
              onAddPatient: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      "Add patient functionality will be implemented here",
                    ),
                  ),
                );
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
        SectionTitle(
          number: "4",
          title: LocaleKeys.forms_select_date.tr(),
          isActive: doctorId != null,
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap:
              doctorId == null
                  ? null
                  : () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
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
              labelText: LocaleKeys.forms_select_date.tr(),
              prefixIcon: const Icon(Icons.calendar_today),
              border: const OutlineInputBorder(),
              enabled: doctorId != null,
            ),
            child: Text(
              DateFormat(
                'EEE, MMM d, yyyy',
                context.locale.languageCode,
              ).format(selectedDate),
              style: TextStyle(
                color: doctorId != null ? Colors.black : Colors.grey,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          number: "5",
          title: LocaleKeys.appointment_time.tr(),
          isActive: doctorId != null,
        ),
        const SizedBox(height: 8),
        doctorId == null
            ? const SelectDoctorMessage()
            : TimeSlotSelector(
              selectedTimeSlot: _selectedTimeSlot,
              onTimeSelected: (timeSlot, startTimeOfDay, endTimeOfDay) {
                setState(() {
                  _selectedTimeSlot = timeSlot;
                  startTime = startTimeOfDay;
                  endTime = endTimeOfDay;
                });
              },
              onRefresh: _loadFreeTimeSlots,
            ),
      ],
    );
  }

  Widget _buildTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          number: "6",
          title: LocaleKeys.appointment_appointment_type_label.tr(),
          isActive: doctorId != null && patientId != null,
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<RecordType>(
          decoration: InputDecoration(
            labelText: LocaleKeys.appointment_appointment_type_label.tr(),
            prefixIcon: const Icon(Icons.category),
            border: const OutlineInputBorder(),
            enabled: doctorId != null && patientId != null,
          ),
          value: recordType,
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
        SectionTitle(
          number: "7",
          title: LocaleKeys.appointment_status_label.tr(),
          isActive: doctorId != null && patientId != null,
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<AppointmentStatus>(
          decoration: InputDecoration(
            labelText: LocaleKeys.appointment_status_label.tr(),
            prefixIcon: const Icon(Icons.flag),
            border: const OutlineInputBorder(),
            enabled: doctorId != null && patientId != null,
          ),
          value: appointmentStatus,
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
        SectionTitle(
          number: "8",
          title: LocaleKeys.appointment_room.tr(),
          isActive: doctorId != null && patientId != null,
        ),
        const SizedBox(height: 8),
        _rooms.isEmpty
            ? DropdownButtonFormField<int>(
              decoration: InputDecoration(
                labelText: LocaleKeys.appointment_room.tr(),
                prefixIcon: const Icon(Icons.meeting_room),
                border: const OutlineInputBorder(),
                enabled: doctorId != null && patientId != null,
              ),
              value: roomId,
              items: const [
                DropdownMenuItem(value: 1, child: Text('Room 1')),
                DropdownMenuItem(value: 2, child: Text('Room 2')),
              ],
              onChanged:
                  doctorId != null && patientId != null
                      ? (value) => setState(() => roomId = value)
                      : null,
            )
            : DropdownButtonFormField<int>(
              decoration: InputDecoration(
                labelText: LocaleKeys.appointment_room.tr(),
                prefixIcon: const Icon(Icons.meeting_room),
                border: const OutlineInputBorder(),
                enabled: doctorId != null && patientId != null,
              ),
              value: roomId,
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

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          number: "9",
          title: LocaleKeys.appointment_notes.tr(),
          isActive: doctorId != null && patientId != null,
          isRequired: false,
        ),
        const SizedBox(height: 8),
        TextFormField(
          decoration: InputDecoration(
            labelText: LocaleKeys.appointment_notes.tr(),
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.note),
            enabled: doctorId != null && patientId != null,
          ),
          onTapOutside: (event) => FocusScope.of(context).unfocus(),
          maxLines: 3,
          onChanged: (value) => description = value,
        ),
      ],
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
    );
  }

  Widget _buildSaveButton() {
    final bool canSave =
        doctorId != null && patientId != null && _selectedTimeSlot != null;

    return BlocListener<AppointmentActionCubit, AppointmentActionState>(
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
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          onPressed: canSave ? _saveAppointment : null,
          child: Text(LocaleKeys.buttons_save.tr()),
        ),
      ),
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
