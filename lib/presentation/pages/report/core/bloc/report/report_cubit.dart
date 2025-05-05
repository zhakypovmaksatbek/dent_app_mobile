import 'package:dent_app_mobile/core/repo/report/report_repo.dart';
import 'package:dent_app_mobile/core/utils/format_utils.dart';
import 'package:dent_app_mobile/models/report/report_model.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'report_state.dart';

class ReportCubit extends Cubit<ReportState> {
  ReportCubit() : super(ReportInitial());

  final reportRepo = ReportRepository();

  Future<void> getReport(String startDate, String endDate) async {
    emit(ReportLoading());
    try {
      final report = await reportRepo.getReport(startDate, endDate);
      emit(ReportLoaded(report));
    } on DioException catch (e) {
      emit(ReportError(FormatUtils.formatErrorMessage(e)));
    }
  }
}
