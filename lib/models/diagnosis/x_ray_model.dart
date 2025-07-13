class XRayModel {
  int? imageId;
  String? imageCreateAt;
  String? imageLink;
  int? appointmentId;
  String? appointmentCreateAt;
  String? toothToShow;
  String? imageDescription;

  XRayModel({
    this.imageId,
    this.imageCreateAt,
    this.imageLink,
    this.appointmentId,
    this.appointmentCreateAt,
    this.toothToShow,
    this.imageDescription,
  });

  XRayModel.fromJson(Map<String, dynamic> json) {
    imageId = json['imageId'];
    imageCreateAt = json['imageCreateAt'];
    imageLink = json['imageLink'];
    appointmentId = json['appointmentId'];
    appointmentCreateAt = json['appointmentCreateAt'];
    toothToShow = json['toothToShow'];
    imageDescription = json['imageDescription'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['imageId'] = imageId;
    data['imageCreateAt'] = imageCreateAt;
    data['imageLink'] = imageLink;
    data['appointmentId'] = appointmentId;
    data['appointmentCreateAt'] = appointmentCreateAt;
    data['toothToShow'] = toothToShow;
    data['imageDescription'] = imageDescription;
    return data;
  }
}
