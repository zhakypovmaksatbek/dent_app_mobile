class CalendarAppointmentModel {
  int? appointmentId;
  String? startTime;
  String? endTime;
  int? patientId;
  String? patientFirsName;
  String? patientLastName;
  String? patientPhoneNumber;
  String? patientPhoneNumber2;
  bool? patientAttention;
  int? doctorId;
  String? doctorFirsName;
  String? doctorLastName;
  String? appointmentStatus;
  String? recordType;
  String? description;
  int? roomId;
  String? room;

  CalendarAppointmentModel({
    this.appointmentId,
    this.startTime,
    this.endTime,
    this.patientId,
    this.patientFirsName,
    this.patientLastName,
    this.patientPhoneNumber,
    this.patientPhoneNumber2,
    this.patientAttention,
    this.doctorId,
    this.doctorFirsName,
    this.doctorLastName,
    this.appointmentStatus,
    this.recordType,
    this.description,
    this.roomId,
    this.room,
  });

  CalendarAppointmentModel.fromJson(Map<String, dynamic> json) {
    appointmentId = json['appointmentId'];
    startTime = json['startTime'];
    endTime = json['endTime'];
    patientId = json['patientId'];
    patientFirsName = json['patientFirsName'];
    patientLastName = json['patientLastName'];
    patientPhoneNumber = json['patientPhoneNumber'];
    patientPhoneNumber2 = json['patientPhoneNumber2'];
    patientAttention = json['patientAttention'];
    doctorId = json['doctorId'];
    doctorFirsName = json['doctorFirsName'];
    doctorLastName = json['doctorLastName'];
    appointmentStatus = json['appointmentStatus'];
    recordType = json['recordType'];
    description = json['description'];
    roomId = json['roomId'];
    room = json['room'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['appointmentId'] = appointmentId;
    data['startTime'] = startTime;
    data['endTime'] = endTime;
    data['patientId'] = patientId;
    data['patientFirsName'] = patientFirsName;
    data['patientLastName'] = patientLastName;
    data['patientPhoneNumber'] = patientPhoneNumber;
    data['patientPhoneNumber2'] = patientPhoneNumber2;
    data['patientAttention'] = patientAttention;
    data['doctorId'] = doctorId;
    data['doctorFirsName'] = doctorFirsName;
    data['doctorLastName'] = doctorLastName;
    data['appointmentStatus'] = appointmentStatus;
    data['recordType'] = recordType;
    data['description'] = description;
    data['roomId'] = roomId;
    data['room'] = room;
    return data;
  }
}
