import 'package:dent_app_mobile/generated/locale_keys.g.dart';

enum SalaryType {
  percent(LocaleKeys.forms_percent),
  fixed(LocaleKeys.forms_fixed);

  const SalaryType(this.displayName);

  final String displayName;

  factory SalaryType.fromString(String value) {
    return SalaryType.values.firstWhere(
      (e) => e.name.toUpperCase() == value,
      orElse: () => percent,
    );
  }
}

extension SalaryTypeExtension on SalaryType {
  String get name => toString().split('.').last;
}
