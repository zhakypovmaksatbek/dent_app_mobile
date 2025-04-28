part of 'service_type_cubit.dart';

abstract class ServiceTypeState {}

class ServiceTypeInitial extends ServiceTypeState {}

class ServiceTypeLoading extends ServiceTypeState {}

class ServiceTypeEmpty extends ServiceTypeState {}

class ServiceTypeLoaded extends ServiceTypeState {
  final ServiceTypeModel serviceTypes;

  ServiceTypeLoaded({required this.serviceTypes});
}

class ServiceTypeError extends ServiceTypeState {
  final String message;

  ServiceTypeError({required this.message});
}
