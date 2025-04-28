class HeartbeatsModel {
  int? countPatients;
  ServiceMade? serviceMade;
  ServiceMade? appointmentMade;
  WorkingHours? workingHours;
  List<InfographicResponses>? infographicResponses;
  List<QuantityServiceByUserResponses>? quantityServiceByUserResponses;
  List<QuantityServiceByUserResponses>? quantityByServiceResponses;

  HeartbeatsModel({
    this.countPatients,
    this.serviceMade,
    this.appointmentMade,
    this.workingHours,
    this.infographicResponses,
    this.quantityServiceByUserResponses,
    this.quantityByServiceResponses,
  });

  HeartbeatsModel.fromJson(Map<String, dynamic> json) {
    countPatients = json['countPatients'];
    serviceMade =
        json['serviceMade'] != null
            ? ServiceMade.fromJson(json['serviceMade'])
            : null;
    appointmentMade =
        json['appointmentMade'] != null
            ? ServiceMade.fromJson(json['appointmentMade'])
            : null;
    workingHours =
        json['workingHours'] != null
            ? WorkingHours.fromJson(json['workingHours'])
            : null;
    if (json['infographicResponses'] != null) {
      infographicResponses = <InfographicResponses>[];
      json['infographicResponses'].forEach((v) {
        infographicResponses!.add(InfographicResponses.fromJson(v));
      });
    }
    if (json['quantityServiceByUserResponses'] != null) {
      quantityServiceByUserResponses = <QuantityServiceByUserResponses>[];
      json['quantityServiceByUserResponses'].forEach((v) {
        quantityServiceByUserResponses!.add(
          QuantityServiceByUserResponses.fromJson(v),
        );
      });
    }
    if (json['quantityByServiceResponses'] != null) {
      quantityByServiceResponses = <QuantityServiceByUserResponses>[];
      json['quantityByServiceResponses'].forEach((v) {
        quantityByServiceResponses!.add(
          QuantityServiceByUserResponses.fromJson(v),
        );
      });
    }
  }
}

class ServiceMade {
  String? current;
  String? difference;
  bool? exceeds;

  ServiceMade({this.current, this.difference, this.exceeds});

  ServiceMade.fromJson(Map<String, dynamic> json) {
    current = json['current']?.toString();
    difference = json['difference']?.toString();
    exceeds = json['exceeds'];
  }
}

class WorkingHours {
  String? current;
  String? difference;
  bool? exceeds;

  WorkingHours({this.current, this.difference, this.exceeds});

  WorkingHours.fromJson(Map<String, dynamic> json) {
    current = json['current'];
    difference = json['difference'];
    exceeds = json['exceeds'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['current'] = current;
    data['difference'] = difference;
    data['exceeds'] = exceeds;
    return data;
  }
}

class InfographicResponses {
  String? day;
  int? quantity;

  InfographicResponses({this.day, this.quantity});

  InfographicResponses.fromJson(Map<String, dynamic> json) {
    day = json['day']?.toString();
    quantity = json['quantity'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['day'] = day;
    data['quantity'] = quantity;
    return data;
  }
}

class QuantityServiceByUserResponses {
  String? label;
  double? value;

  QuantityServiceByUserResponses({this.label, this.value});

  QuantityServiceByUserResponses.fromJson(Map<String, dynamic> json) {
    label = json['label'];
    value = json['value']?.toDouble();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['label'] = label;
    data['value'] = value;
    return data;
  }
}
