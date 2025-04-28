import 'package:dent_app_mobile/models/pagination_model.dart';

class PaymentReportDataModel extends PaginationModel<PaymentReportModel> {
  PaymentReportDataModel.fromJson(Map<String, dynamic> json)
    : super.fromJson(json, (item) => PaymentReportModel.fromJson(item));
}

class PaymentReportModel {
  int? appointmentId;
  String? appointmentDateTime;
  int? doctorId;
  String? doctorFullName;
  int? patientId;
  String? patientFullName;
  String? payedDate;
  String? typeOfPayment;
  double? payed;

  PaymentReportModel({
    this.appointmentId,
    this.appointmentDateTime,
    this.doctorId,
    this.doctorFullName,
    this.patientId,
    this.patientFullName,
    this.payedDate,
    this.typeOfPayment,
    this.payed,
  });

  PaymentReportModel.fromJson(Map<String, dynamic> json) {
    appointmentId = json['appointmentId'];
    appointmentDateTime = json['appointmentDateTime'];
    doctorId = json['doctorId'];
    doctorFullName = json['doctorFullName'];
    patientId = json['patientId'];
    patientFullName = json['patientFullName'];
    payedDate = json['payedDate'];
    typeOfPayment = json['typeOfPayment'];
    payed = json['payed']?.toDouble();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['appointmentId'] = appointmentId;
    data['appointmentDateTime'] = appointmentDateTime;
    data['doctorId'] = doctorId;
    data['doctorFullName'] = doctorFullName;
    data['patientId'] = patientId;
    data['patientFullName'] = patientFullName;
    data['payedDate'] = payedDate;
    data['typeOfPayment'] = typeOfPayment;
    data['payed'] = payed;
    return data;
  }
}
