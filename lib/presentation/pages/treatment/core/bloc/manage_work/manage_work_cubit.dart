import 'package:bloc/bloc.dart';
import 'package:dent_app_mobile/core/repo/appointment/i_appointment_repo.dart';
import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/models/response_model.dart';
import 'package:dent_app_mobile/models/work/appointment_work_model.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'manage_work_cubit.freezed.dart';
part 'manage_work_state.dart';

class ManageWorkCubit extends Cubit<ManageWorkState> {
  ManageWorkCubit(this._repo) : super(ManageWorkState.initial());
  final IAppointmentRepo _repo;

  Future<void> updateWork({
    required int workId,
    required AppointmentWorkModel workModel,
  }) async {
    emit(const ManageWorkState.loading());
    try {
      await _repo.updateAppointmentWork(workId, work: workModel);

      emit(
        ManageWorkState.success(
          LocaleKeys.notifications_work_successfully_saved.tr(),
          false,
          workId,
        ),
      );
    } on DioException catch (e) {
      ResponseModel message = ResponseModel(
        message: LocaleKeys.errors_something_went_wrong.tr(),
      );
      if (e.response?.data is Map<String, dynamic>) {
        message = ResponseModel.fromJson(e.response?.data);
      }
      emit(ManageWorkState.error(message: message));
    }
  }

  Future<void> deleteWork(int workId) async {
    emit(const ManageWorkState.loading());
    try {
      await _repo.deleteAppointmentWork(workId);
      emit(
        ManageWorkState.success(
          LocaleKeys.notifications_work_successfully_deleted.tr(),
          true,
          workId,
        ),
      );
    } on DioException catch (e) {
      ResponseModel message = ResponseModel(
        message: LocaleKeys.errors_something_went_wrong.tr(),
      );
      if (e.response?.data is Map<String, dynamic>) {
        message = ResponseModel.fromJson(e.response?.data);
      }
      emit(ManageWorkState.error(message: message));
    }
  }
}
