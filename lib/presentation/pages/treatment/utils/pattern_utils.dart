import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/presentation/pages/treatment/core/data/pattern_type.dart';
import 'package:easy_localization/easy_localization.dart';

class PatternUtils {
  static String getTitleForPatternType(PatternType patternType) {
    switch (patternType) {
      case PatternType.complaints:
        return LocaleKeys.appointment_complaints.tr();
      case PatternType.descriptionAndComments:
        return LocaleKeys.report_description_comment.tr();
      case PatternType.previousAndConcomitantDiseases:
        return LocaleKeys.report_transferred_and_related_complaints.tr();
      case PatternType.xRayAndLaboratoryData:
        return LocaleKeys.report_laboratory_and_radiological_data.tr();
      default:
        return '';
    }
  }

  static String getHintTextForPatternType(PatternType patternType) {
    switch (patternType) {
      case PatternType.complaints:
        return 'Additional complaints...';
      case PatternType.descriptionAndComments:
        return 'Enter treatment description and comments...';
      case PatternType.previousAndConcomitantDiseases:
        return '';
      case PatternType.xRayAndLaboratoryData:
        return '';
      default:
        return '';
    }
  }
}
