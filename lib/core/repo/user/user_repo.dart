import 'package:dent_app_mobile/core/data/app_data_service.dart';
import 'package:dent_app_mobile/core/service/dio_settings.dart';
import 'package:dent_app_mobile/models/login/login_model.dart';
import 'package:dent_app_mobile/models/patient/visit_model.dart';
import 'package:dent_app_mobile/models/users/schedule_model.dart';
import 'package:dent_app_mobile/models/users/specialty_model.dart';

abstract class UserRepo {
  Future<LoginResponseModel> login(LoginModel loginModel);
  Future<VisitDataModel> getVisits({required int userId, required int page});
  Future<List<SpecialtyModel>> getSpecialties(int userId);
  Future<List<SpecialtyModel>> getUserSpecialties({required int userId});
  Future<void> addUserSpecialty({
    required int userId,
    required List<int> specialtyIds,
  });
  Future<void> deleteUserSpecialty({
    required int userId,
    required int specialtyId,
  });
  Future<ScheduleModel> getDoctorSchedule(int userId, DateTime startWeek);
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

  @override
  Future<VisitDataModel> getVisits({
    required int userId,
    required int page,
  }) async {
    final response = await dioService.dio.get(
      'api/appointments/staff/$userId',

      queryParameters: {'page': page},
    );
    return VisitDataModel.fromJson(response.data);
  }

  @override
  Future<void> addUserSpecialty({
    required int userId,
    required List<int> specialtyIds,
  }) async {
    await dioService.dio.post(
      'api/users/$userId/specialities',
      queryParameters: {'specialityIds': specialtyIds.join(',')},
    );
  }

  @override
  Future<void> deleteUserSpecialty({
    required int userId,
    required int specialtyId,
  }) async {
    await dioService.dio.delete('api/users/$userId/specialities/$specialtyId');
  }

  @override
  Future<List<SpecialtyModel>> getSpecialties(int userId) async {
    final response = await dioService.dio.get(
      'api/users/$userId/specialities/select',
    );

    if (response.data is List) {
      return (response.data as List)
          .map((e) => SpecialtyModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return [];
  }

  @override
  Future<List<SpecialtyModel>> getUserSpecialties({required int userId}) async {
    final response = await dioService.dio.get('api/users/$userId/specialities');

    if (response.data is List) {
      return (response.data as List)
          .map((e) => SpecialtyModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return [];
  }

  @override
  Future<ScheduleModel> getDoctorSchedule(
    int userId,
    DateTime startWeek,
  ) async {
    // format startWeek to YYYY-MM-DD
    final startWeekFormatted = startWeek.toIso8601String().split('T')[0];

    final response = await dioService.dio.get(
      'api/schedules/$userId',
      queryParameters: {'startWeek': startWeekFormatted},
    );
    return ScheduleModel.fromJson(response.data);
  }
}
