import 'package:dent_app_mobile/core/repo/appointment/appointment_repo.dart';
import 'package:dent_app_mobile/core/utils/format_utils.dart';
import 'package:dent_app_mobile/models/payment/payment_model.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'pay_appointment_state.dart';

class PayAppointmentCubit extends Cubit<PayAppointmentState> {
  PayAppointmentCubit() : super(PayAppointmentInitial());
  final AppointmentRepo _appointmentRepo = AppointmentRepo();

  Future<void> payAppointment(PaymentModel payment, int appointmentId) async {
    emit(PayAppointmentLoading());
    try {
      await _appointmentRepo.fastPay(payment, appointmentId);
      emit(PayAppointmentSuccess());
    } on DioException catch (e) {
      emit(PayAppointmentError(error: FormatUtils.formatErrorMessage(e)));
    }
  }
}
