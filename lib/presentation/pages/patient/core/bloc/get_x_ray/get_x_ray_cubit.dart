import 'package:dent_app_mobile/core/repo/appointment/appointment_repo.dart';
import 'package:dent_app_mobile/core/repo/appointment/i_appointment_repo.dart';
import 'package:dent_app_mobile/core/utils/format_utils.dart';
import 'package:dent_app_mobile/models/diagnosis/x_ray_model.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'get_x_ray_state.dart';

class GetXRayCubit extends Cubit<GetXRayState> {
  final IAppointmentRepo appointmentRepo = AppointmentRepo();
  GetXRayCubit() : super(GetXRayInitial());

  Future<void> getPatientXRay(int appointmentId) async {
    emit(GetXRayLoading());
    try {
      final result = await appointmentRepo.getPatientXRay(appointmentId);
      emit(GetXRayLoaded(xRay: result));
    } on DioException catch (e) {
      emit(GetXRayError(message: FormatUtils.formatErrorMessage(e)));
    } catch (e) {
      emit(GetXRayError(message: e.toString()));
    }
  }
}
