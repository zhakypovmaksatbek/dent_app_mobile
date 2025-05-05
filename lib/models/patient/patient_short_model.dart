class PatientShortModel {
  int? id;
  String? fullName;
  String? dateOfBirthday;

  PatientShortModel({this.id, this.fullName, this.dateOfBirthday});

  PatientShortModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    fullName = json['fullName'];
    dateOfBirthday = json['dateOfBirthday'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['fullName'] = fullName;
    data['dateOfBirthday'] = dateOfBirthday;
    return data;
  }
}
