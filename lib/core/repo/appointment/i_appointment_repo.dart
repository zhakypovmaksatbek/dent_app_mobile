import 'package:dent_app_mobile/core/utils/image_type.dart';
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
import 'package:dent_app_mobile/presentation/pages/treatment/core/data/condition_type.dart';
import 'package:dent_app_mobile/presentation/pages/treatment/core/data/pattern_type.dart';
import 'package:dent_app_mobile/presentation/pages/treatment/core/model/job_model.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

abstract class IAppointmentRepo {
  Future<List<AppointmentDetailModel>> getAppointments();
  Future<AppointmentDetailModel> getAppointmentById(int id);
  Future<void> createAppointment(CreateAppointmentModel appointment);
  Future<void> updateAppointment(int id, CreateAppointmentModel appointment);
  Future<String> updateAppointmentComment(
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
  Future<PatternModel> getPatternList(PatternType type, {String? search});
  Future<List<ConditionModel>> getConditionList({ConditionType? type});
  Future<List<RoomModel>> getRoomListByDate({
    required DateTime date,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
  });
  Future<String> saveServices(int appointmentId, List<int> serviceIds);
  Future<ReceiptModel> getReceipt(int appointmentId);
  Future<void> fastPay(PaymentModel payment, int appointmentId);
  Future<void> saveWorks(int appointmentId, List<JobModel> jobs);
  Future<AppointmentPaginationModel> getPatientData(
    int patientId, {
    required int page,
  });
  Future<ImageResponseModel> saveImage(XFile image, ImageType type);
  Future<void> deleteImage(String imageId);
  Future<void> uploadPatientXRay(UploadXRayModel uploadPatientRontgenModel);
  Future<List<XRayModel>> getPatientXRay(int patientId);
  Future<AppointmentDoctorsPaginationModel> getAppointmentDoctors(
    DateTime date,
  );
  Future<DetailReceiptModel> getDetailReceipt(int appointmentId);
  Future<List<AppointmentWorkModel>> getAppointmentWorks(int appointmentId);
}
