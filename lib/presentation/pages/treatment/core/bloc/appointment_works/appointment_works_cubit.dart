// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:bloc/bloc.dart';
import 'package:dent_app_mobile/core/repo/appointment/i_appointment_repo.dart';
import 'package:dent_app_mobile/models/work/appointment_work_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'appointment_works_cubit.freezed.dart';
part 'appointment_works_state.dart';

class AppointmentWorksCubit extends Cubit<AppointmentWorksState> {
  AppointmentWorksCubit(this.appointmentRepo)
    : super(AppointmentWorksState.initial());
  final IAppointmentRepo appointmentRepo;
  Future<void> loadAppointmentWork(int appointmentId) async {
    emit(AppointmentWorksState.loading());
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));
      // Fetch appointment work data (replace with actual data fetching logic)
      final work = await appointmentRepo.getAppointmentWorks(appointmentId);
      emit(AppointmentWorksState.loaded(work));
    } catch (e) {
      emit(AppointmentWorksState.error(e.toString()));
    }
  }
}
