import 'package:dent_app_mobile/core/data/app_data_service.dart';
import 'package:dent_app_mobile/core/repo/clinic/clinic_i_repo.dart';
import 'package:dent_app_mobile/core/service/dio_settings.dart';
import 'package:dent_app_mobile/models/clinic/clinic_model.dart';

final class ClinicRepo extends ClinicIRepo {
  final dio = DioService();
  @override
  Future<ClinicModel> getClinic() async {
    final int? clinicId = await AppDataService.instance.getClinicId();
    final response = await dio.get("api/clinics/$clinicId");
    return ClinicModel.fromJson(response.data);
  }
}
