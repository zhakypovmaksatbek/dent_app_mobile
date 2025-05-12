import 'package:dent_app_mobile/presentation/pages/calendar/bloc/calendar_appointments/calendar_appointments_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/calendar/widgets/appointment_summary_widget.dart';
import 'package:dent_app_mobile/presentation/pages/calendar/widgets/calendar_view_widget.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class CalendarFixedSection extends StatelessWidget {
  final Size screenSize;
  final CalendarAppointmentsState state;
  final CalendarController controller;
  final AppointmentDataSource dataSource;
  final Function(CalendarSelectionDetails) onSelectionChanged;
  final Function(ViewChangedDetails) onViewChanged;

  const CalendarFixedSection({
    super.key,
    required this.screenSize,
    required this.state,
    required this.controller,
    required this.dataSource,
    required this.onSelectionChanged,
    required this.onViewChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Container(
        margin: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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

            // Month view calendar - Fixed position
            CalendarViewWidget(
              controller: controller,
              dataSource: dataSource,
              onSelectionChanged: onSelectionChanged,
              onViewChanged: onViewChanged,
              height: screenSize.height * 0.35,
            ),

            // Space below calendar for the sheet - reducing to prevent overflow
            SizedBox(height: screenSize.height * 0.1),
          ],
        ),
      ),
    );
  }
}
