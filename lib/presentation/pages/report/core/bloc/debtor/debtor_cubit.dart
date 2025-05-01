import 'package:dent_app_mobile/core/repo/report/report_repo.dart';
import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/models/report/debtor_model.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'debtor_state.dart';

class DebtorCubit extends Cubit<DebtorState> {
  final _reportRepository = ReportRepository();

  DebtorCubit() : super(DebtorInitial());

  Future<void> getDebtorReport(
    String startDate,
    String endDate, {
    int? page,
    String? search,
  }) async {
    emit(DebtorLoading());
    try {
      final debtorReport = await _reportRepository.getDebtor(
        page: page,
        search: search,
      );
      emit(DebtorLoaded(debtorReport: debtorReport));
    } on DioException catch (e) {
      emit(DebtorError(message: _formatErrorMessage(e)));
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
