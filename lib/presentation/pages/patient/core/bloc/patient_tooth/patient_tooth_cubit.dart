import 'package:dent_app_mobile/core/repo/appointment/appointment_repo.dart';
import 'package:dent_app_mobile/core/utils/format_utils.dart';
import 'package:dent_app_mobile/models/diagnosis/tooth_model.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'patient_tooth_state.dart';

class PatientToothCubit extends Cubit<PatientToothState> {
  PatientToothCubit() : super(PatientToothInitial());

  final IAppointmentRepo _appointmentRepo = AppointmentRepo();

  Future<void> getToothList(int patientId) async {
    emit(PatientToothLoading());
    try {
      final teeth = await _appointmentRepo.getToothList(patientId);
      emit(PatientToothLoaded(teeth: teeth));
    } on DioException catch (e) {
      emit(PatientToothError(message: FormatUtils.formatErrorMessage(e)));
    }
  }
}
