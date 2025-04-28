part of 'service_cubit.dart';

abstract class ServiceState {}

class ServiceInitial extends ServiceState {}

// Servis getirme ile ilgili state'ler
class ServiceLoading extends ServiceState {}

// Servis işlemleri ile ilgili state'ler (save, update, delete)
class ServiceActionLoading extends ServiceState {}

class ServiceActionSuccess extends ServiceState {
  final String message;

  ServiceActionSuccess({required this.message});
}

class ServiceError extends ServiceState {
  final String message;

  ServiceError({required this.message});
}
