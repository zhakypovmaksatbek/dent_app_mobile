import 'package:dent_app_mobile/models/diagnosis/condition_model.dart';
import 'package:dent_app_mobile/models/diagnosis/diagnosis_model.dart';
import 'package:dent_app_mobile/models/service/service_model.dart';
import 'package:dent_app_mobile/presentation/pages/treatment/utils/tooth_type.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class ConditionService extends ChangeNotifier {
  String? _toothId;
  Conditions? _condition;
  ToothType? _toothType;
  DiagnosisModel? _selectedDiagnosis;
  final Map<ServiceItem, int> _selectedServices = {};

  final List<JobModel> _jobs = [];

  String? get toothId => _toothId;
  Conditions? get condition => _condition;
  ToothType? get toothType => _toothType;
  DiagnosisModel? get selectedDiagnosis => _selectedDiagnosis;
  Map<ServiceItem, int> get selectedServices =>
      Map.unmodifiable(_selectedServices);
  List<ServiceItem> get selectedServicesList => _selectedServices.keys.toList();
  int get totalServicesCount =>
      _selectedServices.values.fold(0, (sum, count) => sum + count);
  List<JobModel> get jobs => _jobs;

  void setToothId(String toothId) {
    _toothId = toothId;
    notifyListeners();
  }

  void addJob() {
    _jobs.add(
      JobModel(
        id: const Uuid().v4(),
        toothId: _toothId!,
        servicesWithCount: Map.from(_selectedServices),
        condition: _condition!,
        toothType: _toothType!,
        diagnosis: _selectedDiagnosis!,
      ),
    );
    removeSelections();
    notifyListeners();
  }

  void removeSelections() {
    _selectedServices.clear();
    _selectedDiagnosis = null;
    _toothType = null;
    _condition = null;
    _toothId = null;
    notifyListeners();
  }

  void setToothType(ToothType toothType) {
    _toothType = toothType;
    notifyListeners();
  }

  void clearToothType() {
    _toothType = null;
    notifyListeners();
  }

  void clearCondition() {
    _condition = null;
    notifyListeners();
  }

  void setCondition(Conditions condition) {
    _condition = condition;
    notifyListeners();
  }

  void setSelectedDiagnosis(DiagnosisModel diagnosis) {
    _selectedDiagnosis = diagnosis;
    notifyListeners();
  }

  void clearSelectedDiagnosis() {
    _selectedDiagnosis = null;
    notifyListeners();
  }

  void addService(ServiceItem service) {
    if (_selectedServices.containsKey(service)) {
      _selectedServices[service] = _selectedServices[service]! + 1;
    } else {
      _selectedServices[service] = 1;
    }
    notifyListeners();
  }

  void removeService(ServiceItem service) {
    if (_selectedServices.containsKey(service)) {
      if (_selectedServices[service]! > 1) {
        _selectedServices[service] = _selectedServices[service]! - 1;
      } else {
        _selectedServices.remove(service);
      }
      notifyListeners();
    }
  }

  void toggleService(ServiceItem service) {
    if (_selectedServices.containsKey(service)) {
      _selectedServices.remove(service);
    } else {
      _selectedServices[service] = 1;
    }
    notifyListeners();
  }

  void setServiceCount(ServiceItem service, int count) {
    if (count <= 0) {
      _selectedServices.remove(service);
    } else {
      _selectedServices[service] = count;
    }
    notifyListeners();
  }

  int getServiceCount(ServiceItem service) {
    return _selectedServices[service] ?? 0;
  }

  bool isServiceSelected(ServiceItem service) {
    return _selectedServices.containsKey(service);
  }

  void clearSelectedServices() {
    _selectedServices.clear();
    notifyListeners();
  }
}

class JobModel {
  final String id;
  final String toothId;
  final Map<ServiceItem, int> servicesWithCount;
  final Conditions condition;
  final ToothType toothType;
  final DiagnosisModel diagnosis;

  JobModel({
    required this.id,
    required this.toothId,
    required this.servicesWithCount,
    required this.condition,
    required this.toothType,
    required this.diagnosis,
  });

  // Convenience getters
  List<ServiceItem> get services => servicesWithCount.keys.toList();
  int get totalServiceCount =>
      servicesWithCount.values.fold(0, (sum, count) => sum + count);
  double get totalPrice => servicesWithCount.entries.fold(
    0.0,
    (sum, entry) => sum + (entry.key.price ?? 0) * entry.value,
  );
}
