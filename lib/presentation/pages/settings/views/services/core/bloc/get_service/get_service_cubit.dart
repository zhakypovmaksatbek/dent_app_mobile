import 'package:dent_app_mobile/core/repo/service/service_repo.dart';
import 'package:dent_app_mobile/models/service/service_model.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'get_service_state.dart';

class GetServiceCubit extends Cubit<GetServiceState> {
  GetServiceCubit() : super(GetServiceInitial());

  final IServiceRepo _serviceRepo = ServiceRepo();

  Future<void> getServices({String? search}) async {
    emit(GetServiceLoading());
    try {
      final services = await _serviceRepo.getServices(search: search);
      emit(GetServiceLoaded(services: services));
    } on DioException catch (e) {
      emit(GetServiceError(message: e.toString()));
    }
  }
}
