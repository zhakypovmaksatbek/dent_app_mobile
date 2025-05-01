class AppointmentModel {
  UserResponse? userResponse;
  UserResponse? patientResponse;
  String? startDate;
  String? appointmentStatus;
  String? complaints;
  String? xRayDescription;
  String? oldDiseases;
  String? appDescription;
  String? room;

  AppointmentModel({
    this.userResponse,
    this.patientResponse,
    this.startDate,
    this.appointmentStatus,
    this.complaints,
    this.xRayDescription,
    this.oldDiseases,
    this.appDescription,
    this.room,
  });

  AppointmentModel.fromJson(Map<String, dynamic> json) {
    userResponse =
        json['userResponse'] != null
            ? UserResponse.fromJson(json['userResponse'])
            : null;
    patientResponse =
        json['patientResponse'] != null
            ? UserResponse.fromJson(json['patientResponse'])
            : null;
    startDate = json['startDate'];
    appointmentStatus = json['appointmentStatus'];
    complaints = json['complaints'];
    xRayDescription = json['xRayDescription'];
    oldDiseases = json['oldDiseases'];
    appDescription = json['AppDescription'];
    room = json['room'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (userResponse != null) {
      data['userResponse'] = userResponse!.toJson();
    }
    if (patientResponse != null) {
      data['patientResponse'] = patientResponse!.toJson();
    }
    data['startDate'] = startDate;
    data['appointmentStatus'] = appointmentStatus;
    data['complaints'] = complaints;
    data['xRayDescription'] = xRayDescription;
    data['oldDiseases'] = oldDiseases;
    data['AppDescription'] = appDescription;
    data['room'] = room;
    return data;
  }
}

class UserResponse {
  int? id;
  String? firstName;
  String? lastName;

  UserResponse({this.id, this.firstName, this.lastName});

  UserResponse.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    firstName = json['firstName'];
    lastName = json['lastName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['firstName'] = firstName;
    data['lastName'] = lastName;
    return data;
  }
}
