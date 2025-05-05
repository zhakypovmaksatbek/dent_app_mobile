part of 'appointment_action_cubit.dart';

sealed class AppointmentActionState extends Equatable {
  const AppointmentActionState();

  @override
  List<Object> get props => [];
}

final class AppointmentActionInitial extends AppointmentActionState {}

final class AppointmentActionLoading extends AppointmentActionState {}

final class AppointmentActionSuccess extends AppointmentActionState {}

final class AppointmentActionFailure extends AppointmentActionState {
  final String message;

  const AppointmentActionFailure({required this.message});
}
