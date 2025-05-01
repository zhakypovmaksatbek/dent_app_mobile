import 'package:dent_app_mobile/core/service/dio_settings.dart';
import 'package:dent_app_mobile/models/appointment/appointment_comment_model.dart';
import 'package:dent_app_mobile/models/appointment/appointment_model.dart';
import 'package:dent_app_mobile/models/appointment/create_appointment_model.dart';

abstract class IAppointmentRepo {
  Future<List<AppointmentModel>> getAppointments();
  Future<AppointmentModel> getAppointmentById(int id);
  Future<void> createAppointment(CreateAppointmentModel appointment);
  Future<void> updateAppointment(int id, CreateAppointmentModel appointment);
  Future<void> updateAppointmentComment(
    int id,
    AppointmentCommentModel appointment,
  );
  Future<void> deleteAppointment(int id);
}

class AppointmentRepo extends IAppointmentRepo {
  final dio = DioService();
  @override
  Future<List<AppointmentModel>> getAppointments() async {
    final response = await dio.get('api/appointments');
    return response.data.map((e) => AppointmentModel.fromJson(e)).toList();
  }

  @override
  Future<AppointmentModel> getAppointmentById(int id) async {
    final response = await dio.get('api/appointments/$id');
    return AppointmentModel.fromJson(response.data);
  }

  @override
  Future<void> createAppointment(CreateAppointmentModel appointment) async {
    await dio.post('api/appointments', data: appointment.toJson());
  }

  @override
  Future<void> deleteAppointment(int id) async {
    await dio.delete('api/appointments/$id');
  }

  @override
  Future<void> updateAppointment(
    int id,
    CreateAppointmentModel appointment,
  ) async {
    await dio.put('api/appointments/$id', data: appointment.toJson());
  }

  @override
  Future<void> updateAppointmentComment(
    int id,
    AppointmentCommentModel appointment,
  ) async {
    await dio.put('api/appointments/$id/comments', data: appointment.toJson());
  }
}
