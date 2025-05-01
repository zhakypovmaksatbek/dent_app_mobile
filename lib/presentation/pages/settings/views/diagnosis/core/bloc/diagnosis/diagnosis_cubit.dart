import 'package:dent_app_mobile/core/repo/service/diagnosis_repo.dart';
import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/models/diagnosis/diagnosis_model.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'diagnosis_state.dart';

class DiagnosisCubit extends Cubit<DiagnosisState> {
  DiagnosisCubit() : super(DiagnosisInitial());

  final DiagnosisRepository _diagnosisRepository = DiagnosisRepository();

  Future<void> getDiagnosis(int page, {bool isRefresh = false}) async {
    emit(DiagnosisLoading());
    try {
      final diagnosis = await _diagnosisRepository.getDiagnosis(page);
      emit(DiagnosisLoaded(diagnosis: diagnosis, isRefresh: isRefresh));
    } on DioException catch (e) {
      emit(DiagnosisError(message: _formatErrorMessage(e)));
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
