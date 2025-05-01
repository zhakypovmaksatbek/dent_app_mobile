class AppointmentCommentModel {
  String? appointmentStatus;
  String? description;
  String? complaints;
  String? oldDiseases;
  String? xRayAndLaboratoryDescription;

  AppointmentCommentModel({
    this.appointmentStatus,
    this.description,
    this.complaints,
    this.oldDiseases,
    this.xRayAndLaboratoryDescription,
  });

  AppointmentCommentModel.fromJson(Map<String, dynamic> json) {
    appointmentStatus = json['appointmentStatus'];
    description = json['description'];
    complaints = json['complaints'];
    oldDiseases = json['oldDiseases'];
    xRayAndLaboratoryDescription = json['xRayAndLaboratoryDescription'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['appointmentStatus'] = appointmentStatus;
    data['description'] = description;
    data['complaints'] = complaints;
    data['oldDiseases'] = oldDiseases;
    data['xRayAndLaboratoryDescription'] = xRayAndLaboratoryDescription;
    return data;
  }
}
