import 'package:dent_app_mobile/core/repo/personal/personal_repo.dart';
import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/models/users/user_model.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'personal_state.dart';

class PersonalCubit extends Cubit<PersonalState> {
  PersonalCubit() : super(PersonalInitial());
  final personalRepo = PersonalRepo();

  void getPersonalList(int page, {String? search, bool? isRefresh}) async {
    emit(PersonalLoading());
    try {
      final personalData = await personalRepo.getPersonalList(
        page,
        search: search,
      );
      emit(PersonalLoaded(personalData, isRefresh ?? false));
    } on DioException catch (e) {
      emit(
        PersonalError(
          e.response?.data['message'] ??
              LocaleKeys.errors_something_went_wrong.tr(),
        ),
      );
    } catch (e) {
      emit(PersonalError(e.toString()));
    }
  }
}
