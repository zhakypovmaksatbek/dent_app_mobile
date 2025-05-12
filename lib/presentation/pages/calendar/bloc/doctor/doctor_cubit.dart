import 'package:dent_app_mobile/core/repo/appointment/appointment_repo.dart';
import 'package:dent_app_mobile/core/utils/format_utils.dart';
import 'package:dent_app_mobile/models/appointment/doctor_model.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'doctor_state.dart';

class DoctorCubit extends Cubit<DoctorState> {
  DoctorCubit() : super(DoctorInitial());

  final AppointmentRepo _appointmentRepo = AppointmentRepo();

  Future<void> getDoctors() async {
    emit(DoctorLoading());
    try {
      final doctors = await _appointmentRepo.getDoctorList();
      emit(DoctorLoaded(doctors: doctors));
    } on DioException catch (e) {
      emit(DoctorError(message: FormatUtils.formatErrorMessage(e)));
    }
  }
}
