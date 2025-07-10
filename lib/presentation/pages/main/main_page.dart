import 'package:auto_route/auto_route.dart';
import 'package:dent_app_mobile/core/bloc/settings_cubit/settings_cubit.dart';
import 'package:dent_app_mobile/core/data/app_data_service.dart';
import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/personal/core/util/roles.dart';
import 'package:dent_app_mobile/presentation/theme/colors/color_constants.dart';
import 'package:dent_app_mobile/presentation/widgets/notification/app_warning.dart';
import 'package:dent_app_mobile/router/app_route_manager.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toastification/toastification.dart';

@RoutePage(name: 'MainRoute')
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  Role? currentRole;
  AppRouteConfig? routeConfig;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    try {
      final role = await AppDataService.instance.getRole();
      if (mounted) {
        setState(() {
          currentRole = role;
          routeConfig = AppRouteManager.getConfigForRole(role);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          currentRole = Role.doctor; // Default fallback
          routeConfig = AppRouteManager.getConfigForRole(Role.doctor);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading while role is being determined
    if (currentRole == null || routeConfig == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(ColorConstants.primary),
          ),
        ),
      );
    }

    return BlocListener<SettingsCubit, SettingsState>(
      listener: _settingsState,
      child: AutoTabsRouter(
        routes: routeConfig!.routes,
        homeIndex: 0,
        duration: Durations.long1,
        curve: Curves.easeIn,
        builder: (context, child) {
          return Scaffold(
            body: child,
            bottomNavigationBar: ModernBottomNavigationBar(
              config: routeConfig!,
              currentIndex: context.tabsRouter.activeIndex,
              onTap: (index) => context.tabsRouter.setActiveIndex(index),
            ),
          );
        },
      ),
    );
  }

  void _settingsState(BuildContext context, state) {
    if (state is SettingsError) {
      AppWarning.showToastWarning(
        context,
        LocaleKeys.errors_something_went_wrong.tr(),
        type: ToastificationType.error,
      );
    }
  }
}

// Modern Bottom Navigation Bar with better performance
class ModernBottomNavigationBar extends StatelessWidget {
  final AppRouteConfig config;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const ModernBottomNavigationBar({
    super.key,
    required this.config,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ColorConstants.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: ColorConstants.primary,
        unselectedItemColor: ColorConstants.textSecondary,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400),
        type: BottomNavigationBarType.fixed,
        items: config.navigationItems,
        currentIndex: currentIndex,
        onTap: onTap,
      ),
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
