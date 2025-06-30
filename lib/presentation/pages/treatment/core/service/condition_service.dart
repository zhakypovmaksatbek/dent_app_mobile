import 'package:dent_app_mobile/models/diagnosis/condition_model.dart';
import 'package:dent_app_mobile/models/diagnosis/diagnosis_model.dart';
import 'package:dent_app_mobile/models/service/service_model.dart';
import 'package:dent_app_mobile/presentation/pages/treatment/utils/tooth_type.dart';
import 'package:flutter/material.dart';

class ConditionService extends ChangeNotifier {
  Conditions? _condition;
  ToothType? _toothType;
  DiagnosisModel? _selectedDiagnosis;
  ServiceItem? _selectedService;

  Conditions? get condition => _condition;
  ToothType? get toothType => _toothType;
  DiagnosisModel? get selectedDiagnosis => _selectedDiagnosis;
  ServiceItem? get selectedService => _selectedService;

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

  void setSelectedService(ServiceItem service) {
    _selectedService = service;
    notifyListeners();
  }

  void clearSelectedService() {
    _selectedService = null;
    notifyListeners();
  }
}
