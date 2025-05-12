part of 'patient_tooth_cubit.dart';

sealed class PatientToothState extends Equatable {
  const PatientToothState();

  @override
  List<Object> get props => [];
}

final class PatientToothInitial extends PatientToothState {}

final class PatientToothLoading extends PatientToothState {}

final class PatientToothLoaded extends PatientToothState {
  final List<ToothModel> teeth;
  const PatientToothLoaded({required this.teeth});
}

final class PatientToothError extends PatientToothState {
  final String message;
  const PatientToothError({required this.message});
}
