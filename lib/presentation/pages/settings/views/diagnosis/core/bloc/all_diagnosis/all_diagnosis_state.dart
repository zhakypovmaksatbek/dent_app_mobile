part of 'all_diagnosis_cubit.dart';

sealed class AllDiagnosisState extends Equatable {
  const AllDiagnosisState();

  @override
  List<Object> get props => [];
}

final class AllDiagnosisInitial extends AllDiagnosisState {}

final class AllDiagnosisLoading extends AllDiagnosisState {}

final class AllDiagnosisLoaded extends AllDiagnosisState {
  final List<DiagnosisModel> diagnosisList;

  const AllDiagnosisLoaded({required this.diagnosisList});

  @override
  List<Object> get props => [diagnosisList];
}

final class AllDiagnosisError extends AllDiagnosisState {
  final String message;

  const AllDiagnosisError({required this.message});

  @override
  List<Object> get props => [message];
}
