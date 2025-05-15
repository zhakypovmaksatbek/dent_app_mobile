import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';

class TeethLocationUtil {
  static TeethLocationModel getDetailedTeethLocation(String toothId) {
    if (toothId.isEmpty) {
      return TeethLocationModel(jaw: '', side: '', ageGroup: '', full: '');
    }

    final int id;
    try {
      id = int.parse(toothId);
    } catch (e) {
      return TeethLocationModel(jaw: '', side: '', ageGroup: '', full: '');
    }

    final String jawPosition;
    final String sidePosition;
    final String ageGroup;

    // Determine jaw position (upper/lower)
    if ((id >= 11 && id <= 28) || (id >= 51 && id <= 65)) {
      jawPosition = LocaleKeys.general_upper_side.tr(); // Üst
    } else if ((id >= 31 && id <= 48) || (id >= 71 && id <= 85)) {
      jawPosition = LocaleKeys.general_lower_side.tr(); // Alt
    } else {
      return TeethLocationModel(jaw: '', side: '', ageGroup: '', full: '');
    }

    // Determine side position (right/left)
    if ((id >= 11 && id <= 18) ||
        (id >= 41 && id <= 48) ||
        (id >= 51 && id <= 55) ||
        (id >= 81 && id <= 85)) {
      sidePosition = LocaleKeys.general_right_side.tr(); // Sağ
    } else if ((id >= 21 && id <= 28) ||
        (id >= 31 && id <= 38) ||
        (id >= 61 && id <= 65) ||
        (id >= 71 && id <= 75)) {
      sidePosition = LocaleKeys.general_left_side.tr(); // Sol
    } else {
      return TeethLocationModel(jaw: '', side: '', ageGroup: '', full: '');
    }

    // Determine age group (adult/child)
    if ((id >= 11 && id <= 48)) {
      ageGroup = LocaleKeys.general_adult.tr(); // Yetişkin
    } else if (id >= 51 && id <= 85) {
      ageGroup = LocaleKeys.general_child.tr(); // Çocuk
    } else {
      return TeethLocationModel(jaw: '', side: '', ageGroup: '', full: '');
    }

    return TeethLocationModel(
      jaw: jawPosition,
      side: sidePosition,
      ageGroup: ageGroup,
      full: '$jawPosition $sidePosition ($ageGroup)',
    );
  }
}

class TeethLocationModel {
  final String jaw;
  final String side;
  final String ageGroup;
  final String full;

  TeethLocationModel({
    required this.jaw,
    required this.side,
    required this.ageGroup,
    required this.full,
  });
}
