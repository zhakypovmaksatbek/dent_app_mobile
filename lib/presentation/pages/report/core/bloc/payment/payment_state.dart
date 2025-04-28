part of 'payment_cubit.dart';

sealed class PaymentState extends Equatable {
  const PaymentState();

  @override
  List<Object> get props => [];
}

final class PaymentInitial extends PaymentState {}

final class PaymentLoading extends PaymentState {}

final class PaymentLoaded extends PaymentState {
  final PaymentReportDataModel paymentReport;
  const PaymentLoaded({required this.paymentReport});
}

final class PaymentError extends PaymentState {
  final String message;
  const PaymentError({required this.message});
}
