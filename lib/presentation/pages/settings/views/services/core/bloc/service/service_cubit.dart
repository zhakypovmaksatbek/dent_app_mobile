import 'package:dent_app_mobile/core/repo/service/service_repo.dart';
import 'package:dent_app_mobile/models/service/save_service_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'service_state.dart';

class ServiceCubit extends Cubit<ServiceState> {
  ServiceCubit() : super(ServiceInitial());

  final IServiceRepo _serviceRepo = ServiceRepo();

  Future<void> saveService(SaveServiceModel saveServiceModel) async {
    emit(ServiceActionLoading());
    try {
      await _serviceRepo.saveService(saveServiceModel);
      emit(ServiceActionSuccess(message: 'Servis başarıyla kaydedildi'));
    } on DioException catch (e) {
      emit(ServiceError(message: e.response?.data['message'] ?? ''));
    }
  }

  Future<void> updateService(int id, SaveServiceModel saveServiceModel) async {
    emit(ServiceActionLoading());
    try {
      await _serviceRepo.updateService(id, saveServiceModel);
      emit(ServiceActionSuccess(message: 'Servis başarıyla güncellendi'));
    } on DioException catch (e) {
      emit(ServiceError(message: e.response?.data['message'] ?? ''));
    }
  }

  Future<void> deleteService(int id) async {
    emit(ServiceActionLoading());
    try {
      await _serviceRepo.deleteService(id);
      emit(ServiceActionSuccess(message: 'Servis başarıyla silindi'));
    } on DioException catch (e) {
      emit(ServiceError(message: e.response?.data['message'] ?? ''));
    }
  }
}
