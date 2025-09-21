import 'package:equatable/equatable.dart';

class PatientShortModel extends Equatable {
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

  @override
  List<Object?> get props => [id, fullName, dateOfBirthday];

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PatientShortModel &&
        other.id == id &&
        other.fullName == fullName &&
        other.dateOfBirthday == dateOfBirthday;
  }

  @override
  int get hashCode => Object.hash(id, fullName, dateOfBirthday);

  @override
  String toString() =>
      'PatientShortModel(id: $id, fullName: $fullName, dateOfBirthday: $dateOfBirthday)';
}
