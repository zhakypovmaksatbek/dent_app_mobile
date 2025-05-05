import 'package:dent_app_mobile/core/repo/appointment/appointment_repo.dart';
import 'package:dent_app_mobile/core/utils/format_utils.dart';
import 'package:dent_app_mobile/models/appointment/create_appointment_model.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'appointment_action_state.dart';

class AppointmentActionCubit extends Cubit<AppointmentActionState> {
  AppointmentActionCubit() : super(AppointmentActionInitial());

  final AppointmentRepo _appointmentRepo = AppointmentRepo();

  Future<void> createAppointment(CreateAppointmentModel appointment) async {
    emit(AppointmentActionLoading());
    try {
      await _appointmentRepo.createAppointment(appointment);
      emit(AppointmentActionSuccess());
    } on DioException catch (e) {
      emit(
        AppointmentActionFailure(message: FormatUtils.formatErrorMessage(e)),
      );
    }
  }

  Future<void> updateAppointment(
    int id,
    CreateAppointmentModel appointment,
  ) async {
    emit(AppointmentActionLoading());
    try {
      await _appointmentRepo.updateAppointment(id, appointment);
      emit(AppointmentActionSuccess());
    } on DioException catch (e) {
      emit(
        AppointmentActionFailure(message: FormatUtils.formatErrorMessage(e)),
      );
    }
  }

  Future<void> deleteAppointment(int id) async {
    emit(AppointmentActionLoading());
    try {
      await _appointmentRepo.deleteAppointment(id);
      emit(AppointmentActionSuccess());
    } on DioException catch (e) {
      emit(
        AppointmentActionFailure(message: FormatUtils.formatErrorMessage(e)),
      );
    }
  }
}
