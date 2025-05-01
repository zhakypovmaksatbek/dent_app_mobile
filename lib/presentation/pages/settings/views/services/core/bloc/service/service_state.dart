part of 'service_cubit.dart';

abstract class ServiceState {}

class ServiceInitial extends ServiceState {}

class ServiceLoading extends ServiceState {}

class ServiceActionLoading extends ServiceState {}

class ServiceActionSuccess extends ServiceState {
  final String message;

  ServiceActionSuccess({required this.message});
}

class ServiceError extends ServiceState {
  final String message;

  ServiceError({required this.message});
}
