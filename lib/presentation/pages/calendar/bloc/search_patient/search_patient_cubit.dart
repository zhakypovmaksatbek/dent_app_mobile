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

  Future<void> searchPatients(String query) async {
    emit(SearchPatientLoading());
    try {
      final patients = await _appointmentRepo.getPatientShortList(query);
      emit(SearchPatientLoaded(patients));
    } on DioException catch (e) {
      emit(SearchPatientError(FormatUtils.formatErrorMessage(e)));
    }
  }
}
