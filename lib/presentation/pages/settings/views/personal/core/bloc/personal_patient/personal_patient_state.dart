part of 'personal_patient_cubit.dart';

sealed class PersonalPatientState extends Equatable {
  const PersonalPatientState();

  @override
  List<Object> get props => [];
}

final class PersonalPatientInitial extends PersonalPatientState {}

final class PersonalPatientLoading extends PersonalPatientState {}

final class PersonalPatientLoaded extends PersonalPatientState {
  final VisitDataModel visits;
  final bool isRefresh;
  const PersonalPatientLoaded({required this.visits, required this.isRefresh});
}

final class PersonalPatientError extends PersonalPatientState {
  final String message;
  const PersonalPatientError({required this.message});
}
