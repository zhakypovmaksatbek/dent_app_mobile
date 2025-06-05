import 'package:auto_route/auto_route.dart';
import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/presentation/constants/asset_constants.dart';
import 'package:dent_app_mobile/presentation/theme/colors/color_constants.dart';
import 'package:dent_app_mobile/presentation/widgets/image/custom_asset_image.dart';
import 'package:dent_app_mobile/router/app_route_manager.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

@RoutePage(name: 'MainRoute')
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final routes = AppRouteManager.routes;
  final routesV2 = AppRouteManager.routesV2;
  @override
  Widget build(BuildContext context) {
    return AutoTabsRouter(
      routes: routesV2,
      homeIndex: 0,
      duration: Durations.long1,
      curve: Curves.easeIn,
      builder: (context, child) {
        return Scaffold(
          body: child,
          bottomNavigationBar: BottomNavigationBar(
            backgroundColor: ColorConstants.white,
            selectedItemColor: ColorConstants.primary,
            unselectedItemColor: ColorConstants.textPrimary,
            useLegacyColorScheme: false,
            items: [
              NavigationItemModel(
                icon: CustomAssetImage(
                  path: AssetConstants.chart.svg,
                  isSvg: true,
                ),
                label: LocaleKeys.routes_dashboard.tr(),
                activeIcon: CustomAssetImage(
                  path: AssetConstants.chart.svg,
                  isSvg: true,
                  svgColor: ColorConstants.primary,
                ),
              ),
              NavigationItemModel(
                icon: CustomAssetImage(
                  path: AssetConstants.calendar.svg,
                  isSvg: true,
                ),
                label: LocaleKeys.routes_calendar.tr(),
                activeIcon: CustomAssetImage(
                  path: AssetConstants.calendar.svg,
                  isSvg: true,
                  svgColor: ColorConstants.primary,
                ),
              ),
              NavigationItemModel(
                icon: CustomAssetImage(
                  path: AssetConstants.schedule.svg,
                  isSvg: true,
                ),
                label: LocaleKeys.routes_report.tr(),
                activeIcon: CustomAssetImage(
                  path: AssetConstants.schedule.svg,
                  isSvg: true,
                  svgColor: ColorConstants.primary,
                ),
              ),

              NavigationItemModel(
                icon: CustomAssetImage(
                  path: AssetConstants.user.svg,
                  isSvg: true,
                ),
                label: LocaleKeys.routes_patients.tr(),
                activeIcon: CustomAssetImage(
                  path: AssetConstants.user.svg,
                  isSvg: true,
                  svgColor: ColorConstants.primary,
                ),
              ),
              NavigationItemModel(
                icon: CustomAssetImage(
                  path: AssetConstants.settings.svg,
                  isSvg: true,
                ),
                label: LocaleKeys.routes_settings.tr(),
                activeIcon: CustomAssetImage(
                  path: AssetConstants.settings.svg,
                  isSvg: true,
                  svgColor: ColorConstants.primary,
                ),
              ),
            ],
            currentIndex: context.tabsRouter.activeIndex,

            onTap: (index) {
              context.tabsRouter.setActiveIndex(index);
            },
          ),
        );
      },
    );
  }
}

class NavigationItemModel extends BottomNavigationBarItem {
  NavigationItemModel({
    required super.icon,
    required super.label,
    required super.activeIcon,
  });
}
