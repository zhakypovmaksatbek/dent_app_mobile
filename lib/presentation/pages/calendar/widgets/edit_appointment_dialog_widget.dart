import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/main.dart';
import 'package:dent_app_mobile/models/appointment/calendar_appointment_model.dart';
import 'package:dent_app_mobile/models/appointment/create_appointment_model.dart';
import 'package:dent_app_mobile/models/appointment/room_model.dart';
import 'package:dent_app_mobile/models/appointment/time_model.dart';
import 'package:dent_app_mobile/presentation/pages/calendar/bloc/calendar_action/appointment_action_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/calendar/bloc/calendar_appointments/calendar_appointments_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/calendar/bloc/free_time/free_time_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/calendar/bloc/room/room_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/calendar/widgets/appointment_dialog_widgets/index.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/personal/core/util/appointment_status.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/personal/core/util/record_type.dart';
import 'package:dent_app_mobile/presentation/widgets/snack_bars/app_snack_bar.dart';
import 'package:dent_app_mobile/presentation/widgets/text/app_text.dart';
import 'package:dent_app_mobile/router/app_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditAppointmentDialogWidget extends StatefulWidget {
  final CalendarAppointmentModel appointment;

  const EditAppointmentDialogWidget({super.key, required this.appointment});

  @override
  State<EditAppointmentDialogWidget> createState() =>
      _EditAppointmentDialogWidgetState();
}

