part of 'deposit_cubit.dart';

sealed class DepositState extends Equatable {
  const DepositState();

  @override
  List<Object> get props => [];
}

final class DepositInitial extends DepositState {}

final class DepositLoading extends DepositState {}

final class DepositLoaded extends DepositState {
  final PaymentReportDataModel depositReport;
  const DepositLoaded({required this.depositReport});
}

final class DepositError extends DepositState {
  final String message;
  const DepositError({required this.message});
}
