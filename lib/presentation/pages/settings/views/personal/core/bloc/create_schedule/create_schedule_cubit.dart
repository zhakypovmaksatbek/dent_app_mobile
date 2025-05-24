import 'package:dent_app_mobile/core/repo/user/user_repo.dart';
import 'package:dent_app_mobile/core/utils/format_utils.dart';
import 'package:dent_app_mobile/models/response_model.dart';
import 'package:dent_app_mobile/models/users/create_schedule_model.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'create_schedule_state.dart';

class CreateScheduleCubit extends Cubit<CreateScheduleState> {
  CreateScheduleCubit() : super(CreateScheduleInitial());

  final UserRepo userRepo = UserRepoImpl();

  void createSchedule(int userId, CreateScheduleModel schedule) async {
    emit(CreateScheduleLoading());
    try {
      final response = await userRepo.createDoctorSchedule(userId, schedule);
      emit(CreateScheduleSuccess(response));
    } on DioException catch (e) {
      emit(CreateScheduleError(FormatUtils.formatErrorMessage(e)));
    }
  }
}
