import 'package:dent_app_mobile/models/pagination_model.dart';

class DiagnosisPaginationModel extends PaginationModel<DiagnosisModel> {
  DiagnosisPaginationModel.fromJson(Map<String, dynamic> json)
    : super.fromJson(json, (item) => DiagnosisModel.fromJson(item));
}

final class DiagnosisModel {
  int? id;
  String? name;

  DiagnosisModel({this.id, this.name});

  DiagnosisModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    return data;
  }
}
