import 'package:auto_route/auto_route.dart';
import 'package:dent_app_mobile/core/data/app_data_service.dart';
import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/main.dart';
import 'package:dent_app_mobile/presentation/pages/settings/settings_mixin.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/personal/core/util/roles.dart';
import 'package:dent_app_mobile/presentation/pages/settings/widgets/profile_section.dart';
import 'package:dent_app_mobile/presentation/theme/colors/color_constants.dart';
import 'package:dent_app_mobile/presentation/widgets/buttons/def_elevated_button.dart';
import 'package:dent_app_mobile/presentation/widgets/loading/loading_widget.dart';
import 'package:dent_app_mobile/presentation/widgets/notification/app_bottom_sheet.dart';
import 'package:dent_app_mobile/presentation/widgets/notification/confirmation_bottom_sheet.dart';
import 'package:dent_app_mobile/router/app_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

@RoutePage(name: 'SettingsRoute')
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> with SettingsMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(LocaleKeys.routes_profile.tr()), elevation: 0),
      body: FutureBuilder<Role>(
        future: AppDataService.instance.getRole(),
        builder: (context, asyncSnapshot) {
          if (asyncSnapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget();
          }
          return SingleChildScrollView(
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
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildNavigationCards(asyncSnapshot.data ?? Role.doctor),
                // Padding(
                //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
                //   child: Text(
                //     LocaleKeys.routes_account.tr(),
                //     style: Theme.of(context).textTheme.titleLarge?.copyWith(
                //       fontWeight: FontWeight.bold,
                //     ),
                //   ),
                // ),
                // const SizedBox(height: 16),
                // _buildAccountCards(),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: DefElevatedButton(
                      title: LocaleKeys.buttons_logout.tr(),
                      onPressed: () async {
                        AppBottomSheet.showBottomSheet(
                          context,
                          ConfirmationBottomSheet(
                            title: LocaleKeys.notifications_logout_info.tr(),
                            description: LocaleKeys
                                .notifications_logout_info_description
                                .tr(),
                            confirmButtonText: LocaleKeys.buttons_logout.tr(),
                            cancelButtonText: LocaleKeys.buttons_cancel.tr(),
                            onConfirm: () async {
                              await AppDataService.instance.clearTokens();
                              router.replaceAll([const LoginRoute()]);
                            },
                            onCancel: () => router.maybePop(),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNavigationCards(Role currentRole) {
    // Define navigation items

    final navItems = currentRole == Role.admin ? adminNavItems : doctorNavItems;

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
