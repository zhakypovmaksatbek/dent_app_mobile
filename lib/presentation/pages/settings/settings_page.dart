import 'package:auto_route/auto_route.dart';
import 'package:dent_app_mobile/core/data/app_data_service.dart';
import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/main.dart';
import 'package:dent_app_mobile/presentation/pages/settings/widgets/profile_section.dart';
import 'package:dent_app_mobile/presentation/theme/colors/color_constants.dart';
import 'package:dent_app_mobile/presentation/widgets/buttons/def_elevated_button.dart';
import 'package:dent_app_mobile/router/app_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

@RoutePage(name: 'SettingsRoute')
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final router = getIt<AppRouter>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.routes_settings.tr()),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ProfileSection(),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                LocaleKeys.routes_navigation.tr(),
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            _buildNavigationCards(),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                LocaleKeys.routes_account.tr(),
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            _buildAccountCards(),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                width: double.infinity,
                child: DefElevatedButton(
                  title: LocaleKeys.buttons_logout.tr(),
                  onPressed: () async {
                    await AppDataService.instance.clearTokens();
                    router.replaceAll([const LoginRoute()]);
                  },
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationCards() {
    // Define navigation items
    final navItems = [
      {
        'title': LocaleKeys.routes_services.tr(),
        'icon': Icons.medical_services_outlined,
        'description': LocaleKeys.general_services_info.tr(),
        'onTap': () {
          router.push(const ServicesRoute());
        },
      },
      {
        'title': LocaleKeys.routes_diagnosis.tr(),
        'icon': Icons.biotech_outlined,
        'description': LocaleKeys.general_diagnosis_info.tr(),
        'onTap': () {
          router.push(const DiagnosisRoute());
        },
      },
      {
        'title': LocaleKeys.routes_personal.tr(),
        'icon': Icons.people_outline,
        'description': LocaleKeys.general_personal_info.tr(),
        'onTap': () {
          router.push(const PersonalRoute());
        },
      },
      {
        'title': LocaleKeys.routes_clinic_settings.tr(),
        'icon': Icons.business_outlined,
        'description': LocaleKeys.general_clinic_settings_info.tr(),
        'onTap': () {
          // Navigate to clinic settings
        },
      },
      {
        'title': LocaleKeys.routes_warehouse.tr(),
        'icon': Icons.warehouse_outlined,
        'description': "LocaleKeys.general_warehouse_info.tr()",
        'onTap': () {
          router.push(const WarehouseRoute());
        },
      },
      {
        'title': LocaleKeys.routes_notifications.tr(),
        'icon': Icons.notifications_outlined,
        'description': LocaleKeys.general_notifications_info_description.tr(),
        'onTap': () {
          // Navigate to notifications settings
        },
      },
    ];

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: navItems.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemBuilder: (context, index) {
        final item = navItems[index];
        return _buildNavigationCard(
          title: item['title'] as String,
          icon: item['icon'] as IconData,
          description: item['description'] as String,
          onTap: item['onTap'] as VoidCallback,
        );
      },
    );
  }

  Widget _buildAccountCards() {
    // Define account items
    final accountItems = [
      {
        'title': LocaleKeys.routes_password_security.tr(),
        'icon': Icons.security_outlined,
        'description': LocaleKeys.general_change_password_info.tr(),
        'onTap': () {
          // Navigate to security page
        },
      },
      {
        'title': LocaleKeys.routes_language.tr(),
        'icon': Icons.language_outlined,
        'description': LocaleKeys.general_language_info.tr(),
        'onTap': () {
          // Navigate to language settings
        },
      },
      {
        'title': LocaleKeys.routes_theme.tr(),
        'icon': Icons.color_lens_outlined,
        'description': LocaleKeys.general_theme_info.tr(),
        'onTap': () {
          // Navigate to theme settings
        },
      },
    ];

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: accountItems.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemBuilder: (context, index) {
        final item = accountItems[index];
        return _buildNavigationCard(
          title: item['title'] as String,
          icon: item['icon'] as IconData,
          description: item['description'] as String,
          onTap: item['onTap'] as VoidCallback,
        );
      },
    );
  }

  Widget _buildNavigationCard({
    required String title,
    required IconData icon,
    required String description,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      color: ColorConstants.primary.withValues(alpha: .08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        overlayColor: WidgetStateProperty.all(
          ColorConstants.primary.withValues(alpha: .1),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
