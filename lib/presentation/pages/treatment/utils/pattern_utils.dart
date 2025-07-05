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
      case PatternType.surveyPlan:
        return LocaleKeys.forms_survey_plan.tr();
      case PatternType.recommendation:
        return LocaleKeys.forms_recommendation.tr();
      case PatternType.treatment:
        return LocaleKeys.forms_treatment.tr();
    }
  }

  static String getHintTextForPatternType(PatternType patternType) {
    switch (patternType) {
      case PatternType.complaints:
        return LocaleKeys.forms_complaints_description.tr();
      case PatternType.descriptionAndComments:
        return LocaleKeys.forms_treatment_description.tr();
      case PatternType.previousAndConcomitantDiseases:
        return '';
      case PatternType.xRayAndLaboratoryData:
        return '';
      case PatternType.surveyPlan:
        return LocaleKeys.forms_survey_plan_description.tr();
      case PatternType.recommendation:
        return LocaleKeys.forms_recommendation_description.tr();
      case PatternType.treatment:
        return LocaleKeys.forms_treatment_description.tr();
    }
  }
}
