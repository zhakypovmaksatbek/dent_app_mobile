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
  List<PatientShortModel> _allPatients = [];
  bool _isDataLoaded = false;

  Future<void> _loadAllPatients() async {
    if (_isDataLoaded) return;

    try {
      emit(SearchPatientLoading());
      // Backend'den tüm hasta listesini al (boş query ile)
      _allPatients = await _appointmentRepo.getPatientShortList('');
      _isDataLoaded = true;
    } on DioException catch (e) {
      final errorMessage = FormatUtils.formatErrorMessage(e);
      emit(SearchPatientError(errorMessage));
      _allPatients = [];
    }
  }

  Future<List<PatientShortModel>> searchPatients(String? query) async {
    // Önce tüm hastaları yükle
    await _loadAllPatients();

    if (state is SearchPatientError) {
      return [];
    }

    // Query boş ise tüm listeyi döndür
    if (query == null || query.trim().isEmpty) {
      emit(SearchPatientLoaded(_allPatients));
      return _allPatients;
    }

    // Local filtreleme yap
    final filteredPatients =
        _allPatients.where((patient) {
          final fullName = patient.fullName?.toLowerCase() ?? '';
          final searchQuery = query.toLowerCase().trim();
          return fullName.contains(searchQuery);
        }).toList();

    emit(SearchPatientLoaded(filteredPatients));
    return filteredPatients;
  }

  // Yeni hasta eklendiğinde listeyi güncelle
  void addNewPatient(PatientShortModel patient) {
    _allPatients.add(patient);
    // Mevcut arama sonuçlarını güncelle
    if (state is SearchPatientLoaded) {
      final currentState = state as SearchPatientLoaded;
      final updatedList = [...currentState.patients, patient];
      emit(SearchPatientLoaded(updatedList));
    }
  }

  // Cache'i temizle (gerektiğinde)
  void clearCache() {
    _allPatients = [];
    _isDataLoaded = false;
  }
}
