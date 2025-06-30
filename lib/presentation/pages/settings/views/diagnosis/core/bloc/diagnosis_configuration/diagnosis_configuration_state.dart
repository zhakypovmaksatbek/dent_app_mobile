part of 'diagnosis_configuration_cubit.dart';

sealed class DiagnosisConfigurationState extends Equatable {
  const DiagnosisConfigurationState();

  @override
  List<Object> get props => [];
}

final class DiagnosisConfigurationInitial extends DiagnosisConfigurationState {}

final class DiagnosisConfigurationLoading extends DiagnosisConfigurationState {}

final class DiagnosisConfigurationLoaded extends DiagnosisConfigurationState {
  const DiagnosisConfigurationLoaded();
}

final class DiagnosisConfigurationError extends DiagnosisConfigurationState {
  final String message;
  const DiagnosisConfigurationError({required this.message});
}
