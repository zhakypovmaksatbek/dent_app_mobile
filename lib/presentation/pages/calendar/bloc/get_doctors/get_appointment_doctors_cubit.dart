import 'package:dent_app_mobile/core/repo/appointment/appointment_repo.dart';
import 'package:dent_app_mobile/core/utils/format_utils.dart';
import 'package:dent_app_mobile/models/appointment/appointment_doctor_model.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'get_appointment_doctors_state.dart';

class GetAppointmentDoctorsCubit extends Cubit<GetAppointmentDoctorsState> {
  GetAppointmentDoctorsCubit() : super(GetAppointmentDoctorsInitial());

  final AppointmentRepo _appointmentRepo = AppointmentRepo();

  Future<void> getAppointmentDoctors(DateTime date) async {
    emit(GetAppointmentDoctorsLoading());
    try {
      final doctors = await _appointmentRepo.getAppointmentDoctors(date);
      emit(GetAppointmentDoctorsLoaded(doctors: doctors));
    } on DioException catch (e) {
      emit(
        GetAppointmentDoctorsError(message: FormatUtils.formatErrorMessage(e)),
      );
    }
  }
}
