import 'package:dent_app_mobile/core/repo/service/service_repo.dart';
import 'package:dent_app_mobile/models/service/service_model.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'get_service_item_state.dart';

class GetServiceItemCubit extends Cubit<GetServiceItemState> {
  GetServiceItemCubit() : super(GetServiceItemInitial());

  final IServiceRepo _serviceRepo = ServiceRepo();

  Future<void> getServiceItems({String? search}) async {
    emit(GetServiceItemLoading());
    try {
      final serviceItems = await _serviceRepo.getServiceItems(search: search);
      emit(GetServiceItemLoaded(serviceItems: serviceItems));
    } on DioException catch (e) {
      emit(GetServiceItemError(message: e.toString()));
    }
  }
}
