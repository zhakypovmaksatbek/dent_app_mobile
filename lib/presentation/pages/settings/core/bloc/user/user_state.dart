part of 'user_cubit.dart';

sealed class UserState extends Equatable {
  const UserState();

  @override
  List<Object> get props => [];
}

final class UserInitial extends UserState {}

final class UserLoading extends UserState {}

final class UserLoaded extends UserState {
  final UserDetailModel user;

  const UserLoaded({required this.user});

  @override
  List<Object> get props => [user];
}

final class UserError extends UserState {
  final ResponseModel response;

  const UserError({required this.response});

  @override
  List<Object> get props => [response];
}
