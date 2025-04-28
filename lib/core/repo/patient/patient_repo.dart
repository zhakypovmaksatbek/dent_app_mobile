import 'package:dent_app_mobile/core/service/dio_settings.dart';
import 'package:dent_app_mobile/models/patient/patient_create_model.dart';
import 'package:dent_app_mobile/models/patient/patient_data_model.dart';

abstract class IPatientRepo {
  Future<PatientDataModel> getPatients(int page, int size);
  Future<PatientDataModel> searchPatients(String query);
  Future<void> createPatient(PatientCreateModel patient);
  Future<void> updatePatient(int id, PatientCreateModel patient);
  Future<void> deletePatient(int id);
  Future<void> getPatient(int id);
}

class PatientRepo extends IPatientRepo {
  final dio = DioService();
  @override
  Future<PatientDataModel> getPatients(int page, int size) async {
    final response = await dio.get(
      'api/patients',
      queryParameters: {'page': page, 'size': size},
    );
    return PatientDataModel.fromJson(response.data);
  }

  @override
  Future<void> createPatient(PatientCreateModel patient) async {
    final response = await dio.post('api/patients', data: patient.toJson());
    return response.data;
  }

  @override
  Future<void> deletePatient(int id) async {
    final response = await dio.delete('api/patients/$id');
    return response.data;
  }

  @override
  Future<void> getPatient(int id) async {
    final response = await dio.get('api/patients/$id');
    return response.data;
  }

  @override
  Future<PatientDataModel> searchPatients(String query) async {
    final response = await dio.get(
      'api/patients',
      queryParameters: {'searchPatient': query},
    );
    return PatientDataModel.fromJson(response.data);
  }

  @override
  Future<void> updatePatient(int id, PatientCreateModel patient) async {
    final response = await dio.put('api/patients/$id', data: patient.toJson());
    return response.data;
  }
}
