import 'package:dent_app_mobile/core/repo/report/report_repo.dart';
import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/models/report/report_model.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
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
      if (e.response?.data is Map<String, dynamic>) {
        emit(
          ReportError(
            e.response?.data['message'] ??
                LocaleKeys.errors_something_went_wrong.tr(),
          ),
        );
      } else {
        emit(ReportError(LocaleKeys.errors_something_went_wrong.tr()));
      }
    }
  }
}
