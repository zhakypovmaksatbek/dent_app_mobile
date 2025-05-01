part of 'personal_specialty_cubit.dart';

sealed class PersonalSpecialtyState extends Equatable {
  const PersonalSpecialtyState();

  @override
  List<Object> get props => [];
}

final class PersonalSpecialtyInitial extends PersonalSpecialtyState {}

final class PersonalSpecialtyLoading extends PersonalSpecialtyState {}

final class PersonalSpecialtyLoaded extends PersonalSpecialtyState {
  final List<SpecialtyModel> specialties;
  final List<SpecialtyModel> userSpecialties;

  const PersonalSpecialtyLoaded({
    required this.specialties,
    required this.userSpecialties,
  });

  @override
  List<Object> get props => [specialties, userSpecialties];
}

final class PersonalSpecialtyUpdating extends PersonalSpecialtyState {
  final PersonalSpecialtyState previousState;
  final String actionType; // 'add' or 'delete'
  final List<int> specialtyIds;

  const PersonalSpecialtyUpdating({
    required this.previousState,
    required this.actionType,
    required this.specialtyIds,
  });

  @override
  List<Object> get props => [previousState, actionType, specialtyIds];
}

final class PersonalSpecialtyError extends PersonalSpecialtyState {
  final String message;
  final Object? error;
  final PersonalSpecialtyState? previousState;

  const PersonalSpecialtyError({
    required this.message,
    this.error,
    this.previousState,
  });

  @override
  List<Object> get props => [
    message,
    if (previousState != null) previousState!,
  ];
}
