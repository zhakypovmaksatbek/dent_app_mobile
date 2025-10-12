class DetailReceiptModel {
  int? appointmentId;
  double? totalAmount;
  double? additionalDiscount;
  double? totalAmountPayable;
  double? paid;
  double? debt;
  double? balance;
  List<WorkServicesResponses>? workServicesResponses;

  DetailReceiptModel({
    this.appointmentId,
    this.totalAmount,
    this.additionalDiscount,
    this.totalAmountPayable,
    this.paid,
    this.debt,
    this.balance,
    this.workServicesResponses,
  });

  DetailReceiptModel.fromJson(Map<String, dynamic> json) {
    appointmentId = json['appointmentId'];
    totalAmount = json['totalAmount']?.toDouble();
    additionalDiscount = json['additionalDiscount']?.toDouble();
    totalAmountPayable = json['totalAmountPayable']?.toDouble();
    paid = json['paid']?.toDouble();
    debt = json['debt']?.toDouble();
    balance = json['balance']?.toDouble();
    if (json['workServicesResponses'] != null) {
      workServicesResponses = <WorkServicesResponses>[];
      json['workServicesResponses'].forEach((v) {
        workServicesResponses!.add(WorkServicesResponses.fromJson(v));
      });
    }
  }
}

class WorkServicesResponses {
  String? serviceName;
  int? toothNumber;
  double? price;
  int? numberOfServices;
  double? sum;

  WorkServicesResponses({
    this.serviceName,
    this.toothNumber,
    this.price,
    this.numberOfServices,
    this.sum,
  });

  WorkServicesResponses.fromJson(Map<String, dynamic> json) {
    serviceName = json['serviceName'];
    toothNumber = json['toothNumber'];
    price = json['price']?.toDouble();
    numberOfServices = json['numberOfServices'];
    sum = json['sum']?.toDouble();
  }
}
