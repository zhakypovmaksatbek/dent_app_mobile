import 'package:dent_app_mobile/generated/locale_keys.g.dart';

enum Gender {
  male(LocaleKeys.forms_male_m),
  female(LocaleKeys.forms_female_f);

  const Gender(this.displayName);

  final String displayName;

  factory Gender.fromString(String value) {
    return Gender.values.firstWhere(
      (e) => e.name.toUpperCase() == value,
      orElse: () => male,
    );
  }
}
