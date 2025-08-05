// import 'package:bloc/bloc.dart';
// import 'package:dent_app_mobile/models/appointment/doctor_model.dart';
// import 'package:dent_app_mobile/models/appointment/room_model.dart';
// import 'package:dent_app_mobile/models/appointment/time_model.dart';
// import 'package:dent_app_mobile/models/patient/patient_short_model.dart';
// import 'package:dent_app_mobile/presentation/pages/calendar/widgets/custom_search_field.dart';
// import 'package:dent_app_mobile/presentation/pages/settings/views/personal/core/util/appointment_status.dart';
// import 'package:dent_app_mobile/presentation/pages/settings/views/personal/core/util/record_type.dart';
// import 'package:equatable/equatable.dart';
// import 'package:flutter/material.dart';

// part 'create_appointment_dialog_state.dart';

// class CreateAppointmentDialogCubit extends Cubit<CreateAppointmentDialogState> {
//  final DoctorRepository _doctorRepository;
//   final PatientRepository _patientRepository;
  
//   AppointmentDialogCubit(/*...repositories...*/) : super(AppointmentDialogState.initial());

//   void init(DateTime initialDate, bool isAdmin) {
//     // initState'teki tüm mantık buraya taşınacak
//     // _loadRole, _loadRooms vb.
//   }
  
//   void doctorSelected(DoctorModel doctor) {
//     emit(state.copyWith(status: FormStatus.loading, selectedDoctorId: doctor.id));
//     // _loadFreeTimeSlots mantığı burada çalışacak
//     // Sonucunda yeni state emit edilecek
//   }
  
//   void dateChanged(DateTime newDate) {
//      emit(state.copyWith(status: FormStatus.loading, selectedDate: newDate, selectedTimeSlot: null));
//      // Boş zamanları yeniden yükle...
//   }
  
//   void searchPatient(String query) {
//     // Debounce mantığı burada (rxdart paketi ile daha temiz olur)
//     // Arama yap ve state'i güncelle
//   }

//   void saveAppointment() {
//     if (!isFormValid()) return;
//     emit(state.copyWith(status: FormStatus.submitting));
//     // _saveAppointment mantığı burada
//   }
// }