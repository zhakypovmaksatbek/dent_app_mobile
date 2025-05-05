import 'package:auto_route/auto_route.dart';
import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/models/appointment/calendar_appointment_model.dart';
import 'package:dent_app_mobile/presentation/pages/calendar/bloc/calendar_action/appointment_action_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/calendar/bloc/calendar_appointments/calendar_appointments_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/calendar/services/appointment_dialog_service.dart';
import 'package:dent_app_mobile/presentation/pages/calendar/widgets/appointment_datasource_util.dart';
import 'package:dent_app_mobile/presentation/pages/calendar/widgets/appointment_list_widget.dart';
import 'package:dent_app_mobile/presentation/pages/calendar/widgets/appointment_summary_widget.dart';
import 'package:dent_app_mobile/presentation/pages/calendar/widgets/calendar_view_widget.dart';
import 'package:dent_app_mobile/presentation/widgets/snack_bars/app_snack_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

@RoutePage(name: 'CalendarRoute')
class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  // Controllers for the monthly calendar and appointment list
  late final CalendarController _monthController;

  // Selected date to focus the appointment list
  DateTime _selectedDate = DateTime.now();

  // List of appointments for the selected day
  List<CalendarAppointmentModel> _selectedDayAppointments = [];

  // Cubits for managing calendar data and actions
  final AppointmentActionCubit _appointmentActionCubit =
      AppointmentActionCubit();

  @override
  void initState() {
    super.initState();
    _monthController = CalendarController();

    // Load appointments when the widget initializes (only once)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAppointmentsForDateRange();
    });
  }

  // Make sure we properly close resources
  @override
  void dispose() {
    _monthController.dispose();
    _appointmentActionCubit.close();
    super.dispose();
  }

  // Load appointments for the current month or visible date range
  void _loadAppointmentsForDateRange() {
    // Determine start and end date based on month view
    final DateTime today = _selectedDate;
    final DateTime monthStart = DateTime(today.year, today.month, 1);
    final DateTime monthEnd = DateTime(today.year, today.month + 1, 0);
    if (kDebugMode) {
      print('Loading appointments from $monthStart to $monthEnd');
    }
    // Fetch appointments using the cubit
    context.read<CalendarAppointmentsCubit>().getCalendarAppointments(
      monthStart,
      monthEnd,
    );
  }

  // Callback when a date is selected in month view
  void _onSelectionChanged(CalendarSelectionDetails details) {
    if (details.date != null) {
      setState(() {
        _selectedDate = details.date!;
        _updateSelectedDayAppointments();
      });
    }
  }

  // Update the list of appointments for the selected day
  void _updateSelectedDayAppointments() {
    if (context.read<CalendarAppointmentsCubit>().state
        is CalendarAppointmentsLoaded) {
      final appointments =
          (context.read<CalendarAppointmentsCubit>().state
                  as CalendarAppointmentsLoaded)
              .appointments;

      // Filter appointments for the selected day
      _selectedDayAppointments =
          appointments.where((appointment) {
            if (appointment.startTime != null) {
              final appointmentDate = DateTime.parse(appointment.startTime!);
              return appointmentDate.year == _selectedDate.year &&
                  appointmentDate.month == _selectedDate.month &&
                  appointmentDate.day == _selectedDate.day;
            }
            return false;
          }).toList();
    } else {
      _selectedDayAppointments = [];
    }
  }

  // Callback when month view is changed (navigation)
  void _onViewChanged(ViewChangedDetails details) {
    if (details.visibleDates.isNotEmpty) {
      // Reload appointments for the new visible date range
      final DateTime rangeStart = details.visibleDates.first;
      final DateTime rangeEnd = details.visibleDates.last;

      context.read<CalendarAppointmentsCubit>().getCalendarAppointments(
        rangeStart,
        rangeEnd,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return BlocProvider.value(
      value: _appointmentActionCubit,
      child: Scaffold(
        appBar: AppBar(
          title: Text(LocaleKeys.routes_calendar.tr()),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadAppointmentsForDateRange,
              tooltip: LocaleKeys.buttons_refresh.tr(),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                _createAppointment(context, _selectedDate);
              },
              tooltip: LocaleKeys.buttons_add_appointment.tr(),
            ),
          ],
        ),
        body: BlocListener<AppointmentActionCubit, AppointmentActionState>(
          listener: (context, state) {
            if (state is AppointmentActionSuccess) {
              _loadAppointmentsForDateRange();
              AppSnackBar.showSuccessSnackBar(
                context,
                LocaleKeys.notifications_appointment_updated_successfully.tr(),
              );
            } else if (state is AppointmentActionFailure) {
              AppSnackBar.showErrorSnackBar(context, state.message);
            }
          },
          child:
              BlocBuilder<CalendarAppointmentsCubit, CalendarAppointmentsState>(
                buildWhen: (previous, current) => previous != current,
                builder: (context, state) {
                  // Create data source from loaded appointments
                  final calendarDataSource =
                      state is CalendarAppointmentsLoaded
                          ? AppointmentDataSourceUtil.getAppointmentDataSource(
                            state.appointments,
                          )
                          : AppointmentDataSource([]);

                  // Update selected day appointments when state changes
                  if (state is CalendarAppointmentsLoaded) {
                    _updateSelectedDayAppointments();
                  }

                  return Container(
                    margin: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
                    child: Column(
                      children: [
                        // Summary of appointments at the top
                        AppointmentSummaryWidget(state: state),
                        const SizedBox(height: 8),

                        // Loading indicator when fetching data
                        if (state is CalendarAppointmentsLoading)
                          LinearProgressIndicator(
                            backgroundColor: Colors.grey[200],
                            color: Theme.of(context).primaryColor,
                          ),

                        // Month view calendar
                        CalendarViewWidget(
                          controller: _monthController,
                          dataSource: calendarDataSource,
                          onSelectionChanged: _onSelectionChanged,
                          onViewChanged: _onViewChanged,
                          height: size.height * 0.35,
                        ),

                        const SizedBox(height: 8),

                        // Selected day appointments list
                        Expanded(
                          child: AppointmentListWidget(
                            appointments: _selectedDayAppointments,
                            selectedDate: _selectedDate,
                            onEdit:
                                AppointmentDialogService()
                                    .showEditAppointmentDialog,
                            onDelete: (context, appointment) async {
                              final result = await AppointmentDialogService()
                                  .showDeleteConfirmationDialog(
                                    context,
                                    appointment,
                                  );
                              if (result) {
                                _appointmentActionCubit.deleteAppointment(
                                  appointment.appointmentId!,
                                );
                              }
                            },
                            onTap:
                                AppointmentDialogService()
                                    .showAppointmentDetails,
                            onAddAppointment: (p0, {initialDate}) {
                              _createAppointment(
                                context,
                                initialDate ?? _selectedDate,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
        ),
        // floatingActionButton: FloatingActionButton(
        //   backgroundColor: ColorConstants.primary,
        //   onPressed:
        //       () => AppointmentDialogService.showAddAppointmentDialog(
        //         context,
        //         initialDate: _selectedDate,
        //       ),
        //   child: const Icon(Icons.add, color: Colors.white),
        // ),
      ),
    );
  }

  void _createAppointment(BuildContext context, DateTime currentDate) {
    if (currentDate.isAfter(DateTime.now().subtract(const Duration(days: 1)))) {
      AppointmentDialogService.showAddAppointmentDialog(
        context,
        initialDate: currentDate,
      );
    } else {
      AppSnackBar.showErrorSnackBar(
        context,
        LocaleKeys.notifications_appointment_cannot_be_in_the_past.tr(),
      );
    }
  }
}
