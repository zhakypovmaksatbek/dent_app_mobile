import 'package:dent_app_mobile/models/pagination_model.dart';

class PatientDataModel extends PaginationModel<PatientModel> {
  PatientDataModel.fromJson(Map<String, dynamic> json)
    : super.fromJson(json, (item) => PatientModel.fromJson(item));
}

class PatientModel {
  int? id;
  String? fullName;
  String? phoneNumber;
  String? birthDate;
  double? deposit;
  double? payment;
  double? debt;
  String? email;

  PatientModel({
    this.id,
    this.fullName,
    this.phoneNumber,
    this.birthDate,
    this.deposit,
    this.payment,
    this.debt,
    this.email,
  });

  PatientModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    fullName = json['fullName'];
    phoneNumber = json['phoneNumber'];
    birthDate = json['birthDate'];
    deposit = json['deposit']?.toDouble();
    payment = json['payment']?.toDouble();
    debt = json['debt']?.toDouble();
    email = json['email'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['fullName'] = fullName;
    data['phoneNumber'] = phoneNumber;
    data['birthDate'] = birthDate;
    data['deposit'] = deposit;
    data['payment'] = payment;
    data['debt'] = debt;
    data['email'] = email;
    return data;
  }
}

class Pageable {
  Sort? sort;
  int? offset;
  int? pageSize;
  int? pageNumber;
  bool? paged;
  bool? unpaged;

  Pageable({
    this.sort,
    this.offset,
    this.pageSize,
    this.pageNumber,
    this.paged,
    this.unpaged,
  });

  Pageable.fromJson(Map<String, dynamic> json) {
    sort = json['sort'] != null ? Sort.fromJson(json['sort']) : null;
    offset = json['offset'];
    pageSize = json['pageSize'];
    pageNumber = json['pageNumber'];
    paged = json['paged'];
    unpaged = json['unpaged'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (sort != null) {
      data['sort'] = sort!.toJson();
    }
    data['offset'] = offset;
    data['pageSize'] = pageSize;
    data['pageNumber'] = pageNumber;
    data['paged'] = paged;
    data['unpaged'] = unpaged;
    return data;
  }
}

class Sort {
  bool? empty;
  bool? sorted;
  bool? unsorted;

  Sort({this.empty, this.sorted, this.unsorted});

  Sort.fromJson(Map<String, dynamic> json) {
    empty = json['empty'];
    sorted = json['sorted'];
    unsorted = json['unsorted'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['empty'] = empty;
    data['sorted'] = sorted;
    data['unsorted'] = unsorted;
    return data;
  }
}
