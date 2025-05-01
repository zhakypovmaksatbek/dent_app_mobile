import 'package:dent_app_mobile/core/repo/service/diagnosis_repo.dart';
import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
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
      emit(DiagnosisConfigurationError(message: _formatErrorMessage(e)));
    }
  }

  Future<void> updateDiagnosis(int id, String name) async {
    emit(DiagnosisConfigurationLoading());
    try {
      await _diagnosisRepository.updateDiagnosis(id, name);
      emit(DiagnosisConfigurationLoaded());
    } on DioException catch (e) {
      emit(DiagnosisConfigurationError(message: _formatErrorMessage(e)));
    }
  }

  Future<void> deleteDiagnosis(int id) async {
    emit(DiagnosisConfigurationLoading());
    try {
      await _diagnosisRepository.deleteDiagnosis(id);
      emit(DiagnosisConfigurationLoaded());
    } on DioException catch (e) {
      emit(DiagnosisConfigurationError(message: _formatErrorMessage(e)));
    }
  }

  String _formatErrorMessage(DioException e) {
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
