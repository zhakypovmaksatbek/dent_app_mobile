import 'package:dent_app_mobile/core/repo/user/user_repo.dart';
import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/models/login/login_model.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginInitial());
  final UserRepo _userRepo = UserRepoImpl();

  Future<void> login(String email, String password) async {
    emit(LoginLoading());
    try {
      final user = await _userRepo.login(
        LoginModel(email: email, password: password),
      );
      emit(LoginSuccess(user: user));
    } on DioException catch (e) {
      if (e.response?.data is Map<String, dynamic>) {
        emit(LoginFailure(error: e.response?.data['message']));
      } else {
        emit(LoginFailure(error: LocaleKeys.errors_something_went_wrong.tr()));
      }
    } catch (e) {
      emit(LoginFailure(error: LocaleKeys.errors_something_went_wrong.tr()));
    }
  }
}
