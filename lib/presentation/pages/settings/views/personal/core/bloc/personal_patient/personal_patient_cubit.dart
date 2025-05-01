import 'package:dent_app_mobile/core/repo/user/user_repo.dart';
import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/models/patient/visit_model.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'personal_patient_state.dart';

class PersonalPatientCubit extends Cubit<PersonalPatientState> {
  PersonalPatientCubit() : super(PersonalPatientInitial());
  final UserRepo userRepo = UserRepoImpl();
  Future<void> getVisits({
    required int userId,
    required int page,
    bool isRefresh = false,
  }) async {
    emit(PersonalPatientLoading());
    try {
      final visits = await userRepo.getVisits(userId: userId, page: page);
      emit(PersonalPatientLoaded(visits: visits, isRefresh: isRefresh));
    } on DioException catch (e) {
      String message = "";
      if (e.response?.data is Map<String, dynamic>) {
        message =
            e.response?.data['message'] ??
            LocaleKeys.errors_something_went_wrong.tr();
      } else {
        message = e.toString();
      }
      emit(PersonalPatientError(message: message));
    }
  }
}
