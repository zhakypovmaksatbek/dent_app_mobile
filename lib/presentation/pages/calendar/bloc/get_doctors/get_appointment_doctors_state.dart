part of 'get_appointment_doctors_cubit.dart';

sealed class GetAppointmentDoctorsState extends Equatable {
  const GetAppointmentDoctorsState();

  @override
  List<Object> get props => [];
}

final class GetAppointmentDoctorsInitial extends GetAppointmentDoctorsState {}

final class GetAppointmentDoctorsLoading extends GetAppointmentDoctorsState {}

final class GetAppointmentDoctorsLoaded extends GetAppointmentDoctorsState {
  final AppointmentDoctorsPaginationModel doctors;

  const GetAppointmentDoctorsLoaded({required this.doctors});
}

final class GetAppointmentDoctorsError extends GetAppointmentDoctorsState {
  final String message;

  const GetAppointmentDoctorsError({required this.message});
}
