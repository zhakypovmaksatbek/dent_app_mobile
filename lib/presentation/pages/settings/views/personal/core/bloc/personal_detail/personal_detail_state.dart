part of 'personal_detail_cubit.dart';

sealed class PersonalDetailState extends Equatable {
  const PersonalDetailState();

  @override
  List<Object> get props => [];
}

final class PersonalDetailInitial extends PersonalDetailState {}

final class PersonalDetailLoading extends PersonalDetailState {}

final class PersonalDetailLoaded extends PersonalDetailState {
  final UserDetailModel user;
  const PersonalDetailLoaded({required this.user});

  @override
  List<Object> get props => [user];
}

final class PersonalDetailError extends PersonalDetailState {
  final String message;
  const PersonalDetailError({required this.message});

  @override
  List<Object> get props => [message];
}
