class CreateAppointmentModel {
  int? userId;
  int? patientId;
  String? startDate;
  String? startTime;
  String? endTime;
  String? recordType;
  String? appointmentStatus;
  String? description;
  int? roomId;

  CreateAppointmentModel({
    this.userId,
    this.patientId,
    this.startDate,
    this.startTime,
    this.endTime,
    this.recordType,
    this.appointmentStatus,
    this.description,
    this.roomId,
  });

  CreateAppointmentModel.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    patientId = json['patientId'];
    startDate = json['startDate'];
    startTime = json['startTime'];
    endTime = json['endTime'];
    recordType = json['recordType'];
    appointmentStatus = json['appointmentStatus'];
    description = json['description'];
    roomId = json['roomId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['userId'] = userId;
    data['patientId'] = patientId;
    data['startDate'] = startDate;
    data['startTime'] = startTime;
    data['endTime'] = endTime;
    data['recordType'] = recordType;
    data['appointmentStatus'] = appointmentStatus;
    data['description'] = description;
    data['roomId'] = roomId;
    return data;
  }
}
