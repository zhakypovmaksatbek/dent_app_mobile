import 'package:dent_app_mobile/core/service/dio_settings.dart';
import 'package:dent_app_mobile/models/diagnosis/diagnosis_model.dart';

class DiagnosisRepository {
  final _dio = DioService();

  Future<DiagnosisPaginationModel> getDiagnosis(int page) async {
    final response = await _dio.get(
      'api/diagnosis/all',
      queryParameters: {'page': page},
    );
    return DiagnosisPaginationModel.fromJson(response.data);
  }

  Future<void> saveDiagnosis(String name) async {
    await _dio.post('api/diagnosis/save', data: {'name': name});
  }

  Future<void> updateDiagnosis(int id, String name) async {
    await _dio.put('api/diagnosis/$id?name=$name');
  }

  Future<void> deleteDiagnosis(int id) async {
    await _dio.delete('api/diagnosis/$id');
  }
}
