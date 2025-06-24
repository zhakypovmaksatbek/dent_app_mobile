import 'package:dent_app_mobile/core/repo/personal/personal_repo.dart';
import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/models/response_model.dart';
import 'package:dent_app_mobile/models/users/user_detail_model.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  UserCubit() : super(UserInitial());
  final PersonalRepo _personalRepo = PersonalRepo();

  Future<void> getUser() async {
    emit(UserLoading());
    try {
      final user = await _personalRepo.getPersonalDetail();
      emit(UserLoaded(user: user));
    } on DioException catch (e) {
      ResponseModel message = ResponseModel(
        message: LocaleKeys.errors_something_went_wrong.tr(),
      );
      if (e.response?.data is Map<String, dynamic>) {
        message = ResponseModel.fromJson(e.response?.data);
      }
      emit(UserError(response: message));
    } catch (e) {
      emit(UserError(response: ResponseModel(message: e.toString())));
    }
  }
}
