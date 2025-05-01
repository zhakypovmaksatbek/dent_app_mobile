class UserDetailModel {
  int? id;
  String? firstName;
  String? lastName;
  String? patronymic;
  String? gender;
  String? birthDate;
  String? phoneNumber;
  String? phoneNumber2;
  String? email;
  String? doctorAvatar;
  PayrollCalculationsResponse? payrollCalculationsResponse;
  bool? isVisibilityPhoneNumber;

  UserDetailModel({
    this.id,
    this.firstName,
    this.lastName,
    this.patronymic,
    this.gender,
    this.birthDate,
    this.phoneNumber,
    this.phoneNumber2,
    this.email,
    this.doctorAvatar,
    this.payrollCalculationsResponse,
    this.isVisibilityPhoneNumber,
  });

  UserDetailModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    firstName = json['firstName'];
    lastName = json['lastName'];
    patronymic = json['patronymic'];
    gender = json['gender'];
    birthDate = json['birthDate'];
    phoneNumber = json['phoneNumber'];
    phoneNumber2 = json['phoneNumber2'];
    email = json['email'];
    doctorAvatar = json['doctorAvatar'];
    payrollCalculationsResponse =
        json['payrollCalculationsResponse'] != null
            ? PayrollCalculationsResponse.fromJson(
              json['payrollCalculationsResponse'],
            )
            : null;
    isVisibilityPhoneNumber = json['isVisibilityPhoneNumber'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['firstName'] = firstName;
    data['lastName'] = lastName;
    data['patronymic'] = patronymic;
    data['gender'] = gender;
    data['birthDate'] = birthDate;
    data['phoneNumber'] = phoneNumber;
    data['phoneNumber2'] = phoneNumber2;
    data['email'] = email;
    data['doctorAvatar'] = doctorAvatar;
    if (payrollCalculationsResponse != null) {
      data['payrollCalculationsResponse'] =
          payrollCalculationsResponse!.toJson();
    }
    data['isVisibilityPhoneNumber'] = isVisibilityPhoneNumber;
    return data;
  }
}

class PayrollCalculationsResponse {
  double? salary;
  String? percentOrFixed;

  PayrollCalculationsResponse({this.salary, this.percentOrFixed});

  PayrollCalculationsResponse.fromJson(Map<String, dynamic> json) {
    salary = json['salary'];
    percentOrFixed = json['percentOrFixed'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['salary'] = salary;
    data['percentOrFixed'] = percentOrFixed;
    return data;
  }
}
