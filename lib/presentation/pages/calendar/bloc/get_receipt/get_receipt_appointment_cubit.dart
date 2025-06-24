import 'package:dent_app_mobile/core/repo/appointment/appointment_repo.dart';
import 'package:dent_app_mobile/core/utils/format_utils.dart';
import 'package:dent_app_mobile/models/payment/receipt_model.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'get_receipt_appointment_state.dart';

class GetReceiptAppointmentCubit extends Cubit<GetReceiptAppointmentState> {
  GetReceiptAppointmentCubit() : super(GetReceiptAppointmentInitial());

  void getReceipt(int appointmentId) async {
    emit(GetReceiptAppointmentLoading());
    try {
      final receipt = await AppointmentRepo().getReceipt(appointmentId);
      emit(GetReceiptAppointmentSuccess(receipt: receipt));
    } on DioException catch (e) {
      emit(
        GetReceiptAppointmentError(message: FormatUtils.formatErrorMessage(e)),
      );
    }
  }
}
