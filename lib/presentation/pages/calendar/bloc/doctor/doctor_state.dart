part of 'doctor_cubit.dart';

sealed class DoctorState extends Equatable {
  const DoctorState();

  @override
  List<Object> get props => [];
}

final class DoctorInitial extends DoctorState {}

final class DoctorLoading extends DoctorState {}

final class DoctorLoaded extends DoctorState {
  final List<DoctorModel> doctors;

  const DoctorLoaded({required this.doctors});

  @override
  List<Object> get props => [doctors];
}

final class DoctorError extends DoctorState {
  final String message;

  const DoctorError({required this.message});

  @override
  List<Object> get props => [message];
}
