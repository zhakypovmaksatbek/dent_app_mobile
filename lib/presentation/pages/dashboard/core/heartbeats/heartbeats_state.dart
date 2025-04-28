part of 'heartbeats_cubit.dart';

sealed class HeartbeatsState extends Equatable {
  const HeartbeatsState();

  @override
  List<Object> get props => [];
}

final class HeartbeatsInitial extends HeartbeatsState {}

final class HeartbeatsLoading extends HeartbeatsState {}

final class HeartbeatsLoaded extends HeartbeatsState {
  final HeartbeatsModel heartbeats;

  const HeartbeatsLoaded({required this.heartbeats});
}

final class HeartbeatsError extends HeartbeatsState {
  final String message;

  const HeartbeatsError(this.message);
}
