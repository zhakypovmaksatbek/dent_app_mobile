import 'package:bloc/bloc.dart';
import 'package:dent_app_mobile/core/repo/report/report_repo.dart';
import 'package:dent_app_mobile/models/report/payment_report_model.dart';
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
    } catch (e) {
      emit(DepositError(message: e.toString()));
    }
  }
}
