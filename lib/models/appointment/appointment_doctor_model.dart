import 'package:dent_app_mobile/models/pagination_model.dart';

class AppointmentDoctorsPaginationModel
    extends PaginationModel<AppointmentDoctorModel> {
  AppointmentDoctorsPaginationModel.fromJson(Map<String, dynamic> json)
    : super.fromJson(json, (item) => AppointmentDoctorModel.fromJson(item));
}

class AppointmentDoctorModel {
  int? userId;
  String? fullName;
  String? avatar;
  List<String>? specialities;
  List<FreeTimeResponses>? freeTimeResponses;

  AppointmentDoctorModel({
    this.userId,
    this.fullName,
    this.avatar,
    this.specialities,
    this.freeTimeResponses,
  });

  AppointmentDoctorModel.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    fullName = json['fullName'];
    avatar = json['avatar'];
    specialities = json['specialities'].cast<String>();
    if (json['freeTimeResponses'] != null) {
      freeTimeResponses = <FreeTimeResponses>[];
      json['freeTimeResponses'].forEach((v) {
        freeTimeResponses!.add(FreeTimeResponses.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['userId'] = userId;
    data['fullName'] = fullName;
    data['avatar'] = avatar;
    data['specialities'] = specialities;
    if (freeTimeResponses != null) {
      data['freeTimeResponses'] =
          freeTimeResponses!.map((v) => v.toJson()).toList();
    }

    return data;
  }
}

class FreeTimeResponses {
  String? startTime;
  String? endTime;

  FreeTimeResponses({this.startTime, this.endTime});

  FreeTimeResponses.fromJson(Map<String, dynamic> json) {
    startTime = json['startTime'];
    endTime = json['endTime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['startTime'] = startTime;
    data['endTime'] = endTime;
    return data;
  }
}
