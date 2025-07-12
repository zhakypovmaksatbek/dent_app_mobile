import 'package:dent_app_mobile/core/repo/appointment/appointment_repo.dart';
import 'package:dent_app_mobile/core/utils/format_utils.dart';
import 'package:dent_app_mobile/presentation/pages/treatment/core/model/job_model.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'save_jobs_state.dart';

class SaveJobsCubit extends Cubit<SaveJobsState> {
  SaveJobsCubit() : super(SaveJobsInitial());
  final AppointmentRepo appointmentRepo = AppointmentRepo();

  Future<void> saveJobs(int appointmentId, List<JobModel> jobs) async {
    emit(SaveJobsLoading());
    try {
      await appointmentRepo.saveWorks(appointmentId, jobs);
      emit(SaveJobsSuccess());
    } on DioException catch (e) {
      emit(SaveJobsError(message: FormatUtils.formatErrorMessage(e)));
    }
  }
}
