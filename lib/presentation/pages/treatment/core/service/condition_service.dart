// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:dent_app_mobile/models/diagnosis/condition_model.dart';
import 'package:dent_app_mobile/models/diagnosis/diagnosis_model.dart';
import 'package:dent_app_mobile/models/service/service_model.dart';
import 'package:dent_app_mobile/presentation/pages/treatment/core/data/pattern_type.dart';
import 'package:dent_app_mobile/presentation/pages/treatment/core/model/job_model.dart';
import 'package:dent_app_mobile/presentation/pages/treatment/utils/tooth_type.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class ConditionService extends ChangeNotifier {
  String? _toothId;
  Conditions? _condition;
  ToothType? _toothType;
  final List<DiagnosisModel> _selectedDiagnosis = [];
  final Map<ServiceItem, int> _selectedServices = {};

  final List<JobModel> _jobs = [];

  String? get toothId => _toothId;
  Conditions? get condition => _condition;
  ToothType? get toothType => _toothType;
  List<DiagnosisModel> get selectedDiagnosis => _selectedDiagnosis;
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
        diagnosis: List.from(_selectedDiagnosis), // Create a copy of the list
      ),
    );
    removeSelections();
    notifyListeners();
  }

  void removeSelections() {
    _selectedServices.clear();
    _selectedDiagnosis.clear();
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
    // Initialize the list if it's null
    _condition = condition;
    notifyListeners();
  }

  void setSelectedDiagnosis(DiagnosisModel diagnosis) {
    if (_selectedDiagnosis.any((d) => d.id == diagnosis.id)) {
      _selectedDiagnosis.removeWhere((d) => d.id == diagnosis.id);
    } else {
      _selectedDiagnosis.add(diagnosis);
    }
    notifyListeners();
  }

  void clearSelectedDiagnosis() {
    _selectedDiagnosis.clear();
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

  void removeJob(JobModel job) {
    _jobs.remove(job);
    notifyListeners();
  }

  /// Updates a specific field of a job
  void updateJob(String id, PatternType updateType, String value) {
    try {
      final jobIndex = _jobs.indexWhere((job) => job.id == id);
      if (jobIndex == -1) {
        throw ArgumentError('Job with id $id not found');
      }

      final job = _jobs[jobIndex];

      final updatedJob = switch (updateType) {
        PatternType.surveyPlan => job.copyWith(surveyPlan: value),
        PatternType.recommendation => job.copyWith(recommendation: value),
        PatternType.treatment => job.copyWith(treatment: value),
        _ => throw ArgumentError('Unsupported update type: $updateType'),
      };

      _jobs[jobIndex] = updatedJob;
      notifyListeners();
    } catch (e) {
      // Handle error appropriately - you might want to show a snackbar or log this
      debugPrint('Error updating job: $e');
      rethrow;
    }
  }

  void clearJobs() {
    _jobs.clear();
    notifyListeners();
  }

  // Add helper methods for better condition management

  void toggleCondition(Conditions condition) {
    setCondition(condition);
  }

  void clearAllConditions() {
    _condition = null;
    notifyListeners();
  }
}
