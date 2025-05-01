import 'package:dent_app_mobile/generated/locale_keys.g.dart';

enum RecordType {
  treatment(LocaleKeys.record_type_treatment),
  consultation(LocaleKeys.record_type_consultation),
  diagnostics(LocaleKeys.record_type_diagnostics),
  inspection(LocaleKeys.record_type_inspection),
  implantation(LocaleKeys.record_type_implantation),
  orthopedics(LocaleKeys.record_type_orthopedics),
  orthodontics(LocaleKeys.record_type_orthodontics),
  periodontology(LocaleKeys.record_type_periodontology),
  surgery(LocaleKeys.record_type_surgery),
  firstDoctorAppointment(LocaleKeys.record_type_first_doctor_appointment);

  final String displayName;

  const RecordType(this.displayName);

  // from string
  static RecordType fromString(String value) {
    return RecordType.values.firstWhere(
      (e) => e.name.toUpperCase() == value,
      orElse: () => RecordType.treatment,
    );
  }
}
