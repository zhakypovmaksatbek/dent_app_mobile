import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';

enum ToothType {
  main(key: 'MAIN'),
  right(key: 'RIGHT'),
  left(key: 'LEFT'),
  top(key: 'TOP'),
  bottom(key: 'BOTTOM'),
  jaw(key: 'JAW'),
  centerRight(key: 'CENTER_RIGHT'),
  centerLeft(key: 'CENTER_LEFT'),
  all(key: 'ALL');

  final String key;

  const ToothType({required this.key});
}

extension ToothTypeExtension on ToothType {
  String get title {
    switch (this) {
      case ToothType.main:
        return LocaleKeys.tooth_main.tr();
      case ToothType.right:
        return LocaleKeys.tooth_right.tr();
      case ToothType.left:
        return LocaleKeys.tooth_left.tr();
      case ToothType.top:
        return LocaleKeys.tooth_top.tr();
      case ToothType.bottom:
        return LocaleKeys.tooth_bottom.tr();
      case ToothType.jaw:
        return LocaleKeys.tooth_jaw.tr();
      case ToothType.centerRight:
        return LocaleKeys.tooth_center_right.tr();
      case ToothType.centerLeft:
        return LocaleKeys.tooth_center_left.tr();
      case ToothType.all:
        return LocaleKeys.tooth_all.tr();
    }
  }
}
