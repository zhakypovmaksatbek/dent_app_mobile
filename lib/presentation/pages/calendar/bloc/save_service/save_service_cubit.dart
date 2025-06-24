import 'package:dent_app_mobile/core/repo/appointment/appointment_repo.dart';
import 'package:dent_app_mobile/core/utils/format_utils.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'save_service_state.dart';

class SaveServiceCubit extends Cubit<SaveServiceState> {
  SaveServiceCubit() : super(SaveServiceInitial());

  void fastPay(int appointmentId, List<int> serviceIds) async {
    emit(SaveServiceLoading());
    try {
      final message = await AppointmentRepo().saveServices(
        appointmentId,
        serviceIds,
      );
      emit(SaveServiceSuccess(message: message));
    } on DioException catch (e) {
      emit(SaveServiceError(message: FormatUtils.formatErrorMessage(e)));
    }
  }
}
