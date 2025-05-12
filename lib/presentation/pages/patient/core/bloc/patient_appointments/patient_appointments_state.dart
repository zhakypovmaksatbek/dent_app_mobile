part of 'patient_appointments_cubit.dart';

sealed class PatientAppointmentsState extends Equatable {
  const PatientAppointmentsState();

  @override
  List<Object> get props => [];
}

final class PatientAppointmentsInitial extends PatientAppointmentsState {}

final class PatientAppointmentsLoading extends PatientAppointmentsState {}

final class PatientAppointmentsLoaded extends PatientAppointmentsState {
  final VisitDataModel response;

  const PatientAppointmentsLoaded({required this.response});
}

final class PatientAppointmentsError extends PatientAppointmentsState {
  final String message;

  const PatientAppointmentsError(this.message);
}
