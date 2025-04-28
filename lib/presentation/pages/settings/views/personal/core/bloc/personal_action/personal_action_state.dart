part of 'personal_action_cubit.dart';

sealed class PersonalActionState extends Equatable {
  const PersonalActionState();

  @override
  List<Object> get props => [];
}

final class PersonalActionInitial extends PersonalActionState {}
