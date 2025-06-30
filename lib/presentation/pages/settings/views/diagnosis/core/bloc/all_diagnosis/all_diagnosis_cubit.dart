import 'package:dent_app_mobile/core/repo/service/diagnosis_repo.dart';
import 'package:dent_app_mobile/core/utils/format_utils.dart';
import 'package:dent_app_mobile/models/diagnosis/diagnosis_model.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'all_diagnosis_state.dart';

class AllDiagnosisCubit extends Cubit<AllDiagnosisState> {
  AllDiagnosisCubit() : super(AllDiagnosisInitial());

  final DiagnosisRepository _diagnosisRepository = DiagnosisRepository();

  Future<void> getDiagnosisList() async {
    emit(AllDiagnosisLoading());
    try {
      final diagnosisList = await _diagnosisRepository.getDiagnosisList();
      emit(AllDiagnosisLoaded(diagnosisList: diagnosisList));
    } on DioException catch (e) {
      emit(AllDiagnosisError(message: FormatUtils.formatErrorMessage(e)));
    }
  }
}
