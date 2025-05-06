class DocumentModel {
  int? id;
  String? supplier;
  String? description;
  int? totalPrice;
  int? payed;
  int? debt;
  String? dateOfCreated;
  String? paymentStatus;

  DocumentModel({
    this.id,
    this.supplier,
    this.description,
    this.totalPrice,
    this.payed,
    this.debt,
    this.dateOfCreated,
    this.paymentStatus,
  });

  DocumentModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    supplier = json['supplier'];
    description = json['description'];
    totalPrice = json['totalPrice'];
    payed = json['payed'];
    debt = json['debt'];
    dateOfCreated = json['dateOfCreated'];
    paymentStatus = json['paymentStatus'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['supplier'] = supplier;
    data['description'] = description;
    data['totalPrice'] = totalPrice;
    data['payed'] = payed;
    data['debt'] = debt;
    data['dateOfCreated'] = dateOfCreated;
    data['paymentStatus'] = paymentStatus;
    return data;
  }
}
