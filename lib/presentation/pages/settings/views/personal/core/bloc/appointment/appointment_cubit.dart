import 'package:dent_app_mobile/core/repo/appointment/appointment_repo.dart';
import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/models/appointment/appointment_comment_model.dart';
import 'package:dent_app_mobile/models/appointment/appointment_model.dart';
import 'package:dent_app_mobile/models/appointment/create_appointment_model.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'appointment_state.dart';

class AppointmentCubit extends Cubit<AppointmentState> {
  AppointmentCubit() : super(AppointmentInitial());

  final appointmentRepo = AppointmentRepo();

  Future<void> getAppointmentById(int id) async {
    emit(AppointmentLoading());
    try {
      final appointment = await appointmentRepo.getAppointmentById(id);
      emit(AppointmentLoaded(appointment: appointment));
    } on DioException catch (e) {
      emit(AppointmentError(message: _errorMessage(e)));
    }
  }

  Future<void> deleteAppointment(int id) async {
    emit(AppointmentLoading());
    try {
      await appointmentRepo.deleteAppointment(id);
      emit(AppointmentDeleted());
    } on DioException catch (e) {
      emit(AppointmentError(message: _errorMessage(e)));
    }
  }

  Future<void> updateAppointment(
    int id,
    CreateAppointmentModel appointment,
  ) async {
    emit(AppointmentLoading());
    try {
      await appointmentRepo.updateAppointment(id, appointment);
      final updatedAppointment = await appointmentRepo.getAppointmentById(id);
      emit(AppointmentLoaded(appointment: updatedAppointment));
    } on DioException catch (e) {
      emit(AppointmentError(message: _errorMessage(e)));
    }
  }

  Future<void> updateAppointmentComment(
    int id,
    AppointmentCommentModel comment,
  ) async {
    emit(AppointmentLoading());
    try {
      await appointmentRepo.updateAppointmentComment(id, comment);
      final updatedAppointment = await appointmentRepo.getAppointmentById(id);
      emit(AppointmentLoaded(appointment: updatedAppointment));
    } on DioException catch (e) {
      emit(AppointmentError(message: _errorMessage(e)));
    }
  }

  String _errorMessage(DioException e) {
    String message = LocaleKeys.errors_something_went_wrong.tr();
    if (e.response?.data is Map<String, dynamic>) {
      final data = e.response?.data as Map<String, dynamic>;
      if (data.containsKey('message')) {
        message = data['message'];
      }
    }
    return message;
  }
}
