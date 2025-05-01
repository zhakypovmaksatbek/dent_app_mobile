import 'package:dent_app_mobile/models/pagination_model.dart';

final class VisitDataModel extends PaginationModel<VisitModel> {
  VisitDataModel.fromJson(Map<String, dynamic> json)
    : super.fromJson(json, (item) => VisitModel.fromJson(item));
}

class VisitModel {
  int? appointmentId;
  int? patientId;
  String? appointment;
  String? recordType;
  double? totalPrice;
  double? pricePayable;
  double? paid;
  double? debt;
  double? additionalDiscount;
  double? deposit;
  List<AppointmentServiceToPatientResponses>?
  appointmentServiceToPatientResponses;
  List<int>? tooth;

  VisitModel({
    this.appointmentId,
    this.patientId,
    this.appointment,
    this.recordType,
    this.totalPrice,
    this.pricePayable,
    this.paid,
    this.debt,
    this.additionalDiscount,
    this.deposit,
    this.appointmentServiceToPatientResponses,
    this.tooth,
  });

  VisitModel.fromJson(Map<String, dynamic> json) {
    appointmentId = json['appointmentId'];
    patientId = json['patientId'];
    appointment = json['appointment'];
    recordType = json['recordType'];
    totalPrice = json['totalPrice'];
    pricePayable = json['pricePayable'];
    paid = json['paid'];
    debt = json['debt'];
    additionalDiscount = json['additionalDiscount'];
    deposit = json['deposit'];
    if (json['appointmentServiceToPatientResponses'] != null) {
      appointmentServiceToPatientResponses =
          <AppointmentServiceToPatientResponses>[];
      json['appointmentServiceToPatientResponses'].forEach((v) {
        appointmentServiceToPatientResponses!.add(
          AppointmentServiceToPatientResponses.fromJson(v),
        );
      });
    }
    tooth = json['tooth'].cast<int>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['appointmentId'] = appointmentId;
    data['patientId'] = patientId;
    data['appointment'] = appointment;
    data['recordType'] = recordType;
    data['totalPrice'] = totalPrice;
    data['pricePayable'] = pricePayable;
    data['paid'] = paid;
    data['debt'] = debt;
    data['additionalDiscount'] = additionalDiscount;
    data['deposit'] = deposit;
    if (appointmentServiceToPatientResponses != null) {
      data['appointmentServiceToPatientResponses'] =
          appointmentServiceToPatientResponses!.map((v) => v.toJson()).toList();
    }
    data['tooth'] = tooth;
    return data;
  }
}

class AppointmentServiceToPatientResponses {
  String? name;

  AppointmentServiceToPatientResponses({this.name});

  AppointmentServiceToPatientResponses.fromJson(Map<String, dynamic> json) {
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    return data;
  }
}
