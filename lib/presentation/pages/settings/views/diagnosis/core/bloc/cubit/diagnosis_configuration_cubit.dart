import 'package:dent_app_mobile/core/repo/service/diagnosis_repo.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'diagnosis_configuration_state.dart';

class DiagnosisConfigurationCubit extends Cubit<DiagnosisConfigurationState> {
  DiagnosisConfigurationCubit() : super(DiagnosisConfigurationInitial());

  final DiagnosisRepository _diagnosisRepository = DiagnosisRepository();

  Future<void> saveDiagnosis(String name) async {
    emit(DiagnosisConfigurationLoading());
    try {
      await _diagnosisRepository.saveDiagnosis(name);
      emit(DiagnosisConfigurationLoaded());
    } on DioException catch (e) {
      emit(DiagnosisConfigurationError(message: e.toString()));
    }
  }

  Future<void> updateDiagnosis(int id, String name) async {
    emit(DiagnosisConfigurationLoading());
    try {
      await _diagnosisRepository.updateDiagnosis(id, name);
      emit(DiagnosisConfigurationLoaded());
    } on DioException catch (e) {
      emit(DiagnosisConfigurationError(message: e.toString()));
    }
  }

  Future<void> deleteDiagnosis(int id) async {
    emit(DiagnosisConfigurationLoading());
    try {
      await _diagnosisRepository.deleteDiagnosis(id);
      emit(DiagnosisConfigurationLoaded());
    } on DioException catch (e) {
      emit(DiagnosisConfigurationError(message: e.toString()));
    }
  }
}
