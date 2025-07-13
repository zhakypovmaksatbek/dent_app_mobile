import 'package:auto_route/auto_route.dart';
import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/presentation/constants/asset_constants.dart';
import 'package:dent_app_mobile/presentation/pages/main/main_page.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/personal/core/util/roles.dart';
import 'package:dent_app_mobile/presentation/widgets/image/custom_asset_image.dart';
import 'package:dent_app_mobile/router/app_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

// Configuration class for routes and navigation
class AppRouteConfig {
  final List<PageRouteInfo<dynamic>> routes;
  final List<BottomNavigationBarItem> navigationItems;
  final Role role;

  const AppRouteConfig({
    required this.routes,
    required this.navigationItems,
    required this.role,
  });
}

final class AppRouteManager {
  // Cache for route configurations to avoid rebuilding
  static final Map<Role, AppRouteConfig> _configCache = {};

  // Legacy static lists (kept for backward compatibility)
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

  // Get configuration for specific role with caching
  static AppRouteConfig getConfigForRole(Role? role) {
    final userRole = role ?? Role.admin; // Default to admin

    if (_configCache.containsKey(userRole)) {
      return _configCache[userRole]!;
    }

    late AppRouteConfig config;

    switch (userRole) {
      case Role.admin:
        config = AppRouteConfig(
          role: Role.admin,
          routes: [
            const DashboardRoute(),
            const CalendarRoute(),
            const PatientRoute(),

            const ReportRoute(),
            const SettingsRoute(),
          ],
          navigationItems: _buildAdminNavigationItems(),
        );
        break;
      case Role.doctor:
        config = AppRouteConfig(
          role: Role.doctor,
          routes: [
            const CalendarRoute(),
            // const ReportRoute(),
            const PatientRoute(),
            const SettingsRoute(),
          ],
          navigationItems: _buildDoctorNavigationItems(),
        );
        break;
      case Role.developer:
        // Developer has same access as admin
        config = AppRouteConfig(
          role: Role.developer,
          routes: [
            const DashboardRoute(),
            const CalendarRoute(),
            const ReportRoute(),
            const PatientRoute(),
            const SettingsRoute(),
          ],
          navigationItems: _buildAdminNavigationItems(),
        );
        break;
      default:
        // Default to doctor configuration for any other roles
        config = AppRouteConfig(
          role: userRole,
          routes: [
            const CalendarRoute(),
            const ReportRoute(),
            const PatientRoute(),
            const SettingsRoute(),
          ],
          navigationItems: _buildDoctorNavigationItems(),
        );
        break;
    }

    _configCache[userRole] = config;
    return config;
  }

  // Build navigation items for admin
  static List<BottomNavigationBarItem> _buildAdminNavigationItems() {
    return [
      NavigationItemModel(
        icon: CustomAssetImage(path: AssetConstants.chart.svg, isSvg: true),
        label: LocaleKeys.routes_dashboard.tr(),
        activeIcon: CustomAssetImage(
          path: AssetConstants.aChart.svg,
          isSvg: true,
        ),
      ),
      NavigationItemModel(
        icon: CustomAssetImage(path: AssetConstants.calendar.svg, isSvg: true),
        label: LocaleKeys.routes_calendar.tr(),
        activeIcon: CustomAssetImage(
          path: AssetConstants.aCalendar.svg,
          isSvg: true,
        ),
      ),
      NavigationItemModel(
        icon: CustomAssetImage(path: AssetConstants.user.svg, isSvg: true),
        label: LocaleKeys.routes_patients.tr(),
        activeIcon: CustomAssetImage(
          path: AssetConstants.aUser.svg,
          isSvg: true,
        ),
      ),
      NavigationItemModel(
        icon: CustomAssetImage(path: AssetConstants.schedule.svg, isSvg: true),
        label: LocaleKeys.routes_report.tr(),
        activeIcon: CustomAssetImage(
          path: AssetConstants.aSchedule.svg,
          isSvg: true,
        ),
      ),

      NavigationItemModel(
        icon: CustomAssetImage(path: AssetConstants.settings.svg, isSvg: true),
        label: LocaleKeys.routes_settings.tr(),
        activeIcon: CustomAssetImage(
          path: AssetConstants.aSettings.svg,
          isSvg: true,
        ),
      ),
    ];
  }

  // Build navigation items for doctor (user)
  static List<BottomNavigationBarItem> _buildDoctorNavigationItems() {
    return [
      NavigationItemModel(
        icon: CustomAssetImage(path: AssetConstants.calendar.svg, isSvg: true),
        label: LocaleKeys.routes_calendar.tr(),
        activeIcon: CustomAssetImage(
          path: AssetConstants.aCalendar.svg,
          isSvg: true,
        ),
      ),
      // NavigationItemModel(
      //   icon: CustomAssetImage(path: AssetConstants.schedule.svg, isSvg: true),
      //   label: LocaleKeys.routes_report.tr(),
      //   activeIcon: CustomAssetImage(
      //     path: AssetConstants.aSchedule.svg,
      //     isSvg: true,
      //   ),
      // ),
      NavigationItemModel(
        icon: CustomAssetImage(path: AssetConstants.user.svg, isSvg: true),
        label: LocaleKeys.routes_patients.tr(),
        activeIcon: CustomAssetImage(
          path: AssetConstants.aUser.svg,
          isSvg: true,
        ),
      ),
      NavigationItemModel(
        icon: CustomAssetImage(path: AssetConstants.settings.svg, isSvg: true),
        label: LocaleKeys.routes_settings.tr(),
        activeIcon: CustomAssetImage(
          path: AssetConstants.aSettings.svg,
          isSvg: true,
        ),
      ),
    ];
  }

  // Clear cache when needed (e.g., locale change)
  static void clearCache() {
    _configCache.clear();
  }

  // Legacy getters (kept for backward compatibility)
  static final List<BottomNavigationBarItem> adminItems =
      _buildAdminNavigationItems();
  static final List<BottomNavigationBarItem> userItems =
      _buildDoctorNavigationItems();
}
