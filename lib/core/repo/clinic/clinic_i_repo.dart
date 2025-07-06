import 'package:dent_app_mobile/models/clinic/clinic_model.dart';

abstract class ClinicIRepo {
  Future<ClinicModel> getClinic();
}
