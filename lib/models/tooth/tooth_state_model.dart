import 'dart:ui';

class ToothStateModel {
  final String id;
  final Color color;
  final String title;
  final String description;
  final String icdCode;
  final List<String> surfaces;

  ToothStateModel({
    required this.id,
    required this.color,
    required this.title,
    required this.description,
    required this.icdCode,
    this.surfaces = const [],
  });
}

class ToothDiagnosisCategory {
  final String id;
  final String title;
  final Color color;
  final List<ToothStateModel> diagnoses;

  const ToothDiagnosisCategory({
    required this.id,
    required this.title,
    required this.color,
    required this.diagnoses,
  });
}
