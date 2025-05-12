class DoctorModel {
  int? id;
  String? fullName;
  List<String>? specialities;
  bool? table;

  DoctorModel({this.id, this.fullName, this.specialities, this.table});

  DoctorModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    fullName = json['fullName'];
    specialities = json['specialities'].cast<String>();
    table = json['table'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['fullName'] = fullName;
    data['specialities'] = specialities;
    data['table'] = table;
    return data;
  }
}
