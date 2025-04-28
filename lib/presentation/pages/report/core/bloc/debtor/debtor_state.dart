part of 'debtor_cubit.dart';

sealed class DebtorState extends Equatable {
  const DebtorState();

  @override
  List<Object> get props => [];
}

final class DebtorInitial extends DebtorState {}

final class DebtorLoading extends DebtorState {}

final class DebtorLoaded extends DebtorState {
  final DebtorDataModel debtorReport;
  const DebtorLoaded({required this.debtorReport});
}

final class DebtorError extends DebtorState {
  final String message;
  const DebtorError({required this.message});
}