class _EditAppointmentDialogWidgetState
    extends State<EditAppointmentDialogWidget> {
  late DateTime selectedDate;
  late DateTime originalDate; // Orijinal randevu tarihi
  late TimeOfDay startTime;
  late TimeOfDay endTime;
  late final GlobalKey<FormState> formKey;
  late final RoomCubit _roomCubit;
  late final AppointmentActionCubit _appointmentActionCubit;
  late final FreeTimeCubit _freeTimeCubit;

  String? patientName;
  String? doctorName;
  String? description;
  int? patientId;
  int? doctorId;
  RecordType? recordType;
  AppointmentStatus? appointmentStatus;
  int? roomId;
  int minute = 30; // Default duration for appointments

  TimeModel? _selectedTimeSlot;
  final List<RoomModel> _rooms = [];

  @override
  void initState() {
    super.initState();
    _initializeValues();
    formKey = GlobalKey<FormState>();
    _roomCubit = RoomCubit();
    _appointmentActionCubit = AppointmentActionCubit();
    _freeTimeCubit = FreeTimeCubit();

    // Load rooms when the widget initializes
    _loadRooms();

    // Load free time slots for the current doctor and date with calculated duration
    _calculateDurationAndLoadTimeSlots();
  }

  void _initializeValues() {
    final appointment = widget.appointment;

    // Initialize date and time
    selectedDate =
        appointment.startTime != null
            ? DateTime.parse(appointment.startTime!)
            : DateTime.now();

    // Store the original appointment date for comparisons
    originalDate = selectedDate;

    startTime =
        appointment.startTime != null
            ? TimeOfDay(
              hour: DateTime.parse(appointment.startTime!).hour,
              minute: DateTime.parse(appointment.startTime!).minute,
            )
            : TimeOfDay(hour: DateTime.now().hour, minute: 0);

    endTime =
        appointment.endTime != null
            ? TimeOfDay(
              hour: DateTime.parse(appointment.endTime!).hour,
              minute: DateTime.parse(appointment.endTime!).minute,
            )
            : TimeOfDay(hour: DateTime.now().hour + 1, minute: 0);

    // Calculate appointment duration in minutes
    if (appointment.startTime != null && appointment.endTime != null) {
      final start = DateTime.parse(appointment.startTime!);
      final end = DateTime.parse(appointment.endTime!);
      minute = end.difference(start).inMinutes;

      // Round to nearest 10 minutes
      minute = ((minute + 5) ~/ 10) * 10;

      // Ensure minute is between 30 and 60
      minute = minute.clamp(30, 60);
    }

    // Initialize appointment data
    patientName =
        '${appointment.patientFirsName ?? ''} ${appointment.patientLastName ?? ''}'
            .trim();
    doctorName =
        '${appointment.doctorFirsName ?? ''} ${appointment.doctorLastName ?? ''}'
            .trim();
    description = appointment.description;
    patientId = appointment.patientId;
    doctorId = appointment.doctorId;

    // Use the enum values instead of strings
    recordType = RecordType.values.firstWhere(
      (type) => type.key == appointment.recordType,
      orElse: () => RecordType.consultation,
    );

    appointmentStatus = AppointmentStatus.values.firstWhere(
      (status) =>
          status.key.toLowerCase() ==
          (appointment.appointmentStatus ?? '').toLowerCase(),
      orElse: () => AppointmentStatus.notConfirmed,
    );

    roomId = appointment.roomId ?? 1;
  }

  void _loadRooms() {
    _roomCubit.getRoomList();
  }

  void _calculateDurationAndLoadTimeSlots() {
    // Wait for the next frame to ensure doctorId is set
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (doctorId != null) {
        _loadFreeTimeSlots();
      }
    });
  }

  void _loadFreeTimeSlots() {
    if (doctorId != null) {
      // For appointment editing: if the selected date is today or later,
      // get available times from API, otherwise use original appointment time
      if (selectedDate.isAfter(
        DateTime.now().subtract(const Duration(days: 1)),
      )) {
        _freeTimeCubit.getFreeTime(doctorId!, selectedDate, minute);
      } else {
        // For past appointments, only the original time can be used - return empty list
        _freeTimeCubit.emit(FreeTimeLoaded(times: []));
      }
    }
  }

  @override
  void dispose() {
    _roomCubit.close();
    _appointmentActionCubit.close();
    _freeTimeCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<RoomCubit>(create: (context) => _roomCubit),
        BlocProvider<AppointmentActionCubit>(
          create: (context) => _appointmentActionCubit,
        ),
        BlocProvider<FreeTimeCubit>(create: (context) => _freeTimeCubit),
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
                  _buildPatientSection(),
                  const SizedBox(height: 16),
                  _buildDoctorSection(),
                  const SizedBox(height: 16),
                  _buildDurationSection(),
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
                  _buildActionButtons(),
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
            title: LocaleKeys.buttons_edit.tr(),
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

  Widget _buildPatientSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          number: "1",
          title: LocaleKeys.appointment_patient.tr(),
          isActive: true,
        ),
        const SizedBox(height: 8),
        TextFormField(
          enabled: false, // Can't change patient in edit mode
          initialValue: patientName,
          decoration: InputDecoration(
            labelText: LocaleKeys.appointment_patient.tr(),
            prefixIcon: const Icon(Icons.person),
            border: const OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildDoctorSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          number: "2",
          title: LocaleKeys.report_doctor.tr(),
          isActive: true,
        ),
        const SizedBox(height: 8),
        TextFormField(
          enabled: false, // Can't change doctor in edit mode
          initialValue: doctorName,
          decoration: InputDecoration(
            labelText: LocaleKeys.report_doctor.tr(),
            prefixIcon: const Icon(Icons.medical_services),
            border: const OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildDurationSection() {
    final List<int> minuteOptions = [30, 40, 50, 60];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          number: "3",
          title: LocaleKeys.appointment_time.tr(),
          isActive: true,
        ),
        const SizedBox(height: 8),
        DurationSelector(
          minuteOptions: minuteOptions,
          selectedMinute: minute,
          enabled: true,
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

  Widget _buildDateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          number: "4",
          title: LocaleKeys.forms_select_date.tr(),
          isActive: true,
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            // Tarih seçim ekranı için başlangıç tarihi ayarlama
            // Geçmiş randevuları düzenlerken, orijinal tarih geçmişte olabilir
            // Bu durumda tarih seçimi için ilk tarih olarak geçmiş tarihe izin veriyoruz
            final DateTime firstDate =
                originalDate.isBefore(DateTime.now())
                    ? originalDate.subtract(
                      const Duration(days: 1),
                    ) // Orijinal tarihten bir gün önce
                    : DateTime.now();

            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: selectedDate,
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
              labelText: LocaleKeys.forms_select_date.tr(),
              prefixIcon: const Icon(Icons.calendar_today),
              border: const OutlineInputBorder(),
            ),
            child: Text(
              DateFormat(
                'EEE, MMM d, yyyy',
                context.locale.languageCode,
              ).format(selectedDate),
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
          isActive: true,
        ),
        const SizedBox(height: 8),
        // Special message for past appointment dates
        selectedDate.isBefore(DateTime.now()) && selectedDate != originalDate
            ? Center(
              child: Column(
                children: [
                  Text(
                    LocaleKeys.notifications_appointment_cannot_be_in_the_past
                        .tr(),
                    style: TextStyle(color: Colors.red[700]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    LocaleKeys.forms_select_date.tr(),
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ],
              ),
            )
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
          isActive: true,
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<RecordType>(
          decoration: InputDecoration(
            labelText: LocaleKeys.appointment_appointment_type_label.tr(),
            prefixIcon: const Icon(Icons.category),
            border: const OutlineInputBorder(),
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
          onChanged: (value) => setState(() => recordType = value),
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
          isActive: true,
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<AppointmentStatus>(
          decoration: InputDecoration(
            labelText: LocaleKeys.appointment_status_label.tr(),
            prefixIcon: const Icon(Icons.flag),
            border: const OutlineInputBorder(),
          ),
          value: appointmentStatus,
          items:
              AppointmentStatus.values
                  .map(
                    (e) =>
                        DropdownMenuItem(value: e, child: Text(e.label.tr())),
                  )
                  .toList(),
          onChanged: (value) => setState(() => appointmentStatus = value),
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
          isActive: true,
        ),
        const SizedBox(height: 8),
        _rooms.isEmpty
            ? DropdownButtonFormField<int>(
              decoration: InputDecoration(
                labelText: LocaleKeys.appointment_room.tr(),
                prefixIcon: const Icon(Icons.meeting_room),
                border: const OutlineInputBorder(),
              ),
              value: roomId,
              items: const [
                DropdownMenuItem(value: 1, child: Text('Room 1')),
                DropdownMenuItem(value: 2, child: Text('Room 2')),
              ],
              onChanged: (value) => setState(() => roomId = value),
            )
            : DropdownButtonFormField<int>(
              decoration: InputDecoration(
                labelText: LocaleKeys.appointment_room.tr(),
                prefixIcon: const Icon(Icons.meeting_room),
                border: const OutlineInputBorder(),
              ),
              value: roomId,
              items:
                  _rooms.map((room) {
                    return DropdownMenuItem<int>(
                      value: room.id,
                      child: Text(room.name ?? 'Unknown Room'),
                    );
                  }).toList(),
              onChanged: (value) => setState(() => roomId = value),
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
          isActive: true,
          isRequired: false,
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: description,
          decoration: InputDecoration(
            labelText: LocaleKeys.appointment_notes.tr(),
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.note),
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

  Widget _buildActionButtons() {
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
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: _confirmDelete,
              child: Text(LocaleKeys.buttons_delete.tr()),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: _updateAppointment,
              child: Text(LocaleKeys.buttons_save.tr()),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete() {
    showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(LocaleKeys.appointment_delete_appointment.tr()),
          content: Text(LocaleKeys.appointment_delete_appointment_content.tr()),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(LocaleKeys.buttons_cancel.tr()),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
                _deleteAppointment();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text(LocaleKeys.buttons_delete.tr()),
            ),
          ],
        );
      },
    );
  }

  void _deleteAppointment() {
    final appointmentId = widget.appointment.appointmentId;
    if (appointmentId != null) {
      _appointmentActionCubit.deleteAppointment(appointmentId);
    } else {
      AppSnackBar.showErrorSnackBar(
        context,
        'Could not delete appointment (missing ID)',
      );
    }
  }

  void _updateAppointment() {
    if (formKey.currentState!.validate()) {
      // If user selected a past date and it's not the original appointment date, show warning
      if (selectedDate.isBefore(DateTime.now()) &&
          selectedDate != originalDate) {
        AppSnackBar.showErrorSnackBar(
          context,
          LocaleKeys.notifications_appointment_cannot_be_in_the_past.tr(),
        );
        return;
      }

      // Create dateTime objects for start and end time
      DateTime startDateTime;
      DateTime endDateTime;

      if (_selectedTimeSlot != null) {
        // If a time slot was selected, use its values
        final startTimeStr =
            _selectedTimeSlot!.startTime?.substring(0, 5) ?? '';
        final endTimeStr = _selectedTimeSlot!.endTime?.substring(0, 5) ?? '';

        final startParts = startTimeStr.split(':');
        final endParts = endTimeStr.split(':');

        startDateTime = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          int.parse(startParts[0]),
          int.parse(startParts[1]),
        );

        endDateTime = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          int.parse(endParts[0]),
          int.parse(endParts[1]),
        );
      } else {
        // Otherwise use the manually selected times
        startDateTime = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          startTime.hour,
          startTime.minute,
        );

        endDateTime = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          endTime.hour,
          endTime.minute,
        );
      }

      // Create updated appointment model
      final updatedAppointment = CreateAppointmentModel(
        patientId: patientId,
        userId: doctorId,
        startDate: DateFormat('yyyy-MM-dd').format(selectedDate),
        startTime: DateFormat('HH:mm').format(startDateTime),
        endTime: DateFormat('HH:mm').format(endDateTime),
        recordType: recordType?.key,
        appointmentStatus: appointmentStatus?.key.toUpperCase(),
        description: description,
        roomId: roomId,
      );

      final appointmentId = widget.appointment.appointmentId;
      if (appointmentId != null) {
        _appointmentActionCubit.updateAppointment(
          appointmentId,
          updatedAppointment,
        );
      } else {
        AppSnackBar.showErrorSnackBar(
          context,
          'Could not update appointment (missing ID)',
        );
      }
    }
  }

  final router = getIt<AppRouter>();
}
