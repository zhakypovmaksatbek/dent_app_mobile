class PatientDetailModel {
  int? id;
  String? firstName;
  String? lastName;
  String? patronymic;
  String? gender;
  String? birthDate;
  String? phoneNumber;
  String? phoneNumber2;
  String? email;
  String? passportNumber;
  String? peculiarities;
  bool? attention;
  double? deposit;
  double? debt;
  String? createdAt;
  double? payment;
  int? totalAppointment;
  AppointmentLastResponseModel? appointmentLastResponse;
  String? fromWhere;

  PatientDetailModel({
    this.id,
    this.firstName,
    this.lastName,
    this.patronymic,
    this.gender,
    this.birthDate,
    this.phoneNumber,
    this.phoneNumber2,
    this.email,
    this.passportNumber,
    this.peculiarities,
    this.attention,
    this.deposit,
    this.debt,
    this.createdAt,
    this.payment,
    this.totalAppointment,
    this.appointmentLastResponse,
    this.fromWhere,
  });

  PatientDetailModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    firstName = json['firstName'];
    lastName = json['lastName'];
    patronymic = json['patronymic'];
    gender = json['gender'];
    birthDate = json['birthDate'];
    phoneNumber = json['phoneNumber'];
    phoneNumber2 = json['phoneNumber2'];
    email = json['email'];
    passportNumber = json['passportNumber'];
    peculiarities = json['peculiarities'];
    attention = json['attention'];
    deposit = json['deposit']?.toDouble();
    debt = json['debt']?.toDouble();
    createdAt = json['createdAt'];
    payment = json['payment']?.toDouble();
    totalAppointment = json['totalAppointment']?.toInt();
    appointmentLastResponse =
        json['appointmentLastResponse'] != null
            ? AppointmentLastResponseModel.fromJson(
              json['appointmentLastResponse'],
            )
            : null;
    fromWhere = json['fromWhere'];
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
    data['passportNumber'] = passportNumber;
    data['peculiarities'] = peculiarities;
    data['attention'] = attention;
    data['deposit'] = deposit;
    data['debt'] = debt;
    data['createdAt'] = createdAt;
    data['payment'] = payment;
    data['totalAppointment'] = totalAppointment;
    if (appointmentLastResponse != null) {
      data['appointmentLastResponse'] = appointmentLastResponse!.toJson();
    }
    data['fromWhere'] = fromWhere;
    return data;
  }
}

class AppointmentLastResponseModel {
  int? appointmentId;
  String? appointmentCreateAt;

  AppointmentLastResponseModel({this.appointmentId, this.appointmentCreateAt});

  AppointmentLastResponseModel.fromJson(Map<String, dynamic> json) {
    appointmentId = json['appointmentId'];
    appointmentCreateAt = json['appointmentCreateAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['appointmentId'] = appointmentId;
    data['appointmentCreateAt'] = appointmentCreateAt;
    return data;
  }
}
