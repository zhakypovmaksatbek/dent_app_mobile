import 'package:dent_app_mobile/models/pagination_model.dart';

final class ReportDataModel extends PaginationModel<ReportModel> {
  ReportDataModel.fromJson(Map<String, dynamic> json)
    : super.fromJson(json, (item) => ReportModel.fromJson(item));
}

class ReportModel {
  String? cash;
  String? withoutCash;
  String? mbank;
  String? optima;
  String? discount;
  String? paymentByDeposit;
  String? makeDeposit;
  String? totalAmount;
  ReportByDateResponse? reportByDateResponse;
  ReportDeptPaymentResponse? reportDeptPaymentResponse;

  ReportModel({
    this.cash,
    this.withoutCash,
    this.mbank,
    this.optima,
    this.discount,
    this.paymentByDeposit,
    this.makeDeposit,
    this.totalAmount,
    this.reportByDateResponse,
    this.reportDeptPaymentResponse,
  });

  ReportModel.fromJson(Map<String, dynamic> json) {
    cash = json['cash']?.toString();
    withoutCash = json['withoutCash']?.toString();
    mbank = json['mbank']?.toString();
    optima = json['optima']?.toString();
    discount = json['discount']?.toString();
    paymentByDeposit = json['paymentByDeposit']?.toString();
    makeDeposit = json['makeDeposit']?.toString();
    totalAmount = json['totalAmount']?.toString();
    reportByDateResponse =
        json['reportByDateResponse'] != null
            ? ReportByDateResponse.fromJson(json['reportByDateResponse'])
            : null;
    reportDeptPaymentResponse =
        json['reportDeptPaymentResponse'] != null
            ? ReportDeptPaymentResponse.fromJson(
              json['reportDeptPaymentResponse'],
            )
            : null;
  }
}

class ReportByDateResponse {
  String? appointment;
  String? invoicesIssued;
  String? paid;
  String? partly;
  String? notPaid;
  String? paymentByDeposit;
  String? makeDeposit;
  String? discounts;

  ReportByDateResponse({
    this.appointment,
    this.invoicesIssued,
    this.paid,
    this.partly,
    this.notPaid,
    this.paymentByDeposit,
    this.makeDeposit,
    this.discounts,
  });

  ReportByDateResponse.fromJson(Map<String, dynamic> json) {
    appointment = json['appointment']?.toString();
    invoicesIssued = json['invoicesIssued']?.toString();
    paid = json['paid']?.toString();
    partly = json['partly']?.toString();
    notPaid = json['notPaid']?.toString();
    paymentByDeposit = json['paymentByDeposit']?.toString();
    makeDeposit = json['makeDeposit']?.toString();
    discounts = json['discounts']?.toString();
  }
}

class ReportDeptPaymentResponse {
  String? debtRepayment;
  String? discount;
  String? paymentByDeposit;
  String? makeDeposit;

  ReportDeptPaymentResponse({
    this.debtRepayment,
    this.discount,
    this.paymentByDeposit,
    this.makeDeposit,
  });

  ReportDeptPaymentResponse.fromJson(Map<String, dynamic> json) {
    debtRepayment = json['debtRepayment']?.toString();
    discount = json['discount']?.toString();
    paymentByDeposit = json['paymentByDeposit']?.toString();
    makeDeposit = json['makeDeposit']?.toString();
  }
}
