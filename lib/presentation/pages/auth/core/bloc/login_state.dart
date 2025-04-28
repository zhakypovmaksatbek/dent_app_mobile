part of 'login_cubit.dart';

@immutable
sealed class LoginState extends Equatable {
  @override
  List<Object?> get props => [];
}

final class LoginInitial extends LoginState {}

final class LoginLoading extends LoginState {}

final class LoginSuccess extends LoginState {
  final LoginResponseModel user;
  LoginSuccess({required this.user});
}

final class LoginFailure extends LoginState {
  final String error;
  LoginFailure({required this.error});
}
