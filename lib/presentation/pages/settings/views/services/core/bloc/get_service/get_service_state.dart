part of 'get_service_cubit.dart';

sealed class GetServiceState extends Equatable {
  const GetServiceState();

  @override
  List<Object> get props => [];
}

final class GetServiceInitial extends GetServiceState {}

final class GetServiceLoading extends GetServiceState {}

final class GetServiceLoaded extends GetServiceState {
  final List<ServiceModel> services;
  const GetServiceLoaded({required this.services});
}

final class GetServiceError extends GetServiceState {
  final String message;
  const GetServiceError({required this.message});
}
