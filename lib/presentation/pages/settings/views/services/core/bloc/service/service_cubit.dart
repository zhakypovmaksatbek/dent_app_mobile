import 'package:dent_app_mobile/core/repo/service/service_repo.dart';
import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/models/service/save_service_model.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'service_state.dart';

class ServiceCubit extends Cubit<ServiceState> {
  ServiceCubit() : super(ServiceInitial());

  final IServiceRepo _serviceRepo = ServiceRepo();

  Future<void> saveService(SaveServiceModel saveServiceModel) async {
    emit(ServiceActionLoading());
    try {
      await _serviceRepo.saveService(saveServiceModel);
      emit(
        ServiceActionSuccess(
          message: LocaleKeys.notifications_service_saved_successfully.tr(),
        ),
      );
    } on DioException catch (e) {
      emit(ServiceError(message: _formatErrorMessage(e)));
    }
  }

  Future<void> updateService(int id, SaveServiceModel saveServiceModel) async {
    emit(ServiceActionLoading());
    try {
      await _serviceRepo.updateService(id, saveServiceModel);
      emit(
        ServiceActionSuccess(
          message: LocaleKeys.notifications_service_updated_successfully.tr(),
        ),
      );
    } on DioException catch (e) {
      emit(ServiceError(message: _formatErrorMessage(e)));
    }
  }

  Future<void> deleteService(int id) async {
    emit(ServiceActionLoading());
    try {
      await _serviceRepo.deleteService(id);
      emit(
        ServiceActionSuccess(
          message: LocaleKeys.notifications_service_deleted_successfully.tr(),
        ),
      );
    } on DioException catch (e) {
      emit(ServiceError(message: _formatErrorMessage(e)));
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
}
