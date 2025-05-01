part of 'personal_cubit.dart';

sealed class PersonalState extends Equatable {
  const PersonalState();

  @override
  List<Object> get props => [];
}

final class PersonalInitial extends PersonalState {}

final class PersonalLoading extends PersonalState {}

final class PersonalLoaded extends PersonalState {
  final UserDataModel personalData;
  final bool isRefresh;

  const PersonalLoaded(this.personalData, this.isRefresh);

  @override
  List<Object> get props => [personalData];
}

final class PersonalError extends PersonalState {
  final String message;

  const PersonalError(this.message);

  @override
  List<Object> get props => [message];
}
