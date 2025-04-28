class LoginModel {
  String? email;
  String? password;

  LoginModel({this.email, this.password});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['email'] = email;
    data['password'] = password;
    return data;
  }
}

class LoginResponseModel {
  int? id;
  String? jwt;
  String? role;
  String? firstName;
  int? clinicId;
  bool? isVisibilityPhoneNumber;

  LoginResponseModel({
    this.id,
    this.jwt,
    this.role,
    this.firstName,
    this.clinicId,
    this.isVisibilityPhoneNumber,
  });

  LoginResponseModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    jwt = json['jwt'];
    role = json['role'];
    firstName = json['firstName'];
    clinicId = json['clinicId'];
    isVisibilityPhoneNumber = json['isVisibilityPhoneNumber'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['jwt'] = jwt;
    data['role'] = role;
    data['firstName'] = firstName;
    data['clinicId'] = clinicId;
    data['isVisibilityPhoneNumber'] = isVisibilityPhoneNumber;
    return data;
  }
}
