import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/models/appointment/calendar_appointment_model.dart';
import 'package:dent_app_mobile/models/appointment/doctor_model.dart';
import 'package:dent_app_mobile/presentation/pages/calendar/services/appointment_dialog_service.dart';
import 'package:dent_app_mobile/presentation/pages/calendar/widgets/appointment_item_widget.dart';
import 'package:dent_app_mobile/presentation/widgets/text/app_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class CalendarBottomSheet extends StatelessWidget {
  final ScrollController scrollController;
  final List<DoctorModel> selectedDoctors;
  final ValueNotifier<List<DoctorModel>> doctors;
  final List<CalendarAppointmentModel> appointments;
  final DateTime selectedDate;
  final Function(DoctorModel) onDoctorChanged;
  final Function(CalendarAppointmentModel) onDeleteAppointment;
  final Function(DateTime) onCreateAppointment;

  const CalendarBottomSheet({
    super.key,
    required this.scrollController,
    required this.selectedDoctors,
    required this.doctors,
    required this.appointments,
    required this.selectedDate,
    required this.onDoctorChanged,
    required this.onDeleteAppointment,
    required this.onCreateAppointment,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 1,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: CustomScrollView(
          physics: const ClampingScrollPhysics(),
          controller: scrollController,
          slivers: [
            // Drag handle
            _buildDragHandle(),

            // Doctor filters section
            _buildDoctorFiltersSection(context),

            // Appointments list
            _buildAppointmentsList(context),

            // Add extra bottom padding for SafeArea
            SliverToBoxAdapter(
              child: SizedBox(
                height:
                    MediaQuery.of(context).padding.bottom > 0
                        ? MediaQuery.of(context).padding.bottom
                        : 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build the drag handle at the top of the sheet
  Widget _buildDragHandle() {
    return SliverToBoxAdapter(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 12.0, bottom: 8.0),
          child: Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(2.5),
            ),
          ),
        ),
      ),
    );
  }

  // Build the doctor filters section
  Widget _buildDoctorFiltersSection(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Doctor dropdown with clear button
            _buildDoctorSelectionRow(context),

            // Selected doctors chips
            if (selectedDoctors.isNotEmpty) _buildSelectedDoctorsChips(context),

            if (selectedDoctors.isNotEmpty) const Divider(height: 1),
          ],
        ),
      ),
    );
  }

  // Build the doctor selection dropdown and clear button
  Widget _buildDoctorSelectionRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ValueListenableBuilder(
            valueListenable: doctors,
            builder: (context, value, child) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButton<DoctorModel>(
                  isExpanded: true,
                  padding: EdgeInsets.zero,
                  underline: const SizedBox(),
                  hint: AppText(
                    title: LocaleKeys.buttons_select_doctor.tr(),
                    textType: TextType.body,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                  value: null,
                  items:
                      value.map((doctor) {
                        final isSelected = selectedDoctors.contains(doctor);
                        return DropdownMenuItem(
                          value: doctor,
                          child: Row(
                            children: [
                              if (isSelected)
                                const Icon(
                                  Icons.check,
                                  size: 16,
                                  color: Colors.green,
                                ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  doctor.fullName ?? "",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color:
                                        isSelected
                                            ? Colors.green
                                            : Colors.black,
                                    fontWeight:
                                        isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                  onChanged: (DoctorModel? newValue) {
                    if (newValue != null) {
                      onDoctorChanged(newValue);
                    }
                  },
                ),
              );
            },
          ),
        ),
        if (selectedDoctors.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.clear_all, size: 20, color: Colors.red),
            onPressed: () => onDoctorChanged(DoctorModel()),
            tooltip: 'Clear All Filters',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
      ],
    );
  }

  // Build the chips showing selected doctors
  Widget _buildSelectedDoctorsChips(BuildContext context) {
    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: selectedDoctors.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final doctor = selectedDoctors[index];
          return Chip(
            labelPadding: const EdgeInsets.symmetric(horizontal: 4),
            padding: EdgeInsets.zero,
            label: Text(
              doctor.fullName ?? '',
              style: const TextStyle(fontSize: 12),
            ),
            deleteIcon: const Icon(Icons.close, size: 14),
            onDeleted: () => onDoctorChanged(doctor),
            backgroundColor: Colors.blue.shade50,
            side: BorderSide(color: Colors.blue.shade200),
            visualDensity: VisualDensity.compact,
          );
        },
      ),
    );
  }

  // Build the appointments list
  Widget _buildAppointmentsList(BuildContext context) {
    return appointments.isEmpty
        ? _buildEmptyAppointmentsView(context)
        : _buildAppointmentsListView(context);
  }

  // Build the empty state view when no appointments
  Widget _buildEmptyAppointmentsView(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                LocaleKeys.appointment_no_appointments_for_date.tr(
                  namedArgs: {
                    'date': DateFormat(
                      'EEEE,d MMMM',
                      context.locale.languageCode,
                    ).format(selectedDate),
                  },
                ),
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
                textAlign: TextAlign.center,
              ),
              TextButton.icon(
                onPressed: () => onCreateAppointment(selectedDate),
                icon: const Icon(Icons.add, size: 18),
                label: Text(
                  LocaleKeys.buttons_add_appointment.tr(),
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build the list of appointments
  Widget _buildAppointmentsListView(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final appointment = appointments[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          child: AppointmentItemWidget(
            appointment: appointment,
            onEdit: AppointmentDialogService().showEditAppointmentDialog,
            onDelete: (context, appt) => onDeleteAppointment(appt),
            onTap: AppointmentDialogService().showAppointmentDetails,
          ),
        );
      }, childCount: appointments.length),
    );
  }
}
