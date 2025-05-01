import 'package:dent_app_mobile/generated/locale_keys.g.dart';

enum Week {
  monday(LocaleKeys.week_monday),
  tuesday(LocaleKeys.week_tuesday),
  wednesday(LocaleKeys.week_wednesday),
  thursday(LocaleKeys.week_thursday),
  friday(LocaleKeys.week_friday),
  saturday(LocaleKeys.week_saturday),
  sunday(LocaleKeys.week_sunday);

  final String displayName;

  const Week(this.displayName);

  factory Week.fromString(String value) {
    return Week.values.firstWhere(
      (e) => e.name.toUpperCase() == value,
      orElse: () => monday,
    );
  }
}
