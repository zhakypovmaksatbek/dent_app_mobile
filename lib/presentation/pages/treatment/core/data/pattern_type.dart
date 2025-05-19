enum PatternType {
  //TREATMENT, SURVEY_PLAN, RECOMMENDATION, COMPLAINTS, DESCRIPTION_AND_COMMENTS, PREVIOUS_AND_CONCOMITANT_DISEASES, X_RAY_AND_LABORATORY_DATA
  treatment(value: 'TREATMENT'),
  surveyPlan(value: 'SURVEY_PLAN'),
  recommendation(value: 'RECOMMENDATION'),
  complaints(value: 'COMPLAINTS'),
  descriptionAndComments(value: 'DESCRIPTION_AND_COMMENTS'),
  previousAndConcomitantDiseases(value: 'PREVIOUS_AND_CONCOMITANT_DISEASES'),
  xRayAndLaboratoryData(value: 'X_RAY_AND_LABORATORY_DATA');

  final String value;

  const PatternType({required this.value});
}
