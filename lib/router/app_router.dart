import 'package:auto_route/auto_route.dart';
import 'package:dent_app_mobile/models/users/user_model.dart';
import 'package:dent_app_mobile/presentation/pages/auth/screen/login_page.dart';
import 'package:dent_app_mobile/presentation/pages/calendar/views/calendar_page.dart';
import 'package:dent_app_mobile/presentation/pages/dashboard/dashboard_page.dart';
import 'package:dent_app_mobile/presentation/pages/main/main_page.dart';
import 'package:dent_app_mobile/presentation/pages/patient/patient_page.dart';
import 'package:dent_app_mobile/presentation/pages/patient/view/appointment_detail.dart';
import 'package:dent_app_mobile/presentation/pages/report/report_page.dart';
import 'package:dent_app_mobile/presentation/pages/settings/settings_page.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/diagnosis/view/diagnosis_page.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/personal/views/create_personal_view.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/personal/views/personal_detail_page.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/personal/views/personal_page.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/personal/views/personal_patients_page.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/services/views/services_page.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/warehouse/views/warehouse_page.dart';
import 'package:dent_app_mobile/presentation/pages/splash/splash_page.dart';
import 'package:flutter/material.dart';

part "app_router.gr.dart";

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: SplashRoute.page, initial: true, path: "/splash"),
    AutoRoute(page: LoginRoute.page, path: "/login"),

    AutoRoute(
      page: MainRoute.page,
      path: "/main",
      children: [
        AutoRoute(page: DashboardRoute.page, path: "dashboard", initial: true),
        AutoRoute(page: CalendarRoute.page, path: "calendar"),
        AutoRoute(page: PatientRoute.page, path: "patient"),
        AutoRoute(page: ReportRoute.page, path: "report"),
        AutoRoute(page: SettingsRoute.page, path: "settings"),
        AutoRoute(page: WarehouseRoute.page, path: "warehouse"),
      ],
    ),

    AutoRoute(page: ServicesRoute.page, path: "/services"),
    AutoRoute(page: WarehouseRoute.page, path: "/warehouse"),
    AutoRoute(page: DiagnosisRoute.page, path: "/diagnosis"),
    AutoRoute(page: PersonalRoute.page, path: "/personal_route"),
    AutoRoute(page: CreatePersonalRoute.page, path: "/createPersonal"),
    AutoRoute(page: PersonalDetailRoute.page, path: "/personalDetail"),
    AutoRoute(page: PersonalPatientsRoute.page, path: "/personalPatients"),
    AutoRoute(page: AppointmentDetailRoute.page, path: "/appointmentDetail"),
  ];
}

@RoutePage(name: "PersonalNavigationRoute")
class PersonalRouterRoute extends AutoRouter {
  const PersonalRouterRoute({super.key});
}
