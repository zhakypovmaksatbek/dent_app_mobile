part of 'search_patient_cubit.dart';

sealed class SearchPatientState extends Equatable {
  const SearchPatientState();

  @override
  List<Object> get props => [];
}

final class SearchPatientInitial extends SearchPatientState {}

final class SearchPatientLoading extends SearchPatientState {}

final class SearchPatientLoaded extends SearchPatientState {
  final List<PatientShortModel> patients;
  const SearchPatientLoaded(this.patients);
}

final class SearchPatientError extends SearchPatientState {
  final String message;
  const SearchPatientError(this.message);
}
