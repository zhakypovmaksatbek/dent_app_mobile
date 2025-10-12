import 'package:bloc/bloc.dart';
import 'package:dent_app_mobile/core/repo/appointment/appointment_repo.dart';
import 'package:dent_app_mobile/core/utils/format_utils.dart';
import 'package:dent_app_mobile/models/payment/detail_receipt_model.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

part 'detail_receipt_state.dart';

class DetailReceiptCubit extends Cubit<DetailReceiptState> {
  DetailReceiptCubit() : super(DetailReceiptInitial());
  final AppointmentRepo _appointmentRepo = AppointmentRepo();

  Future<void> getDetailReceipt(int appointmentId) async {
    emit(DetailReceiptLoading());
    try {
      final detailReceipt = await _appointmentRepo.getDetailReceipt(
        appointmentId,
      );
      emit(DetailReceiptSuccess(detailReceipt: detailReceipt));
    } on DioException catch (e) {
      emit(DetailReceiptError(message: FormatUtils.formatErrorMessage(e)));
    } catch (e) {
      emit(DetailReceiptError(message: e.toString()));
    }
  }
}
