import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/main.dart';
import 'package:dent_app_mobile/presentation/pages/settings/settings_page.dart';
import 'package:dent_app_mobile/router/app_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

mixin SettingsMixin on State<SettingsPage> {
  final adminNavItems = [
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
      'title': LocaleKeys.routes_about_clinic.tr(),
      'icon': Icons.business_outlined,
      'description': LocaleKeys.general_about_clinic_description.tr(),
      'onTap': () {
        router.push(const AboutClinicRoute());
      },
    },
    {
      'title': LocaleKeys.routes_warehouse.tr(),
      'icon': Icons.warehouse_outlined,
      'description': LocaleKeys.general_warehouse_info.tr(),
      'onTap': () {
        router.push(const WarehouseRoute());
      },
    },
    // {
    //   'title': LocaleKeys.routes_notifications.tr(),
    //   'icon': Icons.notifications_outlined,
    //   'description': LocaleKeys.general_notifications_info_description.tr(),
    //   'onTap': () {
    //     // Navigate to notifications settings
    //   },
    // },
  ];
  final doctorNavItems = [
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
      'title': LocaleKeys.routes_about_clinic.tr(),
      'icon': Icons.business_outlined,
      'description': LocaleKeys.general_about_clinic_description.tr(),
      'onTap': () {
        router.push(const AboutClinicRoute());
      },
    },

    // {
    //   'title': LocaleKeys.routes_notifications.tr(),
    //   'icon': Icons.notifications_outlined,
    //   'description': LocaleKeys.general_notifications_info_description.tr(),
    //   'onTap': () {
    //     // Navigate to notifications settings
    //   },
    // },
  ];

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
}
