import 'package:dent_app_mobile/core/repo/appointment/appointment_repo.dart';
import 'package:dent_app_mobile/core/utils/format_utils.dart';
import 'package:dent_app_mobile/models/appointment/time_model.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'free_time_state.dart';

class FreeTimeCubit extends Cubit<FreeTimeState> {
  FreeTimeCubit() : super(FreeTimeInitial());

  final IAppointmentRepo appointmentRepo = AppointmentRepo();

  Future<void> getFreeTime(int userId, DateTime date, int minute) async {
    emit(FreeTimeLoading());
    try {
      final times = await appointmentRepo.getTimeList(userId, date, minute);
      emit(FreeTimeLoaded(times: times));
    } on DioException catch (e) {
      emit(FreeTimeError(message: FormatUtils.formatErrorMessage(e)));
    }
  }
}
