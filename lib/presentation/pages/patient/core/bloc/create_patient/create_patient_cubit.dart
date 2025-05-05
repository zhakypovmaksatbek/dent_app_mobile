import 'package:dent_app_mobile/core/repo/patient/patient_repo.dart';
import 'package:dent_app_mobile/core/utils/format_utils.dart';
import 'package:dent_app_mobile/models/patient/patient_create_model.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'create_patient_state.dart';

class CreatePatientCubit extends Cubit<CreatePatientState> {
  CreatePatientCubit() : super(CreatePatientInitial());

  final PatientRepo _patientRepository = PatientRepo();

  Future<void> createPatient(PatientCreateModel patient) async {
    emit(CreatePatientLoading());
    try {
      await _patientRepository.createPatient(patient);
      emit(CreatePatientSuccess());
    } on DioException catch (e) {
      emit(CreatePatientFailure(FormatUtils.formatErrorMessage(e)));
    }
  }
}
