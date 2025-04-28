import 'package:dent_app_mobile/core/repo/report/report_repo.dart';
import 'package:dent_app_mobile/models/report/debtor_model.dart';
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
    } catch (e) {
      emit(DebtorError(message: e.toString()));
    }
  }
}
