import 'package:dent_app_mobile/generated/locale_keys.g.dart';

enum RecordType {
  treatment(LocaleKeys.record_type_treatment, 'TREATMENT'),
  consultation(LocaleKeys.record_type_consultation, 'CONSULTATION'),
  diagnostics(LocaleKeys.record_type_diagnostics, 'DIAGNOSTICS'),
  inspection(LocaleKeys.record_type_inspection, 'INSPECTION'),
  implantation(LocaleKeys.record_type_implantation, 'IMPLANTATION'),
  orthopedics(LocaleKeys.record_type_orthopedics, 'ORTHOPEDICS'),
  orthodontics(LocaleKeys.record_type_orthodontics, 'ORTHODONTICS'),
  periodontology(LocaleKeys.record_type_periodontology, 'PERIODONTICS'),
  surgery(LocaleKeys.record_type_surgery, 'SURGERY'),
  firstDoctorAppointment(
    LocaleKeys.record_type_first_doctor_appointment,
    'FIRST_DOCTOR_APPOINTMENT',
  );

  final String displayName;
  final String key;

  const RecordType(this.displayName, this.key);

  // from string
  static RecordType fromString(String value) {
    return RecordType.values.firstWhere(
      (e) => e.name.toUpperCase() == value,
      orElse: () => RecordType.treatment,
    );
  }
}
