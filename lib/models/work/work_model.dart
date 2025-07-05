class WorkModel {
  int? toothNumber;
  List<int>? serviceIds;
  List<int>? diagnosisId;
  String? surveyPlan;
  String? treatment;
  String? recommendations;
  List<ToothRequests>? toothRequests;

  WorkModel({
    this.toothNumber,
    this.serviceIds,
    this.diagnosisId,
    this.surveyPlan,
    this.treatment,
    this.recommendations,
    this.toothRequests,
  });

  WorkModel.fromJson(Map<String, dynamic> json) {
    toothNumber = json['toothNumber'];
    serviceIds = json['serviceIds'].cast<int>();
    diagnosisId = json['diagnosisId'].cast<int>();
    surveyPlan = json['surveyPlan'];
    treatment = json['treatment'];
    recommendations = json['recommendations'];
    if (json['toothRequests'] != null) {
      toothRequests = <ToothRequests>[];
      json['toothRequests'].forEach((v) {
        toothRequests!.add(ToothRequests.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['toothNumber'] = toothNumber;
    data['serviceIds'] = serviceIds;
    data['diagnosisId'] = diagnosisId;
    data['surveyPlan'] = surveyPlan;
    data['treatment'] = treatment;
    data['recommendations'] = recommendations;
    if (toothRequests != null) {
      data['toothRequests'] = toothRequests!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ToothRequests {
  int? conditionId;
  String? toothType;

  ToothRequests({this.conditionId, this.toothType});

  ToothRequests.fromJson(Map<String, dynamic> json) {
    conditionId = json['conditionId'];
    toothType = json['toothType'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['conditionId'] = conditionId;
    data['toothType'] = toothType;
    return data;
  }
}
