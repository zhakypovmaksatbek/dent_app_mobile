import 'package:dent_app_mobile/core/repo/appointment/appointment_repo.dart';
import 'package:dent_app_mobile/core/utils/format_utils.dart';
import 'package:dent_app_mobile/models/patient/patient_short_model.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'search_patient_state.dart';

class SearchPatientCubit extends Cubit<SearchPatientState> {
  SearchPatientCubit() : super(SearchPatientInitial());

  final AppointmentRepo _appointmentRepo = AppointmentRepo();

  Future<List<PatientShortModel>> searchPatients(String? query) async {
    if (query == null || query.trim().isEmpty) {
      emit(SearchPatientLoaded([]));
      return [];
    }

    emit(SearchPatientLoading());
    try {
      final patients = await _appointmentRepo.getPatientShortList(query);
      emit(SearchPatientLoaded(patients));
      return patients;
    } on DioException catch (e) {
      final errorMessage = FormatUtils.formatErrorMessage(e);
      emit(SearchPatientError(errorMessage));
      return [];
    }
  }
}
