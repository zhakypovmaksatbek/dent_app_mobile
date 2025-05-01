import 'package:bloc/bloc.dart';
import 'package:dent_app_mobile/core/repo/report/report_repo.dart';
import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/models/report/payment_report_model.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';

part 'deposit_state.dart';

class DepositCubit extends Cubit<DepositState> {
  DepositCubit() : super(DepositInitial());

  Future<void> getDepositReport(
    String startDate,
    String endDate, {
    int? page,
    DepositType? depositType,
  }) async {
    emit(DepositLoading());
    try {
      final depositReport = await ReportRepository().getDeposit(
        startDate,
        endDate,
        page: page,
        depositType: depositType,
      );
      emit(DepositLoaded(depositReport: depositReport));
    } on DioException catch (e) {
      emit(DepositError(message: _formatErrorMessage(e)));
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
