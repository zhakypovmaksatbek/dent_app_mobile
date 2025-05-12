import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class CalendarViewWidget extends StatelessWidget {
  final CalendarController controller;
  final AppointmentDataSource dataSource;
  final Function(CalendarSelectionDetails) onSelectionChanged;
  final Function(ViewChangedDetails) onViewChanged;
  final double height;

  const CalendarViewWidget({
    super.key,
    required this.controller,
    required this.dataSource,
    required this.onSelectionChanged,
    required this.onViewChanged,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: height,
      child: SfCalendar(
        view: CalendarView.month,

        controller: controller,
        dataSource: dataSource,
        showNavigationArrow: false,
        allowViewNavigation: false,
        showTodayButton: true,
        showDatePickerButton: true,
        firstDayOfWeek: 1, // Monday
        onSelectionChanged: onSelectionChanged,
        onViewChanged: onViewChanged,
        viewNavigationMode: ViewNavigationMode.snap,
        monthViewSettings: const MonthViewSettings(
          appointmentDisplayMode: MonthAppointmentDisplayMode.indicator,
          showAgenda: false,
          navigationDirection: MonthNavigationDirection.vertical,
        ),
        headerStyle: CalendarHeaderStyle(
          textStyle: theme.textTheme.titleMedium,
          textAlign: TextAlign.center,
          backgroundColor: theme.scaffoldBackgroundColor,
        ),
        selectionDecoration: BoxDecoration(
          border: Border.all(color: theme.primaryColor, width: 2),
          borderRadius: BorderRadius.circular(4),
        ),

        headerHeight: 50,
        headerDateFormat: 'MMMM yyyy',
        viewHeaderHeight: 40,
        viewHeaderStyle: const ViewHeaderStyle(
          dateTextStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          dayTextStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

// Takvim için veri kaynağı
class AppointmentDataSource extends CalendarDataSource {
  AppointmentDataSource(List<Appointment> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return appointments![index].startTime;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments![index].endTime;
  }

  @override
  String getSubject(int index) {
    return appointments![index].subject;
  }

  @override
  Color getColor(int index) {
    return appointments![index].color;
  }

  @override
  String? getNotes(int index) {
    return appointments![index].notes;
  }

  @override
  List<Object>? getResourceIds(int index) {
    return appointments![index].resourceIds;
  }
}

// Randevu modeli
class Appointment {
  final DateTime startTime;
  final DateTime endTime;
  final String subject;
  final String? notes;
  final Color color;
  final List<Object>? resourceIds;

  Appointment({
    required this.startTime,
    required this.endTime,
    required this.subject,
    this.notes,
    required this.color,
    this.resourceIds,
  });
}
