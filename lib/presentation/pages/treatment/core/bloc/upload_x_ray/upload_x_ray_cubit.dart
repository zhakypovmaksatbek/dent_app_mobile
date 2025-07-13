import 'package:dent_app_mobile/core/repo/appointment/appointment_repo.dart';
import 'package:dent_app_mobile/core/utils/format_utils.dart';
import 'package:dent_app_mobile/models/work/upload_patient_rontgen_model.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'upload_x_ray_state.dart';

class UploadXRayCubit extends Cubit<UploadXRayState> {
  UploadXRayCubit() : super(UploadXRayInitial());
  final AppointmentRepo appointmentRepo = AppointmentRepo();
  Future<void> uploadXRay(UploadXRayModel uploadXRayModel) async {
    emit(UploadXRayLoading());
    try {
      await appointmentRepo.uploadPatientXRay(uploadXRayModel);
      emit(UploadXRaySuccess());
    } on DioException catch (e) {
      emit(UploadXRayError(message: FormatUtils.formatErrorMessage(e)));
    } catch (e) {
      emit(UploadXRayError(message: e.toString()));
    }
  }
}
