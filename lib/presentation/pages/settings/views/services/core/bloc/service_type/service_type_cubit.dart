import 'package:dent_app_mobile/core/repo/service/service_repo.dart';
import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/models/service/service_type_model.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
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
      emit(ServiceTypeError(message: _formatErrorMessage(e)));
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
