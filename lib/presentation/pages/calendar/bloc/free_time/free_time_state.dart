part of 'free_time_cubit.dart';

sealed class FreeTimeState extends Equatable {
  const FreeTimeState();

  @override
  List<Object> get props => [];
}

final class FreeTimeInitial extends FreeTimeState {}

final class FreeTimeLoading extends FreeTimeState {}

final class FreeTimeLoaded extends FreeTimeState {
  final List<TimeModel> times;
  const FreeTimeLoaded({required this.times});

  @override
  List<Object> get props => [times];
}

final class FreeTimeError extends FreeTimeState {
  final String message;

  @override
  List<Object> get props => [message];
  const FreeTimeError({required this.message});
}
