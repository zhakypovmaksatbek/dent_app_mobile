part of 'create_schedule_cubit.dart';

sealed class CreateScheduleState extends Equatable {
  const CreateScheduleState();

  @override
  List<Object> get props => [];
}

final class CreateScheduleInitial extends CreateScheduleState {}

final class CreateScheduleLoading extends CreateScheduleState {}

final class CreateScheduleSuccess extends CreateScheduleState {
  final ResponseModel response;
  const CreateScheduleSuccess(this.response);
}

final class CreateScheduleError extends CreateScheduleState {
  final String error;
  const CreateScheduleError(this.error);
}
