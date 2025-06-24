part of 'pay_appointment_cubit.dart';

sealed class PayAppointmentState extends Equatable {
  const PayAppointmentState();

  @override
  List<Object> get props => [];
}

final class PayAppointmentInitial extends PayAppointmentState {}

final class PayAppointmentLoading extends PayAppointmentState {}

final class PayAppointmentSuccess extends PayAppointmentState {}

final class PayAppointmentError extends PayAppointmentState {
  final String error;

  const PayAppointmentError({required this.error});
}
