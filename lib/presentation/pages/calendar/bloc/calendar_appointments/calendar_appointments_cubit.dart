import 'package:dent_app_mobile/core/repo/appointment/appointment_repo.dart';
import 'package:dent_app_mobile/core/utils/format_utils.dart';
import 'package:dent_app_mobile/models/appointment/calendar_appointment_model.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'calendar_appointments_state.dart';

class CalendarAppointmentsCubit extends Cubit<CalendarAppointmentsState> {
  CalendarAppointmentsCubit() : super(CalendarAppointmentsInitial());

  final appointmentRepo = AppointmentRepo();

  Future<void> getCalendarAppointments(
    DateTime startDate,
    DateTime endDate, {
    List<int>? userIds,
  }) async {
    print(
      'CalendarAppointmentsCubit: Loading appointments from $startDate to $endDate',
    );
    emit(CalendarAppointmentsLoading());
    try {
      final appointments = await appointmentRepo.getCalendarAppointments(
        startDate: startDate,
        endDate: endDate,
        userIds: userIds,
      );
      print(
        'CalendarAppointmentsCubit: Loaded ${appointments.length} appointments',
      );
      if (appointments.isNotEmpty) {
        print(
          'CalendarAppointmentsCubit: First appointment: ${appointments.first.patientFirsName} ${appointments.first.patientLastName}, Start: ${appointments.first.startTime}',
        );
      }
      emit(CalendarAppointmentsLoaded(appointments: appointments));
    } on DioException catch (e) {
      print(
        'CalendarAppointmentsCubit: Error loading appointments: ${e.message}',
      );
      emit(
        CalendarAppointmentsError(message: FormatUtils.formatErrorMessage(e)),
      );
    } catch (e) {
      print('CalendarAppointmentsCubit: Unexpected error: $e');
      emit(CalendarAppointmentsError(message: e.toString()));
    }
  }
}
