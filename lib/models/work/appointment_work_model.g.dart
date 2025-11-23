// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'appointment_work_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppointmentWorkModel _$AppointmentWorkModelFromJson(
  Map<String, dynamic> json,
) => AppointmentWorkModel(
  workId: (json['workId'] as num).toInt(),
  toothResponse: json['toothResponse'] == null
      ? null
      : ToothResponse.fromJson(json['toothResponse'] as Map<String, dynamic>),
  serviceResponses: (json['serviceResponses'] as List<dynamic>?)
      ?.map((e) => ServiceResponse.fromJson(e as Map<String, dynamic>))
      .toList(),
  diagnosesResponse: (json['diagnosesResponse'] as List<dynamic>?)
      ?.map((e) => DiagnosesResponse.fromJson(e as Map<String, dynamic>))
      .toList(),
  surveyPlan: json['surveyPlan'] as String?,
  treatment: json['treatment'] as String?,
  recommendations: json['recommendations'] as String?,
);

Map<String, dynamic> _$AppointmentWorkModelToJson(
  AppointmentWorkModel instance,
) => <String, dynamic>{
  'workId': instance.workId,
  'toothResponse': instance.toothResponse,
  'serviceResponses': instance.serviceResponses,
  'diagnosesResponse': instance.diagnosesResponse,
  'surveyPlan': instance.surveyPlan,
  'treatment': instance.treatment,
  'recommendations': instance.recommendations,
};

DiagnosesResponse _$DiagnosesResponseFromJson(Map<String, dynamic> json) =>
    DiagnosesResponse(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
    );

Map<String, dynamic> _$DiagnosesResponseToJson(DiagnosesResponse instance) =>
    <String, dynamic>{'id': instance.id, 'name': instance.name};

ServiceResponse _$ServiceResponseFromJson(Map<String, dynamic> json) =>
    ServiceResponse(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      price: (json['price'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ServiceResponseToJson(ServiceResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'price': instance.price,
    };

ToothResponse _$ToothResponseFromJson(Map<String, dynamic> json) =>
    ToothResponse(
      toothNumber: (json['toothNumber'] as num?)?.toInt(),
      main: json['main'] == null
          ? null
          : Jow.fromJson(json['main'] as Map<String, dynamic>),
      jow: json['jow'] == null
          ? null
          : Jow.fromJson(json['jow'] as Map<String, dynamic>),
      innerToothResponse: json['innerToothResponse'] == null
          ? null
          : InnerToothResponse.fromJson(
              json['innerToothResponse'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$ToothResponseToJson(ToothResponse instance) =>
    <String, dynamic>{
      'toothNumber': instance.toothNumber,
      'main': instance.main,
      'jow': instance.jow,
      'innerToothResponse': instance.innerToothResponse,
    };

InnerToothResponse _$InnerToothResponseFromJson(Map<String, dynamic> json) =>
    InnerToothResponse(
      right: json['right'] == null
          ? null
          : Jow.fromJson(json['right'] as Map<String, dynamic>),
      left: json['left'] == null
          ? null
          : Jow.fromJson(json['left'] as Map<String, dynamic>),
      top: json['top'] == null
          ? null
          : Jow.fromJson(json['top'] as Map<String, dynamic>),
      bottom: json['bottom'] == null
          ? null
          : Jow.fromJson(json['bottom'] as Map<String, dynamic>),
      centerRight: json['centerRight'] == null
          ? null
          : Jow.fromJson(json['centerRight'] as Map<String, dynamic>),
      centerLeft: json['centerLeft'] == null
          ? null
          : Jow.fromJson(json['centerLeft'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$InnerToothResponseToJson(InnerToothResponse instance) =>
    <String, dynamic>{
      'right': instance.right,
      'left': instance.left,
      'top': instance.top,
      'bottom': instance.bottom,
      'centerRight': instance.centerRight,
      'centerLeft': instance.centerLeft,
    };

Jow _$JowFromJson(Map<String, dynamic> json) =>
    Jow(name: json['name'] as String?, color: json['color'] as String?);

Map<String, dynamic> _$JowToJson(Jow instance) => <String, dynamic>{
  'name': instance.name,
  'color': instance.color,
};
