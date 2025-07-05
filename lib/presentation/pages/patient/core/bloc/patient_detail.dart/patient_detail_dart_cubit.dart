import 'package:dent_app_mobile/core/repo/patient/patient_repo.dart';
import 'package:dent_app_mobile/core/utils/format_utils.dart';
import 'package:dent_app_mobile/models/patient/patient_detail_model.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'patient_detail_dart_state.dart';

class PatientDetailCubit extends Cubit<PatientDetailState> {
  PatientDetailCubit() : super(PatientDetailInitial());
  final IPatientRepo _patientRepo = PatientRepo();
  Future<void> getPatientDetail(int id) async {
    emit(PatientDetailLoading());
    try {
      final patientDetail = await _patientRepo.getPatientDetail(id);
      emit(PatientDetailLoaded(patientDetail: patientDetail));
    } on DioException catch (e) {
      emit(PatientDetailError(message: FormatUtils.formatErrorMessage(e)));
    }
  }
}
