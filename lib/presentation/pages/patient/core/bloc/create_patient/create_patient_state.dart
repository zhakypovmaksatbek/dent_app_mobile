part of 'create_patient_cubit.dart';

sealed class CreatePatientState extends Equatable {
  const CreatePatientState();

  @override
  List<Object> get props => [];
}

final class CreatePatientInitial extends CreatePatientState {}

final class CreatePatientLoading extends CreatePatientState {}

final class CreatePatientSuccess extends CreatePatientState {}

final class CreatePatientFailure extends CreatePatientState {
  final String message;

  const CreatePatientFailure(this.message);

  @override
  List<Object> get props => [message];
}
