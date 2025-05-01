import 'package:dent_app_mobile/core/service/dio_settings.dart';
import 'package:dent_app_mobile/models/users/personal_model.dart';
import 'package:dent_app_mobile/models/users/user_detail_model.dart';
import 'package:dent_app_mobile/models/users/user_model.dart';

abstract class IPersonalRepo {
  Future<UserDetailModel> getPersonalDetail(int id);
  Future<UserDataModel> getPersonalList(int page, {String? search});
  Future<UserDataModel> getManagerList(int page);
  Future<UserDetailModel> getPersonalDetailById(int id);
  Future<void> createPersonal(PersonalModel doctor);
  Future<void> updatePersonal(int id, PersonalModel doctor);
  Future<void> deletePersonal(int id);
}

class PersonalRepo extends IPersonalRepo {
  final dio = DioService();
  @override
  Future<UserDetailModel> getPersonalDetail(int id) async {
    final response = await dio.get('api/users/$id');
    return UserDetailModel.fromJson(response.data);
  }

  @override
  Future<UserModel> createPersonal(PersonalModel doctor) async {
    final response = await dio.post('api/users', data: doctor.toJson());
    return UserModel.fromJson(response.data);
  }

  @override
  Future<void> deletePersonal(int id) async {
    await dio.delete('api/users/$id');
  }

  @override
  Future<UserDataModel> getManagerList(int page) async {
    final response = await dio.get(
      'api/users/managers',
      queryParameters: {"page": page},
    );
    return UserDataModel.fromJson(response.data);
  }

  @override
  Future<UserDetailModel> getPersonalDetailById(int id) async {
    final response = await dio.get('api/users/$id');
    return UserDetailModel.fromJson(response.data);
  }

  @override
  Future<UserDataModel> getPersonalList(int page, {String? search}) async {
    final response = await dio.get(
      'api/users',
      queryParameters: {"page": page, "search": search},
    );
    return UserDataModel.fromJson(response.data);
  }

  @override
  Future<void> updatePersonal(int id, PersonalModel doctor) async {
    await dio.put('api/users/$id', data: doctor.toJson());
  }
}
