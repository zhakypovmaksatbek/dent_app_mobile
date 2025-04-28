part of 'diagnosis_cubit.dart';

sealed class DiagnosisState extends Equatable {
  const DiagnosisState();

  @override
  List<Object> get props => [];
}

final class DiagnosisInitial extends DiagnosisState {}

final class DiagnosisLoading extends DiagnosisState {}

final class DiagnosisLoaded extends DiagnosisState {
  final DiagnosisPaginationModel diagnosis;
  final bool isRefresh;
  const DiagnosisLoaded({required this.diagnosis, required this.isRefresh});
}

final class DiagnosisError extends DiagnosisState {
  final String message;
  const DiagnosisError({required this.message});
}
