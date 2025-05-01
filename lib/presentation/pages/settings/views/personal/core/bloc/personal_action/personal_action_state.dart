part of 'personal_action_cubit.dart';

sealed class PersonalActionState extends Equatable {
  const PersonalActionState();

  @override
  List<Object> get props => [];
}

final class PersonalActionInitial extends PersonalActionState {}

final class PersonalActionLoading extends PersonalActionState {}

final class PersonalActionSuccess extends PersonalActionState {}

final class PersonalActionError extends PersonalActionState {
  final String message;

  const PersonalActionError(this.message);

  @override
  List<Object> get props => [message];
}
