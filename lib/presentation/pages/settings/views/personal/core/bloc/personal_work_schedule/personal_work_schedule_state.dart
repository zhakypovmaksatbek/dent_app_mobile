part of 'personal_work_schedule_cubit.dart';

sealed class PersonalWorkScheduleState extends Equatable {
  const PersonalWorkScheduleState();

  @override
  List<Object> get props => [];
}

final class PersonalWorkScheduleInitial extends PersonalWorkScheduleState {}

final class PersonalWorkScheduleLoading extends PersonalWorkScheduleState {}

final class PersonalWorkScheduleLoaded extends PersonalWorkScheduleState {
  final ScheduleModel schedule;

  const PersonalWorkScheduleLoaded(this.schedule);

  @override
  List<Object> get props => [schedule];
}

final class PersonalWorkScheduleError extends PersonalWorkScheduleState {
  final String message;

  const PersonalWorkScheduleError(this.message);
}
