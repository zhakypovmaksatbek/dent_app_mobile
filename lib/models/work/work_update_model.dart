import 'package:json_annotation/json_annotation.dart';

part 'work_update_model.g.dart';

@JsonSerializable()
class WorkUpdateModel {
  @JsonKey(name: "serviceIds")
  List<int>? serviceIds;
  @JsonKey(name: "diagnosisId")
  List<int>? diagnosisId;
  @JsonKey(name: "surveyPlan")
  String? surveyPlan;
  @JsonKey(name: "treatment")
  String? treatment;
  @JsonKey(name: "recommendations")
  String? recommendations;

  WorkUpdateModel({
    required this.serviceIds,
    required this.diagnosisId,
    required this.surveyPlan,
    required this.treatment,
    required this.recommendations,
  });

  WorkUpdateModel copyWith({
    List<int>? serviceIds,
    List<int>? diagnosisId,
    String? surveyPlan,
    String? treatment,
    String? recommendations,
  }) => WorkUpdateModel(
    serviceIds: serviceIds ?? this.serviceIds,
    diagnosisId: diagnosisId ?? this.diagnosisId,
    surveyPlan: surveyPlan ?? this.surveyPlan,
    treatment: treatment ?? this.treatment,
    recommendations: recommendations ?? this.recommendations,
  );

  factory WorkUpdateModel.fromJson(Map<String, dynamic> json) =>
      _$WorkUpdateModelFromJson(json);

  Map<String, dynamic> toJson() => _$WorkUpdateModelToJson(this);
}
