import 'package:dent_app_mobile/core/repo/personal/personal_repo.dart';
import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/models/users/user_detail_model.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'personal_detail_state.dart';

class PersonalDetailCubit extends Cubit<PersonalDetailState> {
  PersonalDetailCubit() : super(PersonalDetailInitial());

  Future<void> getUserDetail(int userId) async {
    emit(PersonalDetailLoading());
    try {
      final user = await PersonalRepo().getPersonalDetailById(userId);
      emit(PersonalDetailLoaded(user: user));
    } on DioException catch (e) {
      String message = '';
      if (e.response?.data is Map<String, dynamic>) {
        message = e.response?.data['message'];
      } else {
        message = LocaleKeys.errors_something_went_wrong.tr();
      }
      emit(PersonalDetailError(message: message));
    }
  }
}
