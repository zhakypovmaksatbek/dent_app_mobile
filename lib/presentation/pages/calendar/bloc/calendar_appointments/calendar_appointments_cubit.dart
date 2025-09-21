import 'package:dent_app_mobile/core/repo/appointment/appointment_repo.dart';
import 'package:dent_app_mobile/core/utils/format_utils.dart';
import 'package:dent_app_mobile/models/appointment/calendar_appointment_model.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart'; // debugPrint için 'foundation' kullanmak daha iyidir.
import 'package:flutter_bloc/flutter_bloc.dart';

part 'calendar_appointments_state.dart';

class CalendarAppointmentsCubit extends Cubit<CalendarAppointmentsState> {
  CalendarAppointmentsCubit() : super(CalendarAppointmentsInitial());

  final appointmentRepo = AppointmentRepo();

  DateTime? _lastStartDate;
  DateTime? _lastEndDate;
  List<int>? _lastUserIds;

  Future<void> getCalendarAppointments(
    DateTime startDate,
    DateTime endDate, {
    List<int>? userIds,
  }) async {
    _lastStartDate = startDate;
    _lastEndDate = endDate;
    _lastUserIds = userIds;

    await _fetchAppointments();
  }

  Future<void> refreshAppointments() async {
    debugPrint('CalendarAppointmentsCubit: Refreshing appointments...');

    if (_lastStartDate == null || _lastEndDate == null) {
      debugPrint(
        'CalendarAppointmentsCubit: Cannot refresh, no initial data has been loaded.',
      );
      return;
    }

    await _fetchAppointments();
  }

  Future<void> _fetchAppointments() async {
    if (_lastStartDate == null || _lastEndDate == null) return;

    debugPrint(
      'CalendarAppointmentsCubit: Loading appointments from $_lastStartDate to $_lastEndDate',
    );
    emit(CalendarAppointmentsLoading());
    try {
      final appointments = await appointmentRepo.getCalendarAppointments(
        startDate: _lastStartDate!,
        endDate: _lastEndDate!,
        userIds: _lastUserIds,
      );
      debugPrint(
        'CalendarAppointmentsCubit: Loaded ${appointments.length} appointments',
      );
      if (appointments.isNotEmpty) {
        debugPrint(
          'CalendarAppointmentsCubit: First appointment: ${appointments.first.patientFirsName} ${appointments.first.patientLastName}, Start: ${appointments.first.startTime}',
        );
      }
      emit(CalendarAppointmentsLoaded(appointments: appointments));
    } on DioException catch (e) {
      debugPrint(
        'CalendarAppointmentsCubit: Error loading appointments: ${e.message}',
      );
      emit(
        CalendarAppointmentsError(message: FormatUtils.formatErrorMessage(e)),
      );
    } catch (e) {
      debugPrint('CalendarAppointmentsCubit: Unexpected error: $e');
      emit(CalendarAppointmentsError(message: e.toString()));
    }
  }
}
