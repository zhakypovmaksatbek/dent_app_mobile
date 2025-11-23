import 'package:json_annotation/json_annotation.dart';

part 'appointment_work_model.g.dart';

@JsonSerializable()
class AppointmentWorkModel {
  @JsonKey(name: "workId")
  int workId;
  @JsonKey(name: "toothResponse")
  ToothResponse? toothResponse;
  @JsonKey(name: "serviceResponses")
  List<ServiceResponse>? serviceResponses;
  @JsonKey(name: "diagnosesResponse")
  List<DiagnosesResponse>? diagnosesResponse;
  @JsonKey(name: "surveyPlan")
  String? surveyPlan;
  @JsonKey(name: "treatment")
  String? treatment;
  @JsonKey(name: "recommendations")
  String? recommendations;

  AppointmentWorkModel({
    required this.workId,
    required this.toothResponse,
    required this.serviceResponses,
    required this.diagnosesResponse,
    required this.surveyPlan,
    required this.treatment,
    required this.recommendations,
  });

  AppointmentWorkModel copyWith({
    int? workId,
    ToothResponse? toothResponse,
    List<ServiceResponse>? serviceResponses,
    List<DiagnosesResponse>? diagnosesResponse,
    String? surveyPlan,
    String? treatment,
    String? recommendations,
  }) => AppointmentWorkModel(
    workId: workId ?? this.workId,
    toothResponse: toothResponse ?? this.toothResponse,
    serviceResponses: serviceResponses ?? this.serviceResponses,
    diagnosesResponse: diagnosesResponse ?? this.diagnosesResponse,
    surveyPlan: surveyPlan ?? this.surveyPlan,
    treatment: treatment ?? this.treatment,
    recommendations: recommendations ?? this.recommendations,
  );

  factory AppointmentWorkModel.fromJson(Map<String, dynamic> json) =>
      _$AppointmentWorkModelFromJson(json);

  Map<String, dynamic> toJson() => _$AppointmentWorkModelToJson(this);

  List<int> get serviceIdsWithCount {
    final List<int> result = [];
    for (var service in (serviceResponses ?? [])) {
      if (service.id != null) {
        result.add(service.id!);
      }
    }
    return result;
  }

  List<int> get diagnosisIds {
    return (diagnosesResponse ?? []).map((e) => e.id).toList();
  }
}

@JsonSerializable()
class DiagnosesResponse {
  @JsonKey(name: "id")
  int id;
  @JsonKey(name: "name")
  String name;

  DiagnosesResponse({required this.id, required this.name});

  DiagnosesResponse copyWith({int? id, String? name}) =>
      DiagnosesResponse(id: id ?? this.id, name: name ?? this.name);

  factory DiagnosesResponse.fromJson(Map<String, dynamic> json) =>
      _$DiagnosesResponseFromJson(json);

  Map<String, dynamic> toJson() => _$DiagnosesResponseToJson(this);
}

@JsonSerializable()
class ServiceResponse {
  @JsonKey(name: "id")
  int? id;
  @JsonKey(name: "name")
  String? name;
  @JsonKey(name: "price")
  int? price;

  ServiceResponse({required this.id, required this.name, required this.price});

  ServiceResponse copyWith({int? id, String? name, int? price}) =>
      ServiceResponse(
        id: id ?? this.id,
        name: name ?? this.name,
        price: price ?? this.price,
      );

  factory ServiceResponse.fromJson(Map<String, dynamic> json) =>
      _$ServiceResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ServiceResponseToJson(this);
}

@JsonSerializable()
class ToothResponse {
  @JsonKey(name: "toothNumber")
  int? toothNumber;
  @JsonKey(name: "main")
  Jow? main;
  @JsonKey(name: "jow")
  Jow? jow;
  @JsonKey(name: "innerToothResponse")
  InnerToothResponse? innerToothResponse;

  ToothResponse({
    required this.toothNumber,
    required this.main,
    required this.jow,
    required this.innerToothResponse,
  });

  ToothResponse copyWith({
    int? toothNumber,
    Jow? main,
    Jow? jow,
    InnerToothResponse? innerToothResponse,
  }) => ToothResponse(
    toothNumber: toothNumber ?? this.toothNumber,
    main: main ?? this.main,
    jow: jow ?? this.jow,
    innerToothResponse: innerToothResponse ?? this.innerToothResponse,
  );

  factory ToothResponse.fromJson(Map<String, dynamic> json) =>
      _$ToothResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ToothResponseToJson(this);
}

@JsonSerializable()
class InnerToothResponse {
  @JsonKey(name: "right")
  Jow? right;
  @JsonKey(name: "left")
  Jow? left;
  @JsonKey(name: "top")
  Jow? top;
  @JsonKey(name: "bottom")
  Jow? bottom;
  @JsonKey(name: "centerRight")
  Jow? centerRight;
  @JsonKey(name: "centerLeft")
  Jow? centerLeft;

  InnerToothResponse({
    required this.right,
    required this.left,
    required this.top,
    required this.bottom,
    required this.centerRight,
    required this.centerLeft,
  });

  InnerToothResponse copyWith({
    Jow? right,
    Jow? left,
    Jow? top,
    Jow? bottom,
    Jow? centerRight,
    Jow? centerLeft,
  }) => InnerToothResponse(
    right: right ?? this.right,
    left: left ?? this.left,
    top: top ?? this.top,
    bottom: bottom ?? this.bottom,
    centerRight: centerRight ?? this.centerRight,
    centerLeft: centerLeft ?? this.centerLeft,
  );

  factory InnerToothResponse.fromJson(Map<String, dynamic> json) =>
      _$InnerToothResponseFromJson(json);

  Map<String, dynamic> toJson() => _$InnerToothResponseToJson(this);
}

@JsonSerializable()
class Jow {
  @JsonKey(name: "name")
  String? name;
  @JsonKey(name: "color")
  String? color;

  Jow({required this.name, required this.color});

  Jow copyWith({String? name, String? color}) =>
      Jow(name: name ?? this.name, color: color ?? this.color);

  factory Jow.fromJson(Map<String, dynamic> json) => _$JowFromJson(json);

  Map<String, dynamic> toJson() => _$JowToJson(this);
}
