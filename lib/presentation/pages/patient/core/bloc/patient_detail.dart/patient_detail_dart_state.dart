part of 'patient_detail_dart_cubit.dart';

sealed class PatientDetailDartState extends Equatable {
  const PatientDetailDartState();

  @override
  List<Object> get props => [];
}

final class PatientDetailDartInitial extends PatientDetailDartState {}

final class PatientDetailDartLoading extends PatientDetailDartState {}

final class PatientDetailDartLoaded extends PatientDetailDartState {
  final PatientDetailModel patientDetail;

  const PatientDetailDartLoaded({required this.patientDetail});
}

final class PatientDetailDartError extends PatientDetailDartState {
  final String message;

  const PatientDetailDartError({required this.message});
}
