import 'package:dent_app_mobile/core/data/app_data_service.dart';
import 'package:dent_app_mobile/core/service/dio_settings.dart';
import 'package:dent_app_mobile/models/login/login_model.dart';

abstract class UserRepo {
  Future<LoginResponseModel> login(LoginModel loginModel);
}

class UserRepoImpl extends UserRepo {
  final DioService dioService = DioService();
  final AuthDioSettings authDioSettings = AuthDioSettings();
  final appDataService = AppDataService.instance;
  @override
  Future<LoginResponseModel> login(LoginModel loginModel) async {
    final response = await authDioSettings.dio.post(
      'api/auth/login',
      data: loginModel.toJson(),
    );
    final data = LoginResponseModel.fromJson(response.data);
    if (data.jwt != null) {
      await appDataService.setToken(accessToken: data.jwt!);
      await appDataService.setIsLogin(true);
      await appDataService.setTokenExpiry(
        expiryTime: DateTime.now().add(Duration(days: 3)),
      );
    }
    return data;
  }
}
