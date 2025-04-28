import 'package:dent_app_mobile/models/pagination_model.dart';

class DebtorDataModel extends PaginationModel<DebtorModel> {
  DebtorDataModel.fromJson(Map<String, dynamic> json)
    : super.fromJson(json, (item) => DebtorModel.fromJson(item));
}

class DebtorModel {
  final int? id;
  final String? fullName;
  final String? phoneNumber;
  final double? payed;
  final double? debt;

  DebtorModel({
    this.id,
    this.fullName,
    this.phoneNumber,
    this.payed,
    this.debt,
  });

  factory DebtorModel.fromJson(Map<String, dynamic> json) {
    return DebtorModel(
      id: json['id'],
      fullName: json['fullName'],
      phoneNumber: json['phoneNumber'],
      payed: json['payed']?.toDouble(),
      debt: json['debt']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'payed': payed,
      'debt': debt,
    };
  }
}
