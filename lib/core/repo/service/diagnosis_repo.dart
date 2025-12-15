import 'package:dent_app_mobile/main.dart';
import 'package:dent_app_mobile/models/diagnosis/diagnosis_model.dart';

class DiagnosisRepository {
  Future<DiagnosisPaginationModel> getDiagnosis(int page) async {
    final response = await dio.get(
      'api/diagnosis/all',
      queryParameters: {'page': page},
    );
    return DiagnosisPaginationModel.fromJson(response.data);
  }

  Future<void> saveDiagnosis(String name) async {
    await dio.post('api/diagnosis/save', data: {'name': name});
  }

  Future<void> updateDiagnosis(int id, String name) async {
    await dio.put('api/diagnosis/$id?name=$name');
  }

  Future<void> deleteDiagnosis(int id) async {
    await dio.delete('api/diagnosis/$id');
  }

  Future<List<DiagnosisModel>> getDiagnosisList() async {
    final response = await dio.get('api/diagnosis');
    return (response.data as List)
        .map((e) => DiagnosisModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
