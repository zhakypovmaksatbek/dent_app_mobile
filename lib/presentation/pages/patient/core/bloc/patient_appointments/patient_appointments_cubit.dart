import 'package:dent_app_mobile/core/repo/appointment/appointment_repo.dart';
import 'package:dent_app_mobile/core/utils/format_utils.dart';
import 'package:dent_app_mobile/models/patient/visit_model.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'patient_appointments_state.dart';

class PatientAppointmentsCubit extends Cubit<PatientAppointmentsState> {
  PatientAppointmentsCubit() : super(PatientAppointmentsInitial());

  final IAppointmentRepo _appointmentRepo = AppointmentRepo();

  Future<void> getPatientAppointments(int patientId) async {
    emit(PatientAppointmentsLoading());
    try {
      final response = await _appointmentRepo.getPatientAppointments(
        patientId: patientId,
        page: 1,
      );
      emit(PatientAppointmentsLoaded(response: response));
    } on DioException catch (e) {
      emit(PatientAppointmentsError(FormatUtils.formatErrorMessage(e)));
    }
  }
}
