import 'package:dent_app_mobile/core/repo/service/service_repo.dart';
import 'package:dent_app_mobile/models/service/service_type_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'service_type_state.dart';

class ServiceTypeCubit extends Cubit<ServiceTypeState> {
  ServiceTypeCubit() : super(ServiceTypeInitial());

  final IServiceRepo _serviceTypeRepo = ServiceRepo();

  Future<void> getServiceTypes() async {
    emit(ServiceTypeLoading());
    try {
      final serviceTypes = await _serviceTypeRepo.getServiceTypes();
      if (serviceTypes.serviceTypes == null ||
          serviceTypes.serviceTypes!.isEmpty) {
        emit(ServiceTypeEmpty());
      } else {
        emit(ServiceTypeLoaded(serviceTypes: serviceTypes));
      }
    } on DioException catch (e) {
      emit(ServiceTypeError(message: e.toString()));
    }
  }
}
