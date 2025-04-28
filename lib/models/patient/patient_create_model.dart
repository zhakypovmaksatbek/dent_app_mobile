class PatientCreateModel {
  String? firstName;
  String? lastName;
  String? patronymic;
  String? gender;
  String? birthDate;
  String? phoneNumber;
  String? phoneNumber2;
  String? email;
  String? passportNumber;
  String? fromWhere;

  PatientCreateModel({
    this.firstName,
    this.lastName,
    this.patronymic,
    this.gender,
    this.birthDate,
    this.phoneNumber,
    this.phoneNumber2,
    this.email,
    this.passportNumber,
    this.fromWhere,
  });

  PatientCreateModel.fromJson(Map<String, dynamic> json) {
    firstName = json['firstName'];
    lastName = json['lastName'];
    patronymic = json['patronymic'];
    gender = json['gender'];
    birthDate = json['birthDate'];
    phoneNumber = json['phoneNumber'];
    phoneNumber2 = json['phoneNumber2'];
    email = json['email'];
    passportNumber = json['passportNumber'];
    fromWhere = json['fromWhere'];
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
    data['passportNumber'] = passportNumber;
    data['fromWhere'] = fromWhere;
    return data;
  }
}
