// // ignore_for_file: public_member_api_docs, sort_constructors_first
// part of 'create_appointment_dialog_cubit.dart';

// class CreateAppointmentDialogState {
//   final DateTime selectedDate;
//   final TimeOfDay startTime;
//   final TimeOfDay endTime;

//   // Doctor Section
//   final List<DoctorModel> allDoctors;
//   final List<CustomSearchItem<DoctorModel>> doctorSuggestions;
//   final int? selectedDoctorId;

//   // Patient Section
//   final List<PatientShortModel> patientSuggestions;
//   final int? selectedPatientId;

//   // Time & Duration
//   final List<TimeModel> freeTimeSlots;
//   final TimeModel? selectedTimeSlot;
//   final int selectedMinute;

//   // Other fields
//   final List<RoomModel> availableRooms;
//   final int? selectedRoomId;
//   final RecordType recordType;
//   final AppointmentStatus appointmentStatus;
//   final String description;
//   final bool showAdvancedOptions;

//   final FormStatus status;
//   final String? errorMessage;

//   CreateAppointmentDialogState({
//     required this.selectedDate,
//     required this.startTime,
//     required this.endTime,
//     required this.allDoctors,
//     required this.doctorSuggestions,
//     required this.selectedDoctorId,
//     required this.patientSuggestions,
//     required this.selectedPatientId,
//     required this.freeTimeSlots,
//     required this.selectedTimeSlot,
//     required this.selectedMinute,
//     required this.availableRooms,
//     required this.selectedRoomId,
//     required this.recordType,
//     required this.appointmentStatus,
//     required this.description,
//     required this.showAdvancedOptions,
//     this.status = FormStatus.initial,
//     this.errorMessage,
//   });

//   CreateAppointmentDialogState copyWith({
//     DateTime? selectedDate,
//     TimeOfDay? startTime,
//     TimeOfDay? endTime,
//     List<DoctorModel>? allDoctors,
//     List<CustomSearchItem<DoctorModel>>? doctorSuggestions,
//     int? selectedDoctorId,
//     List<PatientShortModel>? patientSuggestions,
//     int? selectedPatientId,
//     List<TimeModel>? freeTimeSlots,
//     TimeModel? selectedTimeSlot,
//     int? selectedMinute,
//     List<RoomModel>? availableRooms,
//     int? selectedRoomId,
//     RecordType? recordType,
//     AppointmentStatus? appointmentStatus,
//     String? description,
//     bool? showAdvancedOptions,
//     FormStatus? status,
//     String? errorMessage,
//   }) {
//     return CreateAppointmentDialogState(
//       selectedDate: selectedDate ?? this.selectedDate,
//       startTime: startTime ?? this.startTime,
//       endTime: endTime ?? this.endTime,
//       allDoctors: allDoctors ?? this.allDoctors,
//       doctorSuggestions: doctorSuggestions ?? this.doctorSuggestions,
//       selectedDoctorId: selectedDoctorId ?? this.selectedDoctorId,
//       patientSuggestions: patientSuggestions ?? this.patientSuggestions,
//       selectedPatientId: selectedPatientId ?? this.selectedPatientId,
//       freeTimeSlots: freeTimeSlots ?? this.freeTimeSlots,
//       selectedTimeSlot: selectedTimeSlot ?? this.selectedTimeSlot,
//       selectedMinute: selectedMinute ?? this.selectedMinute,
//       availableRooms: availableRooms ?? this.availableRooms,
//       selectedRoomId: selectedRoomId ?? this.selectedRoomId,
//       recordType: recordType ?? this.recordType,
//       appointmentStatus: appointmentStatus ?? this.appointmentStatus,
//       description: description ?? this.description,
//       showAdvancedOptions: showAdvancedOptions ?? this.showAdvancedOptions,
//       status: status ?? this.status,
//       errorMessage: errorMessage ?? this.errorMessage,
//     );
//   }
// }

// enum FormStatus { initial, loading, success, failure, submitting }
