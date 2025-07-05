part of 'patient_detail_dart_cubit.dart';

sealed class PatientDetailState extends Equatable {
  const PatientDetailState();

  @override
  List<Object> get props => [];
}

final class PatientDetailInitial extends PatientDetailState {}

final class PatientDetailLoading extends PatientDetailState {}

final class PatientDetailLoaded extends PatientDetailState {
  final PatientDetailModel patientDetail;

  const PatientDetailLoaded({required this.patientDetail});
}

final class PatientDetailError extends PatientDetailState {
  final String message;

  const PatientDetailError({required this.message});
}
