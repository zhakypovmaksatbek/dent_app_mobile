import 'package:dent_app_mobile/core/repo/appointment/appointment_repo.dart';
import 'package:dent_app_mobile/core/utils/format_utils.dart';
import 'package:dent_app_mobile/models/pattern/pattern_model.dart';
import 'package:dent_app_mobile/presentation/pages/treatment/core/data/pattern_type.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'pattern_state.dart';

class PatternCubit extends Cubit<PatternState> {
  PatternCubit() : super(PatternInitial());
  final appointmentRepo = AppointmentRepo();

  Future<void> getPatternList(PatternType type, {String? search}) async {
    emit(PatternLoading());
    try {
      final pattern = await appointmentRepo.getPatternList(
        type,
        search: search,
      );
      emit(PatternLoaded(pattern: pattern));
    } on DioException catch (e) {
      emit(PatternError(message: FormatUtils.formatErrorMessage(e)));
    }
  }
}
