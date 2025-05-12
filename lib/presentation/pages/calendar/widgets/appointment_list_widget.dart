import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/models/appointment/calendar_appointment_model.dart';
import 'package:dent_app_mobile/models/appointment/doctor_model.dart';
import 'package:dent_app_mobile/presentation/pages/calendar/widgets/appointment_item_widget.dart';
import 'package:dent_app_mobile/presentation/pages/calendar/widgets/calendar_view_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class AppointmentListWidget extends StatelessWidget {
  final List<CalendarAppointmentModel> appointments;
  final DateTime selectedDate;
  final Function(BuildContext, CalendarAppointmentModel) onEdit;
  final Function(BuildContext, CalendarAppointmentModel) onDelete;
  final Function(BuildContext, Appointment) onTap;
  final Function(BuildContext, {DateTime? initialDate}) onAddAppointment;
  final ValueNotifier<List<DoctorModel>> doctors;
  final Function(BuildContext, DoctorModel) onDoctorChanged;
  final List<DoctorModel>? selectedDoctors;
  final ScrollController? scrollController;

  const AppointmentListWidget({
    super.key,
    required this.appointments,
    required this.selectedDate,
    required this.onEdit,
    required this.onDelete,
    required this.onTap,
    required this.onAddAppointment,
    required this.doctors,
    required this.onDoctorChanged,
    this.selectedDoctors,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Doctor selection and filters in a row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: doctors,
                  builder: (context, value, child) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButton<DoctorModel>(
                        isExpanded: true,
                        underline: const SizedBox(),
                        hint: Text(
                          'Select Doctor',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        value: null,
                        items:
                            value.map((doctor) {
                              final isSelected =
                                  selectedDoctors?.contains(doctor) ?? false;
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
                            onDoctorChanged(context, newValue);
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
              if (selectedDoctors?.isNotEmpty == true)
                IconButton(
                  icon: const Icon(
                    Icons.clear_all,
                    size: 20,
                    color: Colors.red,
                  ),
                  onPressed: () => onDoctorChanged(context, DoctorModel()),
                  tooltip: 'Clear All Filters',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
        ),

        // Selected doctors chips in horizontal scrollable row
        if (selectedDoctors?.isNotEmpty == true)
          Container(
            height: 40,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: selectedDoctors!.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final doctor = selectedDoctors![index];
                return Chip(
                  labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                  padding: EdgeInsets.zero,
                  label: Text(
                    doctor.fullName ?? '',
                    style: const TextStyle(fontSize: 12),
                  ),
                  deleteIcon: const Icon(Icons.close, size: 14),
                  onDeleted: () => onDoctorChanged(context, doctor),
                  backgroundColor: Colors.blue.shade50,
                  side: BorderSide(color: Colors.blue.shade200),
                  visualDensity: VisualDensity.compact,
                );
              },
            ),
          ),

        // Divider if doctors are selected
        if (selectedDoctors?.isNotEmpty == true) const Divider(height: 1),

        // Appointments list - takes remaining space
        Expanded(
          child:
              appointments.isEmpty
                  ? Center(
                    child: Column(
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
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        TextButton.icon(
                          onPressed:
                              () => onAddAppointment(
                                context,
                                initialDate: selectedDate,
                              ),
                          icon: const Icon(Icons.add, size: 18),
                          label: Text(
                            LocaleKeys.buttons_add_appointment.tr(),
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  )
                  : ListView.separated(
                    itemCount: appointments.length,
                    separatorBuilder:
                        (context, index) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final appointment = appointments[index];
                      return AppointmentItemWidget(
                        appointment: appointment,
                        onEdit: onEdit,
                        onDelete: onDelete,
                        onTap: onTap,
                      );
                    },
                    controller: scrollController,
                  ),
        ),
      ],
    );
  }
}
