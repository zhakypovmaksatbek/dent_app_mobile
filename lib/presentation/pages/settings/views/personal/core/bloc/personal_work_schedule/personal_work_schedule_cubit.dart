import 'package:dent_app_mobile/core/repo/user/user_repo.dart';
import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/models/users/schedule_model.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'personal_work_schedule_state.dart';

class PersonalWorkScheduleCubit extends Cubit<PersonalWorkScheduleState> {
  PersonalWorkScheduleCubit() : super(PersonalWorkScheduleInitial());

  final UserRepo userRepo = UserRepoImpl();

  void getDoctorSchedule(int userId, DateTime startWeek) async {
    emit(PersonalWorkScheduleLoading());
    try {
      final schedule = await userRepo.getDoctorSchedule(userId, startWeek);
      emit(PersonalWorkScheduleLoaded(schedule));
    } on DioException catch (e) {
      emit(PersonalWorkScheduleError(_formatErrorMessage(e)));
    }
  }

  String _formatErrorMessage(DioException e) {
    String message = LocaleKeys.errors_something_went_wrong.tr();
    if (e.response?.data is Map<String, dynamic>) {
      final data = e.response?.data as Map<String, dynamic>;
      if (data.containsKey('message')) {
        message = data['message'];
      }
    }
    return message;
  }

  /// Resets state to initial
  void reset() {
    emit(PersonalWorkScheduleInitial());
  }
}
