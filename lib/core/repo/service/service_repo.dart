import 'package:dent_app_mobile/core/service/dio_settings.dart';
import 'package:dent_app_mobile/models/service/save_service_model.dart';
import 'package:dent_app_mobile/models/service/service_model.dart';
import 'package:dent_app_mobile/models/service/service_type_model.dart';

abstract class IServiceRepo {
  Future<List<ServiceModel>> getServices({String? search});
  Future<List<ServiceItem>> getServiceItems({String? search});
  Future<void> saveService(SaveServiceModel saveServiceModel);
  Future<void> updateService(int id, SaveServiceModel saveServiceModel);
  Future<void> deleteService(int id);
  Future<ServiceTypeModel> getServiceTypes();
}

class ServiceRepo extends IServiceRepo {
  final _dio = DioService();
  @override
  Future<List<ServiceItem>> getServiceItems({String? search}) async {
    final response = await _dio.get(
      'api/services',
      queryParameters: {'search': search},
    );
    return (response.data as List).map((e) => ServiceItem.fromJson(e)).toList();
  }

  @override
  Future<List<ServiceModel>> getServices({String? search}) async {
    final response = await _dio.get(
      'api/services/all',
      queryParameters: {'search': search},
    );
    return (response.data as List)
        .map((e) => ServiceModel.fromJson(e))
        .toList();
  }

  @override
  Future<void> deleteService(int id) async {
    await _dio.delete('api/services/$id');
  }

  @override
  Future<void> saveService(SaveServiceModel saveServiceModel) async {
    await _dio.post('api/services', data: saveServiceModel.toJson());
  }

  @override
  Future<void> updateService(int id, SaveServiceModel saveServiceModel) async {
    await _dio.put('api/services/$id', data: saveServiceModel.toJson());
  }

  @override
  Future<ServiceTypeModel> getServiceTypes() async {
    final response = await _dio.get('api/services/categories');
    return ServiceTypeModel.fromJson(response.data);
  }
}
