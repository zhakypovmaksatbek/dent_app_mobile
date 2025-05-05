part of 'room_cubit.dart';

sealed class RoomState extends Equatable {
  const RoomState();

  @override
  List<Object> get props => [];
}

final class RoomInitial extends RoomState {}

final class RoomLoading extends RoomState {}

final class RoomLoaded extends RoomState {
  final List<RoomModel> rooms;
  const RoomLoaded({required this.rooms});
}

final class RoomFailure extends RoomState {
  final String message;
  const RoomFailure({required this.message});
}
