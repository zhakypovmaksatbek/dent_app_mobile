class ReceiptModel {
  int? appointmentId;
  double? totalAmount;
  double? additionalDiscount;
  double? totalAmountPayable;
  double? paid;
  double? debt;
  double? balance;
  List<ServiceQuantityResponses>? serviceQuantityResponses;

  ReceiptModel({
    this.appointmentId,
    this.totalAmount,
    this.additionalDiscount,
    this.totalAmountPayable,
    this.paid,
    this.debt,
    this.balance,
    this.serviceQuantityResponses,
  });

  ReceiptModel.fromJson(Map<String, dynamic> json) {
    appointmentId = json['appointmentId'];
    totalAmount = json['totalAmount']?.toDouble();
    additionalDiscount = json['additionalDiscount']?.toDouble();
    totalAmountPayable = json['totalAmountPayable']?.toDouble();
    paid = json['paid']?.toDouble();
    debt = json['debt']?.toDouble();
    balance = json['balance']?.toDouble();
    if (json['serviceQuantityResponses'] != null) {
      serviceQuantityResponses = <ServiceQuantityResponses>[];
      json['serviceQuantityResponses'].forEach((v) {
        serviceQuantityResponses!.add(ServiceQuantityResponses.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['appointmentId'] = appointmentId;
    data['totalAmount'] = totalAmount;
    data['additionalDiscount'] = additionalDiscount;
    data['totalAmountPayable'] = totalAmountPayable;
    data['paid'] = paid;
    data['debt'] = debt;
    data['balance'] = balance;
    if (serviceQuantityResponses != null) {
      data['serviceQuantityResponses'] =
          serviceQuantityResponses!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ServiceQuantityResponses {
  String? name;
  double? price;
  int? quantity;
  double? sum;

  ServiceQuantityResponses({this.name, this.price, this.quantity, this.sum});

  ServiceQuantityResponses.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    price = json['price']?.toDouble();
    quantity = json['quantity']?.toInt();
    sum = json['sum']?.toDouble();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['price'] = price;
    data['quantity'] = quantity;
    data['sum'] = sum;
    return data;
  }
}
