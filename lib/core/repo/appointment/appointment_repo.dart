import 'package:dent_app_mobile/core/service/dio_settings.dart';
import 'package:dent_app_mobile/models/appointment/appointment_comment_model.dart';
import 'package:dent_app_mobile/models/appointment/appointment_model.dart';
import 'package:dent_app_mobile/models/appointment/calendar_appointment_model.dart';
import 'package:dent_app_mobile/models/appointment/create_appointment_model.dart';
import 'package:dent_app_mobile/models/appointment/doctor_model.dart';
import 'package:dent_app_mobile/models/appointment/room_model.dart';
import 'package:dent_app_mobile/models/appointment/time_model.dart';
import 'package:dent_app_mobile/models/diagnosis/tooth_model.dart';
import 'package:dent_app_mobile/models/patient/patient_short_model.dart';
import 'package:dent_app_mobile/models/patient/visit_model.dart';

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
  Future<List<CalendarAppointmentModel>> getCalendarAppointments({
    required DateTime startDate,
    required DateTime endDate,
    List<int>? userIds,
  });
  Future<List<CalendarAppointmentModel>> getCalendarAppointmentsForDoctor({
    required DateTime startDate,
    required DateTime endDate,
  });
  Future<List<PatientShortModel>> getPatientShortList(String query);
  Future<List<TimeModel>> getTimeList(int userId, DateTime date, int minute);
  Future<List<RoomModel>> getRoomList();
  Future<List<DoctorModel>> getDoctorList();
  Future<VisitDataModel> getPatientAppointments({
    required int patientId,
    required int page,
  });
  Future<List<ToothModel>> getToothList(int patientId);
}

class AppointmentRepo extends IAppointmentRepo {
  final dio = DioService();
  @override
  Future<List<AppointmentModel>> getAppointments() async {
    final response = await dio.get('api/appointments');
    List<dynamic> data = response.data as List<dynamic>;
    return data
        .map((e) => AppointmentModel.fromJson(e as Map<String, dynamic>))
        .toList();
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

  @override
  Future<List<CalendarAppointmentModel>> getCalendarAppointments({
    required DateTime startDate,
    required DateTime endDate,
    List<int>? userIds,
  }) async {
    final queryParameters = <String, dynamic>{};

    queryParameters['startDay'] = formatDate(startDate);
    queryParameters['endDay'] = formatDate(endDate);
    if (userIds != null) {
      queryParameters['userIds'] = userIds;
    }
    final response = await dio.get(
      'api/calendars',
      queryParameters: queryParameters,
    );

    List<dynamic> data = response.data as List<dynamic>;
    return data
        .map(
          (e) => CalendarAppointmentModel.fromJson(e as Map<String, dynamic>),
        )
        .toList();
  }

  String formatDate(DateTime date) {
    return date.toIso8601String().split('T')[0];
  }

  @override
  Future<List<PatientShortModel>> getPatientShortList(String query) async {
    final response = await dio.get(
      'api/calendars/patients',
      queryParameters: {'search': query},
    );
    List<dynamic> data = response.data as List<dynamic>;
    return data
        .map((e) => PatientShortModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<CalendarAppointmentModel>> getCalendarAppointmentsForDoctor({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final queryParameters = <String, dynamic>{};
    queryParameters['startDate'] = formatDate(startDate);
    queryParameters['endDate'] = formatDate(endDate);
    final response = await dio.get(
      'api/calendars/doctor',
      queryParameters: queryParameters,
    );

    List<dynamic> data = response.data as List<dynamic>;
    return data
        .map(
          (e) => CalendarAppointmentModel.fromJson(e as Map<String, dynamic>),
        )
        .toList();
  }

  @override
  Future<List<TimeModel>> getTimeList(
    int userId,
    DateTime date,
    int minute,
  ) async {
    final response = await dio.get(
      'api/day-schedules/freeTime/$userId/mobile',
      queryParameters: {
        'dataOfAppointment': formatDate(date),
        'minute': minute,
      },
    );
    List<dynamic> data = response.data as List<dynamic>;
    return data
        .map((e) => TimeModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<RoomModel>> getRoomList() async {
    final response = await dio.get('api/rooms');
    List<dynamic> data = response.data as List<dynamic>;
    return data
        .map((e) => RoomModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<DoctorModel>> getDoctorList() async {
    final response = await dio.get('api/calendars/users');
    List<dynamic> data = response.data as List<dynamic>;
    return data
        .map((e) => DoctorModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<VisitDataModel> getPatientAppointments({
    required int patientId,
    required int page,
  }) async {
    final response = await dio.get(
      'api/appointments/patient/$patientId',
      queryParameters: {'page': page},
    );
    return VisitDataModel.fromJson(response.data);
  }

  @override
  Future<List<ToothModel>> getToothList(int patientId) async {
    final response = await dio.get('api/teeth/mains/$patientId');
    List<dynamic> data = response.data as List<dynamic>;
    return data
        .map((e) => ToothModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
