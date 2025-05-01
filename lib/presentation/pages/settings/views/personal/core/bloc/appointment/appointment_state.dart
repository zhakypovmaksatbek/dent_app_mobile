part of 'appointment_cubit.dart';

sealed class AppointmentState extends Equatable {
  const AppointmentState();

  @override
  List<Object> get props => [];
}

final class AppointmentInitial extends AppointmentState {}

final class AppointmentLoading extends AppointmentState {}

final class AppointmentLoaded extends AppointmentState {
  final AppointmentModel appointment;
  const AppointmentLoaded({required this.appointment});
}

final class AppointmentError extends AppointmentState {
  final String message;
  const AppointmentError({required this.message});
}

final class AppointmentDeleted extends AppointmentState {}

final class AppointmentUpdated extends AppointmentState {
  final AppointmentModel appointment;
  const AppointmentUpdated({required this.appointment});
}

final class AppointmentCommentUpdated extends AppointmentState {
  final AppointmentModel appointment;
  const AppointmentCommentUpdated({required this.appointment});
}
