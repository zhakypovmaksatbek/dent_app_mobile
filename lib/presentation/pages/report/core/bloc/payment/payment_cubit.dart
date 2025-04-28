import 'package:bloc/bloc.dart';
import 'package:dent_app_mobile/core/repo/report/report_repo.dart';
import 'package:dent_app_mobile/models/report/payment_report_model.dart';
import 'package:equatable/equatable.dart';

part 'payment_state.dart';

class PaymentCubit extends Cubit<PaymentState> {
  final ReportRepository _reportRepo = ReportRepository();

  PaymentCubit() : super(PaymentInitial());

  Future<void> getPaymentReport(
    String startDate,
    String endDate, {
    int? page,
    int? size,
  }) async {
    emit(PaymentLoading());

    try {
      final paymentReport = await _reportRepo.getPaymentReport(
        startDate,
        endDate,
        page: page,
      );

      emit(PaymentLoaded(paymentReport: paymentReport));
    } catch (e) {
      emit(PaymentError(message: e.toString()));
    }
  }
}
