import 'package:auto_route/auto_route.dart';
import 'package:dent_app_mobile/router/app_router.dart';

final class AppRouteManager {
  static final List<PageRouteInfo<dynamic>> routes = [
    const DashboardRoute(),
    const CalendarRoute(),
    const ReportRoute(),
    const WarehouseRoute(),
    const SettingsRoute(),
  ];

  static final List<PageRouteInfo<dynamic>> routesV2 = [
    const DashboardRoute(),
    const CalendarRoute(),
    const ReportRoute(),
    const PatientRoute(),
    const SettingsRoute(),
  ];
}
