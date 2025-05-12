class ToothTreatment {
  final String id;
  final String toothId;
  final String treatmentType;
  final String description;
  final DateTime date;
  final String? patientId;

  ToothTreatment({
    required this.id,
    required this.toothId,
    required this.treatmentType,
    required this.description,
    required this.date,
    this.patientId,
  });

  // Create from map (JSON deserialization)
  factory ToothTreatment.fromJson(Map<String, dynamic> json) {
    return ToothTreatment(
      id: json['id'],
      toothId: json['toothId'],
      treatmentType: json['treatmentType'],
      description: json['description'],
      date: DateTime.parse(json['date']),
      patientId: json['patientId'],
    );
  }

  // Convert to map (JSON serialization)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'toothId': toothId,
      'treatmentType': treatmentType,
      'description': description,
      'date': date.toIso8601String(),
      'patientId': patientId,
    };
  }

  // Create a copy with updated fields
  ToothTreatment copyWith({
    String? id,
    String? toothId,
    String? treatmentType,
    String? description,
    DateTime? date,
    String? patientId,
  }) {
    return ToothTreatment(
      id: id ?? this.id,
      toothId: toothId ?? this.toothId,
      treatmentType: treatmentType ?? this.treatmentType,
      description: description ?? this.description,
      date: date ?? this.date,
      patientId: patientId ?? this.patientId,
    );
  }
}
