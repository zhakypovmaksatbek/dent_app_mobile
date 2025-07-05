import 'package:dent_app_mobile/core/repo/appointment/appointment_repo.dart';
import 'package:dent_app_mobile/core/repo/appointment/i_appointment_repo.dart';
import 'package:dent_app_mobile/core/utils/format_utils.dart';
import 'package:dent_app_mobile/models/diagnosis/condition_model.dart';
import 'package:dent_app_mobile/presentation/pages/treatment/core/data/condition_type.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'condition_state.dart';

class ConditionCubit extends Cubit<ConditionState> {
  ConditionCubit() : super(ConditionInitial());
  final IAppointmentRepo _appointmentRepo = AppointmentRepo();

  Future<void> getConditionList(ConditionType type) async {
    emit(ConditionLoading());
    try {
      final conditions = await _appointmentRepo.getConditionList();
      emit(ConditionLoaded(conditions));
    } on DioException catch (e) {
      emit(ConditionError(FormatUtils.formatErrorMessage(e)));
    }
  }
}
