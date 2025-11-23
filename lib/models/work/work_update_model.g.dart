// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'work_update_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkUpdateModel _$WorkUpdateModelFromJson(Map<String, dynamic> json) =>
    WorkUpdateModel(
      serviceIds: (json['serviceIds'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      diagnosisId: (json['diagnosisId'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      surveyPlan: json['surveyPlan'] as String?,
      treatment: json['treatment'] as String?,
      recommendations: json['recommendations'] as String?,
    );

Map<String, dynamic> _$WorkUpdateModelToJson(WorkUpdateModel instance) =>
    <String, dynamic>{
      'serviceIds': instance.serviceIds,
      'diagnosisId': instance.diagnosisId,
      'surveyPlan': instance.surveyPlan,
      'treatment': instance.treatment,
      'recommendations': instance.recommendations,
    };
