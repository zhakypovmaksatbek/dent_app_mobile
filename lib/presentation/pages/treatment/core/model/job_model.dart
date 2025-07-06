import 'package:dent_app_mobile/models/diagnosis/condition_model.dart';
import 'package:dent_app_mobile/models/diagnosis/diagnosis_model.dart';
import 'package:dent_app_mobile/models/service/service_model.dart';
import 'package:dent_app_mobile/presentation/pages/treatment/utils/tooth_type.dart';

class JobModel {
  final String id;
  final String toothId;
  final Map<ServiceItem, int> servicesWithCount;
  final Conditions condition;
  final ToothType toothType;
  final List<DiagnosisModel> diagnosis;
  final String? surveyPlan;
  final String? recommendation;
  final String? treatment;

  JobModel({
    required this.id,
    required this.toothId,
    required this.servicesWithCount,
    required this.condition,
    required this.toothType,
    required this.diagnosis,
    this.surveyPlan,
    this.recommendation,
    this.treatment,
  });

  // Convenience getters
  List<ServiceItem> get services => servicesWithCount.keys.toList();
  int get totalServiceCount =>
      servicesWithCount.values.fold(0, (sum, count) => sum + count);
  double get totalPrice => servicesWithCount.entries.fold(
    0.0,
    (sum, entry) => sum + (entry.key.price ?? 0) * entry.value,
  );

  /// Returns service IDs repeated according to their count
  /// Example: if service 1 has count 2, service 2 has count 3
  /// Returns: [1, 1, 2, 2, 2]
  List<int> get serviceIdsWithCount {
    final List<int> result = [];
    for (final entry in servicesWithCount.entries) {
      final serviceId = entry.key.id;
      final count = entry.value;

      if (serviceId != null) {
        // Add the service ID 'count' times
        for (int i = 0; i < count; i++) {
          result.add(serviceId);
        }
      }
    }
    return result;
  }

  List<int> get diagnosisIds {
    return diagnosis.map((e) => e.id!).toList();
  }

  JobModel copyWith({
    String? id,
    String? toothId,
    Map<ServiceItem, int>? servicesWithCount,
    Conditions? condition,
    ToothType? toothType,
    List<DiagnosisModel>? diagnosis,
    String? surveyPlan,
    String? recommendation,
    String? treatment,
  }) {
    return JobModel(
      id: id ?? this.id,
      toothId: toothId ?? this.toothId,
      servicesWithCount: servicesWithCount ?? this.servicesWithCount,
      condition: condition ?? this.condition,
      toothType: toothType ?? this.toothType,
      diagnosis: diagnosis ?? this.diagnosis,
      surveyPlan: surveyPlan ?? this.surveyPlan,
      recommendation: recommendation ?? this.recommendation,
      treatment: treatment ?? this.treatment,
    );
  }
}
