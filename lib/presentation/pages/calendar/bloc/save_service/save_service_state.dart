part of 'save_service_cubit.dart';

sealed class SaveServiceState extends Equatable {
  const SaveServiceState();

  @override
  List<Object> get props => [];
}

final class SaveServiceInitial extends SaveServiceState {}

final class SaveServiceLoading extends SaveServiceState {}

final class SaveServiceSuccess extends SaveServiceState {
  final String message;

  const SaveServiceSuccess({required this.message});

  @override
  List<Object> get props => [message];
}

final class SaveServiceError extends SaveServiceState {
  final String message;

  const SaveServiceError({required this.message});

  @override
  List<Object> get props => [message];
}
