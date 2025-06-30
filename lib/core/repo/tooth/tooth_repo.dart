import 'package:dent_app_mobile/core/repo/tooth/tooth_i_repo.dart';
import 'package:dent_app_mobile/core/service/dio_settings.dart';

class ToothRepo extends ToothIRepo {
  final dio = DioService();
}
