import 'package:dent_app_mobile/core/repo/patient/patient_repo.dart';
import 'package:dent_app_mobile/core/utils/format_utils.dart';
import 'package:dent_app_mobile/models/patient/patient_create_model.dart';
import 'package:dent_app_mobile/models/patient/patient_data_model.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'patient_event.dart';
part 'patient_state.dart';

class PatientBloc extends Bloc<PatientEvent, PatientState> {
  final IPatientRepo _patientRepo;
  int _currentPage = 0;
  static const int _pageSize = 10;

  PatientBloc({required IPatientRepo patientRepo})
    : _patientRepo = patientRepo,
      super(PatientInitial()) {
    on<GetPatients>(_onGetPatients);
    on<SearchPatients>(_onSearchPatients);
    on<UpdatePatient>(_onUpdatePatient);
    on<DeletePatient>(_onDeletePatient);
    on<GetPatient>(_onGetPatient);
  }

  Future<void> _onGetPatients(
    GetPatients event,
    Emitter<PatientState> emit,
  ) async {
    try {
      emit(PatientLoading());
      final PatientDataModel patients = await _patientRepo.getPatients(
        event.page,
        event.size,
      );
      _currentPage = event.page;
      emit(
        PatientLoaded(
          patients: patients,
          isLast: patients.last ?? true,
          currentPage: _currentPage,
          isRefresh: event.isRefresh,
        ),
      );
    } on DioException catch (e) {
      emit(PatientError(FormatUtils.formatErrorMessage(e)));
    }
  }

  Future<void> _onSearchPatients(
    SearchPatients event,
    Emitter<PatientState> emit,
  ) async {
    try {
      emit(PatientLoading());
      final patients = await _patientRepo.searchPatients(event.query);
      emit(PatientSearched(patients));
    } on DioException catch (e) {
      emit(PatientError(FormatUtils.formatErrorMessage(e)));
    }
  }

  Future<void> _onUpdatePatient(
    UpdatePatient event,
    Emitter<PatientState> emit,
  ) async {
    try {
      emit(PatientLoading());
      await _patientRepo.updatePatient(event.id, event.patient);
      emit(PatientUpdated());
      // Refresh the list after updating
      add(GetPatients(page: 1, size: _pageSize, isRefresh: true));
    } on DioException catch (e) {
      emit(PatientError(FormatUtils.formatErrorMessage(e)));
    }
  }

  Future<void> _onDeletePatient(
    DeletePatient event,
    Emitter<PatientState> emit,
  ) async {
    try {
      emit(PatientLoading());
      await _patientRepo.deletePatient(event.id);
      emit(PatientDeleted());
      // Refresh the list after deleting
      add(GetPatients(page: 1, size: _pageSize, isRefresh: true));
    } on DioException catch (e) {
      emit(PatientError(FormatUtils.formatErrorMessage(e)));
    }
  }

  Future<void> _onGetPatient(
    GetPatient event,
    Emitter<PatientState> emit,
  ) async {
    try {
      emit(PatientLoading());
      await _patientRepo.getPatient(event.id);
      // Note: This might need to be updated based on your needs
      // Currently it just loads the patient but doesn't emit a specific state
      emit(PatientInitial());
    } on DioException catch (e) {
      emit(PatientError(FormatUtils.formatErrorMessage(e)));
    }
  }
}
