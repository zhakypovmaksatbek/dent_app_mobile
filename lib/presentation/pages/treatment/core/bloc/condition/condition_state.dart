part of 'condition_cubit.dart';

sealed class ConditionState extends Equatable {
  const ConditionState();

  @override
  List<Object> get props => [];
}

final class ConditionInitial extends ConditionState {}

final class ConditionLoading extends ConditionState {}

final class ConditionLoaded extends ConditionState {
  final List<ConditionModel> conditions;
  const ConditionLoaded(this.conditions);
}

final class ConditionError extends ConditionState {
  final String message;
  const ConditionError(this.message);
}
