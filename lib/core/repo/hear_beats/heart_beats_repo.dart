import 'package:dent_app_mobile/core/service/dio_settings.dart';
import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/models/heartbeats/heart_beats_model.dart';

class HeartBeatsRepo {
  final DioService dio = DioService();

  Future<HeartbeatsModel> getHeartBeats(DateType dateType) async {
    final response = await dio.get(
      'api/heartbeats',
      queryParameters: {'dateType': dateType.name.toUpperCase()},
    );
    return HeartbeatsModel.fromJson(response.data);
  }
}

enum DateType {
  week(LocaleKeys.general_week),
  month(LocaleKeys.general_month),
  year(LocaleKeys.general_year);

  const DateType(this.title);

  final String title;
}
