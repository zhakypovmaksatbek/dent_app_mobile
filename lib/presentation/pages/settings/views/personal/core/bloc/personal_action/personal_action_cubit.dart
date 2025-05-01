import 'package:dent_app_mobile/core/repo/personal/personal_repo.dart';
import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/models/users/personal_model.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'personal_action_state.dart';

class PersonalActionCubit extends Cubit<PersonalActionState> {
  PersonalActionCubit() : super(PersonalActionInitial());

  final PersonalRepo personalRepo = PersonalRepo();

  Future<void> createPerson(PersonalModel doctor) async {
    emit(PersonalActionLoading());
    try {
      await personalRepo.createPersonal(doctor);
      emit(PersonalActionSuccess());
    } on DioException catch (e) {
      emit(
        PersonalActionError(
          e.response?.data['message'] ??
              LocaleKeys.errors_something_went_wrong.tr(),
        ),
      );
    } catch (e) {
      emit(PersonalActionError(e.toString()));
    }
  }

  Future<void> updatePerson(int id, PersonalModel doctor) async {
    emit(PersonalActionLoading());
    try {
      await personalRepo.updatePersonal(id, doctor);
      emit(PersonalActionSuccess());
    } on DioException catch (e) {
      emit(
        PersonalActionError(
          e.response?.data['message'] ??
              LocaleKeys.errors_something_went_wrong.tr(),
        ),
      );
    } catch (e) {
      emit(PersonalActionError(e.toString()));
    }
  }

  Future<void> deletePerson(int id) async {
    emit(PersonalActionLoading());
    try {
      await personalRepo.deletePersonal(id);
      emit(PersonalActionSuccess());
    } on DioException catch (e) {
      emit(
        PersonalActionError(
          e.response?.data['message'] ??
              LocaleKeys.errors_something_went_wrong.tr(),
        ),
      );
    } catch (e) {
      emit(PersonalActionError(e.toString()));
    }
  }
}
