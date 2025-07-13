class UploadXRayModel {
  int? patientId;
  int? imageId;
  int? appointmentId;
  String? description;
  String? teeth;

  UploadXRayModel({
    this.patientId,
    this.imageId,
    this.appointmentId,
    this.description,
    this.teeth,
  });

  UploadXRayModel.fromJson(Map<String, dynamic> json) {
    patientId = json['patientId'];
    imageId = json['imageId'];
    appointmentId = json['appointmentId'];
    description = json['description'];
    teeth = json['teeth'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['patientId'] = patientId;
    data['imageId'] = imageId;
    data['appointmentId'] = appointmentId;
    data['description'] = description;
    data['teeth'] = teeth;
    return data;
  }
}
