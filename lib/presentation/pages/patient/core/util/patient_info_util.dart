import 'package:dent_app_mobile/core/data/app_data_service.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/personal/core/util/roles.dart';

class PatientInfoUtil {
  // visibility phone number
  static Future<bool> getVisibilityPhoneNumber() async {
    final Role role = await AppDataService.instance.getRole();
    if (role == Role.admin) {
      return true;
    }
    return false;
  }
}
