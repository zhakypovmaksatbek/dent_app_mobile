import 'package:bloc/bloc.dart';
import 'package:dent_app_mobile/core/repo/report/report_repo.dart';
import 'package:dent_app_mobile/models/report/payment_report_model.dart';
import 'package:equatable/equatable.dart';

part 'discount_state.dart';

class DiscountCubit extends Cubit<DiscountState> {
  DiscountCubit() : super(DiscountInitial());

  Future<void> getDiscountReport(
    String startDate,
    String endDate, {
    int? page,
  }) async {
    emit(DiscountLoading());
    try {
      final discountReport = await ReportRepository().getDiscountReport(
        startDate,
        endDate,
        page: page,
      );
      emit(DiscountLoaded(discountReport: discountReport));
    } catch (e) {
      emit(DiscountError(message: e.toString()));
    }
  }
}
