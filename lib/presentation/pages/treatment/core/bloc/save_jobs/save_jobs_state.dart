part of 'save_jobs_cubit.dart';

sealed class SaveJobsState extends Equatable {
  const SaveJobsState();

  @override
  List<Object> get props => [];
}

final class SaveJobsInitial extends SaveJobsState {}

final class SaveJobsLoading extends SaveJobsState {}

final class SaveJobsSuccess extends SaveJobsState {}

final class SaveJobsError extends SaveJobsState {
  final String message;
  const SaveJobsError({required this.message});
}
