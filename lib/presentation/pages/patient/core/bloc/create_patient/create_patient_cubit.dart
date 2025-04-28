import 'package:dent_app_mobile/core/repo/patient/patient_repo.dart';
import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/models/patient/patient_create_model.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
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
      if (e.response?.data is Map<String, dynamic>) {
        emit(
          CreatePatientFailure(
            e.response?.data['message'] ??
                LocaleKeys.errors_something_went_wrong.tr(),
          ),
        );
      } else {
        emit(CreatePatientFailure(LocaleKeys.errors_something_went_wrong.tr()));
      }
    }
  }
}
