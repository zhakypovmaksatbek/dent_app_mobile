part of 'settings_cubit.dart';

sealed class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object> get props => [];
}

final class SettingsInitial extends SettingsState {}

final class SettingsLoading extends SettingsState {}

final class SettingsSuccess extends SettingsState {
  final ClinicModel clinic;

  const SettingsSuccess({required this.clinic});

  @override
  List<Object> get props => [clinic];
}

final class SettingsError extends SettingsState {
  final String error;

  const SettingsError({required this.error});

  @override
  List<Object> get props => [error];
}
