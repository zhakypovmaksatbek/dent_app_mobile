import 'package:auto_route/auto_route.dart';
import 'package:dent_app_mobile/core/constants/app_constants.dart';
import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/models/appointment/calendar_appointment_model.dart';
import 'package:dent_app_mobile/models/appointment/doctor_model.dart';
import 'package:dent_app_mobile/presentation/pages/calendar/bloc/calendar_action/appointment_action_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/calendar/bloc/calendar_appointments/calendar_appointments_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/calendar/bloc/doctor/doctor_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/calendar/services/appointment_dialog_service.dart';
import 'package:dent_app_mobile/presentation/pages/calendar/widgets/appointment_datasource_util.dart';
import 'package:dent_app_mobile/presentation/pages/calendar/widgets/calendar_bottom_sheet.dart';
import 'package:dent_app_mobile/presentation/pages/calendar/widgets/calendar_fixed_section.dart';
import 'package:dent_app_mobile/presentation/pages/calendar/widgets/calendar_view_widget.dart';
import 'package:dent_app_mobile/presentation/widgets/snack_bars/app_snack_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
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
  late final DoctorCubit _doctorCubit;
  final ValueNotifier<List<DoctorModel>> _doctors = ValueNotifier([]);
  final List<DoctorModel> _selectedDoctors = [];

  // Selected date to focus the appointment list
  DateTime _selectedDate = DateTime.now();

  // List of appointments for the selected day
  List<CalendarAppointmentModel> _selectedDayAppointments = [];

  // Cubits for managing calendar data and actions
  final AppointmentActionCubit _appointmentActionCubit =
      AppointmentActionCubit();

  // Draggable sheet controller
  final DraggableScrollableController _draggableController =
      DraggableScrollableController();

  @override
  void initState() {
    super.initState();
    _monthController = CalendarController();
    _doctorCubit = DoctorCubit();
    _doctorCubit.getDoctors();
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
    _doctors.dispose();
    _draggableController.dispose();
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
      userIds:
          _selectedDoctors.isNotEmpty
              ? _selectedDoctors.map((e) => (e.id ?? 0)).toList()
              : null,
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

  // Handle doctor selection changes
  void _handleDoctorSelection(DoctorModel doctor) {
    setState(() {
      // If empty doctor model is passed (from Clear All button)
      if (doctor.id == null) {
        _selectedDoctors.clear();
      }
      // If doctor is already selected, remove it
      else if (_selectedDoctors.contains(doctor)) {
        _selectedDoctors.remove(doctor);
      }
      // Otherwise add the doctor
      else {
        _selectedDoctors.add(doctor);
      }
    });

    _loadAppointmentsForDateRange();
  }

  // Delete appointment with confirmation
  Future<void> _deleteAppointment(CalendarAppointmentModel appointment) async {
    final result = await AppointmentDialogService()
        .showDeleteConfirmationDialog(context, appointment);
    if (result) {
      _appointmentActionCubit.deleteAppointment(appointment.appointmentId!);
    }
  }

  // Create a new appointment
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return BlocProvider.value(
      value: _doctorCubit,
      child: BlocProvider.value(
        value: _appointmentActionCubit,
        child: Scaffold(
          appBar: _buildAppBar(),
          floatingActionButtonLocation: ExpandableFab.location,
          floatingActionButton: _buildExpandableFAB(),
          body: _buildBody(size),
        ),
      ),
    );
  }

  // Build the app bar
  AppBar _buildAppBar() {
    return AppBar(
      title: Text(AppConstants.instance.appName),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadAppointmentsForDateRange,
          tooltip: LocaleKeys.buttons_refresh.tr(),
        ),
      ],
    );
  }

  // Build the expandable floating action button
  Widget _buildExpandableFAB() {
    return ExpandableFab(
      type: ExpandableFabType.up,
      childrenAnimation: ExpandableFabAnimation.none,
      distance: 70,
      overlayStyle: ExpandableFabOverlayStyle(
        color: Colors.white.withValues(alpha: .9),
      ),
      openButtonBuilder: RotateFloatingActionButtonBuilder(
        child: const Icon(Icons.menu),
        fabSize: ExpandableFabSize.regular,
      ),
      closeButtonBuilder: DefaultFloatingActionButtonBuilder(
        child: const Icon(Icons.close),
        fabSize: ExpandableFabSize.small,
      ),
      children: [
        FloatingActionButton.small(
          heroTag: null,
          child: const Icon(Icons.add),
          onPressed: () => _createAppointment(context, _selectedDate),
        ),
        FloatingActionButton.small(
          heroTag: null,
          child: const Icon(Icons.search),
          onPressed: () {},
        ),
      ],
    );
  }

  // Build the main body with BLoC listeners and builders
  Widget _buildBody(Size size) {
    return BlocListener<DoctorCubit, DoctorState>(
      listener: (context, state) {
        if (state is DoctorLoaded) {
          _doctors.value = state.doctors;
        } else if (state is DoctorError) {
          AppSnackBar.showErrorSnackBar(context, state.message);
        }
      },
      child: BlocListener<AppointmentActionCubit, AppointmentActionState>(
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

                return _buildCalendarWithSheet(size, state, calendarDataSource);
              },
            ),
      ),
    );
  }

  // Build the calendar with the draggable sheet
  Widget _buildCalendarWithSheet(
    Size size,
    CalendarAppointmentsState state,
    AppointmentDataSource calendarDataSource,
  ) {
    // Calculate bottom sheet initial size to ensure it's visible but not covering the calendar too much
    const double minChildSize = 0.3;
    const double initialChildSize = 0.45;

    return Stack(
      children: [
        // Main content (fixed part)
        CalendarFixedSection(
          screenSize: size,
          state: state,
          controller: _monthController,
          dataSource: calendarDataSource,
          onSelectionChanged: _onSelectionChanged,
          onViewChanged: _onViewChanged,
        ),

        // Draggable bottom sheet
        DraggableScrollableSheet(
          initialChildSize: initialChildSize,
          minChildSize: minChildSize,
          maxChildSize: 0.85,
          snap: true,
          snapSizes: const [minChildSize, initialChildSize, 0.85],
          controller: _draggableController,
          builder: (context, scrollController) {
            return SafeArea(
              child: CalendarBottomSheet(
                scrollController: scrollController,
                selectedDoctors: _selectedDoctors,
                doctors: _doctors,
                appointments: _selectedDayAppointments,
                selectedDate: _selectedDate,
                onDoctorChanged: _handleDoctorSelection,
                onDeleteAppointment:
                    (appointment) => _deleteAppointment(appointment),
                onCreateAppointment:
                    (date) => _createAppointment(context, date),
              ),
            );
          },
        ),
      ],
    );
  }
}
