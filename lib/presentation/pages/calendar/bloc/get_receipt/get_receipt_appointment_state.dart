part of 'get_receipt_appointment_cubit.dart';

sealed class GetReceiptAppointmentState extends Equatable {
  const GetReceiptAppointmentState();

  @override
  List<Object> get props => [];
}

final class GetReceiptAppointmentInitial extends GetReceiptAppointmentState {}

final class GetReceiptAppointmentLoading extends GetReceiptAppointmentState {}

final class GetReceiptAppointmentSuccess extends GetReceiptAppointmentState {
  final ReceiptModel receipt;

  const GetReceiptAppointmentSuccess({required this.receipt});
}

final class GetReceiptAppointmentError extends GetReceiptAppointmentState {
  final String message;

  const GetReceiptAppointmentError({required this.message});
}
