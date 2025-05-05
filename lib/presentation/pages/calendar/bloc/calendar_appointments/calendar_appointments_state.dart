part of 'calendar_appointments_cubit.dart';

sealed class CalendarAppointmentsState extends Equatable {
  const CalendarAppointmentsState();

  @override
  List<Object> get props => [];
}

final class CalendarAppointmentsInitial extends CalendarAppointmentsState {}

final class CalendarAppointmentsLoading extends CalendarAppointmentsState {}

final class CalendarAppointmentsLoaded extends CalendarAppointmentsState {
  final List<CalendarAppointmentModel> appointments;

  const CalendarAppointmentsLoaded({required this.appointments});
}

final class CalendarAppointmentsError extends CalendarAppointmentsState {
  final String message;

  const CalendarAppointmentsError({required this.message});
}
