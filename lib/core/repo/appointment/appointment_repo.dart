import 'package:dent_app_mobile/core/data/app_data_service.dart';
import 'package:dent_app_mobile/core/repo/appointment/i_appointment_repo.dart';
import 'package:dent_app_mobile/core/service/dio_settings.dart';
import 'package:dent_app_mobile/core/utils/image_type.dart';
import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/models/appointment/appointment_comment_model.dart';
import 'package:dent_app_mobile/models/appointment/appointment_detail_model.dart';
import 'package:dent_app_mobile/models/appointment/appointment_doctor_model.dart';
import 'package:dent_app_mobile/models/appointment/appointment_model.dart';
import 'package:dent_app_mobile/models/appointment/calendar_appointment_model.dart';
import 'package:dent_app_mobile/models/appointment/create_appointment_model.dart';
import 'package:dent_app_mobile/models/appointment/doctor_model.dart';
import 'package:dent_app_mobile/models/appointment/room_model.dart';
import 'package:dent_app_mobile/models/appointment/time_model.dart';
import 'package:dent_app_mobile/models/diagnosis/condition_model.dart';
import 'package:dent_app_mobile/models/diagnosis/tooth_model.dart';
import 'package:dent_app_mobile/models/diagnosis/x_ray_model.dart';
import 'package:dent_app_mobile/models/patient/patient_short_model.dart';
import 'package:dent_app_mobile/models/patient/visit_model.dart';
import 'package:dent_app_mobile/models/pattern/pattern_model.dart';
import 'package:dent_app_mobile/models/payment/detail_receipt_model.dart';
import 'package:dent_app_mobile/models/payment/payment_model.dart';
import 'package:dent_app_mobile/models/payment/receipt_model.dart';
import 'package:dent_app_mobile/models/work/appointment_work_model.dart';
import 'package:dent_app_mobile/models/work/image_response_model.dart';
import 'package:dent_app_mobile/models/work/upload_patient_rontgen_model.dart';
import 'package:dent_app_mobile/models/work/work_model.dart';
import 'package:dent_app_mobile/presentation/pages/treatment/core/data/condition_type.dart';
import 'package:dent_app_mobile/presentation/pages/treatment/core/data/pattern_type.dart';
import 'package:dent_app_mobile/presentation/pages/treatment/core/model/job_model.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AppointmentRepo extends IAppointmentRepo {
  final dio = DioService();
  @override
  Future<List<AppointmentDetailModel>> getAppointments() async {
    final response = await dio.get('api/appointments');
    List<dynamic> data = response.data as List<dynamic>;
    return data
        .map((e) => AppointmentDetailModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<AppointmentDetailModel> getAppointmentById(int id) async {
    final response = await dio.get('api/appointments/$id');
    return AppointmentDetailModel.fromJson(response.data);
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
  Future<String> updateAppointmentComment(
    int id,
    AppointmentCommentModel appointment,
  ) async {
    final response = await dio.put(
      'api/appointments/$id/comments',
      data: appointment.toJson(),
    );
    return response.data['message'];
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
  Future<List<PatientShortModel>> getPatientShortList(String? query) async {
    final response = await dio.get(
      'api/calendars/patients',
      queryParameters: query != null ? {'search': query} : null,
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

  @override
  Future<PatternModel> getPatternList(
    PatternType type, {
    String? search,
  }) async {
    final response = await dio.get(
      'api/patterns',
      queryParameters: {'patternType': type.value, 'search': search},
    );
    return PatternModel.fromStringList(response.data);
  }

  @override
  Future<List<ConditionModel>> getConditionList({ConditionType? type}) async {
    final response = await dio.get('api/conditions/grouped/${type?.name}');
    List<dynamic> data = response.data as List<dynamic>;
    return data
        .map((e) => ConditionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<RoomModel>> getRoomListByDate({
    required DateTime date,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
  }) async {
    final dateFormatter = DateFormat('yyyy-MM-dd');

    // Format the date
    final formattedDate = dateFormatter.format(date);

    // Format the times
    final formattedStartTime =
        '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}:00';
    final formattedEndTime =
        '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}:00';

    final response = await dio.get(
      'api/rooms/select',
      queryParameters: {
        'date': formattedDate,
        'startTime': formattedStartTime,
        'endTime': formattedEndTime,
      },
    );

    if (response.data == null) {
      return [];
    }

    final List<dynamic> data = response.data as List<dynamic>;
    return data
        .map((e) => RoomModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<String> saveServices(int appointmentId, List<int> serviceIds) async {
    final response = await dio.post(
      'api/works/quick/$appointmentId',
      data: serviceIds,
    );
    return response.data['message'] ??
        LocaleKeys.notifications_payment_success.tr();
  }

  @override
  Future<ReceiptModel> getReceipt(int appointmentId) async {
    final response = await dio.get(
      'api/payments/wants-to-fast-pay/$appointmentId',
    );
    return ReceiptModel.fromJson(response.data);
  }

  @override
  Future<void> fastPay(PaymentModel payment, int appointmentId) async {
    await dio.post('api/payments/toPay/$appointmentId', data: payment.toJson());
  }

  @override
  Future<void> saveWorks(int appointmentId, List<JobModel> jobs) async {
    final List<Map<String, dynamic>> request = jobs.map((job) {
      return WorkModel(
        toothNumber: int.parse(job.toothId),
        serviceIds: job
            .serviceIdsWithCount, // Use the new getter that repeats IDs based on count
        diagnosisId: job.diagnosisIds,
        surveyPlan: job.surveyPlan,
        treatment: job.treatment,

        recommendations: job.recommendation,
        toothRequests: [
          ToothRequests(
            conditionId: job.condition.id!,
            toothType: job.toothType?.key,
          ),
        ],
      ).toJson(); // Convert to JSON immediately
    }).toList();

    await dio.post('api/works/$appointmentId', data: request);
  }

  @override
  Future<AppointmentPaginationModel> getPatientData(
    int patientId, {
    required int page,
  }) async {
    final response = await dio.get(
      'api/appointments/patient/$patientId',
      queryParameters: {'page': page},
    );
    return AppointmentPaginationModel.fromJson(response.data);
  }

  @override
  Future<ImageResponseModel> saveImage(XFile image, ImageType type) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(image.path, filename: image.name),
    });
    final response = await dio.post(
      'api/files/${type.name.toUpperCase()}',
      data: formData,
    );
    return ImageResponseModel.fromJson(response.data);
  }

  @override
  Future<void> deleteImage(String imageId) async {
    await dio.delete('api/files/$imageId');
  }

  @override
  Future<void> uploadPatientXRay(UploadXRayModel request) async {
    final int? userId = await AppDataService.instance.getUserId();
    await dio.post(
      'api/images/snapshots/$userId/${request.imageId}',
      queryParameters: {
        'appointmentId': request.appointmentId,
        'description': request.description,
        'teeth': request.teeth,
      },
    );
  }

  @override
  Future<List<XRayModel>> getPatientXRay(int patientId) async {
    final response = await dio.get('api/images/$patientId');
    List<dynamic> data = response.data as List<dynamic>;
    return data
        .map((e) => XRayModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<AppointmentDoctorsPaginationModel> getAppointmentDoctors(
    DateTime date,
  ) async {
    final dateFormatter = DateFormat('yyyy-MM-dd');
    final formattedDate = dateFormatter.format(date);
    final response = await dio.get(
      'api/appointments/doctors',
      queryParameters: {'day': formattedDate, 'total': 20},
    );
    return AppointmentDoctorsPaginationModel.fromJson(response.data);
  }

  @override
  Future<DetailReceiptModel> getDetailReceipt(int appointmentId) async {
    final response = await dio.get('api/payments/wantsToPay/$appointmentId');
    return DetailReceiptModel.fromJson(response.data);
  }

  @override
  Future<List<AppointmentWorkModel>> getAppointmentWorks(
    int appointmentId,
  ) async {
    final response = await dio.get('api/works/$appointmentId');
    return (response.data as List<dynamic>)
        .map((e) => AppointmentWorkModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
