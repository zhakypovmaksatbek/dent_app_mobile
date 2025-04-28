import 'package:dent_app_mobile/models/pagination_model.dart';

final class UserDataModel extends PaginationModel<UserModel> {
  UserDataModel.fromJson(Map<String, dynamic> json)
    : super.fromJson(json, (item) => UserModel.fromJson(item));
}

class UserModel {
  int? id;
  String? fullName;
  String? email;
  String? phoneNumber;
  int? salary;
  String? percentOrFixed;
  bool? isVisibilityPhoneNumber;

  UserModel({
    this.id,
    this.fullName,
    this.email,
    this.phoneNumber,
    this.salary,
    this.percentOrFixed,
    this.isVisibilityPhoneNumber,
  });

  UserModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    fullName = json['fullName'];
    email = json['email'];
    phoneNumber = json['phoneNumber'];
    salary = json['salary'];
    percentOrFixed = json['percentOrFixed'];
    isVisibilityPhoneNumber = json['isVisibilityPhoneNumber'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['fullName'] = fullName;
    data['email'] = email;
    data['phoneNumber'] = phoneNumber;
    data['salary'] = salary;
    data['percentOrFixed'] = percentOrFixed;
    data['isVisibilityPhoneNumber'] = isVisibilityPhoneNumber;
    return data;
  }
}
