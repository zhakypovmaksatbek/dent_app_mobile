import 'package:dent_app_mobile/presentation/theme/colors/color_constants.dart';
import 'package:flutter/material.dart';

class ConditionModel {
  String? code;
  String? codeName;
  String? codeDescription;
  List<Conditions>? conditions;

  ConditionModel({
    this.code,
    this.codeName,
    this.codeDescription,
    this.conditions,
  });

  ConditionModel.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    codeName = json['codeName'];
    codeDescription = json['codeDescription'];
    if (json['conditions'] != null) {
      conditions = <Conditions>[];
      json['conditions'].forEach((v) {
        conditions!.add(Conditions.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['code'] = code;
    data['codeName'] = codeName;
    data['codeDescription'] = codeDescription;
    if (conditions != null) {
      data['conditions'] = conditions!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Conditions {
  int? id;
  String? name;
  Color? color;
  String? code;

  Conditions({this.id, this.name, this.color, this.code});

  Conditions.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    code = json['code'];
    // Generate color based on code
    if (code != null) {
      color = ConditionCategoryExtension.fromString(code!).color();
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    if (color != null) {
      // Convert Color to hex string
      data['color'] =
          '#${color!.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}';
    }
    data['code'] = code;
    return data;
  }

  // generate color
}

enum ConditionCategory { k02, k04, k08, s02, z01, z96, z98 }

extension ConditionCategoryExtension on ConditionCategory {
  //from string to condition type
  static ConditionCategory fromString(String type) {
    return ConditionCategory.values.firstWhere(
      (e) => e.name.toUpperCase() == type,
      orElse: () => ConditionCategory.k02,
    );
  }

  // generate color from condition type
  Color color() {
    switch (this) {
      case ConditionCategory.k02:
        return AppColors.k02;
      case ConditionCategory.k04:
        return AppColors.k05;
      case ConditionCategory.k08:
        return AppColors.k08;
      case ConditionCategory.s02:
        return AppColors.s02;
      case ConditionCategory.z01:
        return AppColors.z01;
      case ConditionCategory.z96:
        return AppColors.z96;
      case ConditionCategory.z98:
        return AppColors.z98;
    }
  }
}
