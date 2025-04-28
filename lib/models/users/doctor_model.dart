class PersonalModel {
  String? firstName;
  String? lastName;
  String? patronymic;
  String? gender;
  String? birthDate;
  String? phoneNumber;
  String? phoneNumber2;
  String? email;
  String? password;
  String? role;
  PayrollCalculationsRequest? payrollCalculationsRequest;
  bool? isVisibilityPhoneNumber;

  PersonalModel({
    this.firstName,
    this.lastName,
    this.patronymic,
    this.gender,
    this.birthDate,
    this.phoneNumber,
    this.phoneNumber2,
    this.email,
    this.password,
    this.role,
    this.payrollCalculationsRequest,
    this.isVisibilityPhoneNumber,
  });

  PersonalModel.fromJson(Map<String, dynamic> json) {
    firstName = json['firstName'];
    lastName = json['lastName'];
    patronymic = json['patronymic'];
    gender = json['gender'];
    birthDate = json['birthDate'];
    phoneNumber = json['phoneNumber'];
    phoneNumber2 = json['phoneNumber2'];
    email = json['email'];
    password = json['password'];
    role = json['role'];
    payrollCalculationsRequest =
        json['payrollCalculationsRequest'] != null
            ? PayrollCalculationsRequest.fromJson(
              json['payrollCalculationsRequest'],
            )
            : null;
    isVisibilityPhoneNumber = json['isVisibilityPhoneNumber'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['firstName'] = firstName;
    data['lastName'] = lastName;
    data['patronymic'] = patronymic;
    data['gender'] = gender;
    data['birthDate'] = birthDate;
    data['phoneNumber'] = phoneNumber;
    data['phoneNumber2'] = phoneNumber2;
    data['email'] = email;
    data['password'] = password;
    data['role'] = role;
    if (payrollCalculationsRequest != null) {
      data['payrollCalculationsRequest'] = payrollCalculationsRequest!.toJson();
    }
    data['isVisibilityPhoneNumber'] = isVisibilityPhoneNumber;
    return data;
  }
}

class PayrollCalculationsRequest {
  int? salary;
  SalaryType? percentOrFixed;

  PayrollCalculationsRequest({this.salary, this.percentOrFixed});

  PayrollCalculationsRequest.fromJson(Map<String, dynamic> json) {
    salary = json['salary'];
    percentOrFixed = json['percentOrFixed'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['salary'] = salary;
    data['percentOrFixed'] = percentOrFixed?.name.toUpperCase();
    return data;
  }
}

enum SalaryType { percent, fixed }
