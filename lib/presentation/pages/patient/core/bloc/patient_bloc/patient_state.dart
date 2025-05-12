part of 'patient_bloc.dart';

sealed class PatientState extends Equatable {
  const PatientState();

  @override
  List<Object> get props => [];
}

final class PatientInitial extends PatientState {}

final class PatientLoading extends PatientState {}

final class PatientLoaded extends PatientState {
  final PatientDataModel patients;
  final bool isLast;
  final int currentPage;
  final bool isRefresh;

  const PatientLoaded({
    required this.patients,
    required this.isLast,
    required this.currentPage,
    this.isRefresh = false,
  });

  @override
  List<Object> get props => [patients, isLast, currentPage];
}

final class PatientError extends PatientState {
  final String message;

  const PatientError(this.message);

  @override
  List<Object> get props => [message];
}

final class PatientCreated extends PatientState {}

final class PatientUpdated extends PatientState {}

final class PatientDeleted extends PatientState {}

final class PatientSearched extends PatientState {
  final PatientDataModel patients;

  const PatientSearched(this.patients);

  @override
  List<Object> get props => [patients];
}
