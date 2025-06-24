class PaymentModel {
  int? discount;
  String? discountType;
  String? typeOfPayment;
  int? sum;
  bool? check;

  PaymentModel({
    this.discount,
    this.discountType,
    this.typeOfPayment,
    this.sum,
    this.check,
  });

  PaymentModel.fromJson(Map<String, dynamic> json) {
    discount = json['discount'];
    discountType = json['discountType'];
    typeOfPayment = json['typeOfPayment'];
    sum = json['sum'];
    check = json['check'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['discount'] = discount;
    data['discountType'] = discountType;
    data['typeOfPayment'] = typeOfPayment;
    data['sum'] = sum;
    data['check'] = check;
    return data;
  }
}
