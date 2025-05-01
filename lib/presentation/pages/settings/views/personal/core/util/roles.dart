import 'package:dent_app_mobile/generated/locale_keys.g.dart';

enum Role {
  admin(LocaleKeys.roles_admin),
  doctor(LocaleKeys.roles_doctor),
  developer(LocaleKeys.roles_developer),
  mortal(LocaleKeys.roles_mortal),
  investor(LocaleKeys.roles_investor),
  manager(LocaleKeys.roles_manager);

  const Role(this.displayName);
  final String displayName;

  // from string
  static Role fromString(String value) {
    return Role.values.firstWhere(
      (e) => e.displayName.toUpperCase() == value.toUpperCase(),
    );
  }
}
