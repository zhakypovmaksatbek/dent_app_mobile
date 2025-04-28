part of 'report_cubit.dart';

sealed class ReportState extends Equatable {
  const ReportState();

  @override
  List<Object> get props => [];
}

final class ReportInitial extends ReportState {}

final class ReportLoading extends ReportState {}

final class ReportLoaded extends ReportState {
  final ReportModel report;

  const ReportLoaded(this.report);

  @override
  List<Object> get props => [report];
}

final class ReportError extends ReportState {
  final String message;

  const ReportError(this.message);

  @override
  List<Object> get props => [message];
}
