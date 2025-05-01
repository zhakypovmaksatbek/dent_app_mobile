import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/presentation/theme/colors/color_constants.dart';
import 'package:flutter/material.dart';

enum AppointmentStatus {
  notConfirmed(
    key: 'not_confirmed',
    color: AppColors.red,
    label: LocaleKeys.appointment_status_not_confirmed,
  ),
  confirmed(
    key: 'confirmed',
    color: AppColors.cash,
    label: LocaleKeys.appointment_status_confirmed,
  ),
  comeIn(
    key: 'comein',
    color: AppColors.blue,
    label: LocaleKeys.appointment_status_come_in,
  ),
  finish(
    key: 'finish',
    color: AppColors.primary,
    label: LocaleKeys.appointment_status_finish,
  ),
  notCome(
    key: 'not_come',
    color: AppColors.optima,
    label: LocaleKeys.appointment_status_not_come,
  ),
  canceled(
    key: 'canceled',
    color: AppColors.grey,
    label: LocaleKeys.appointment_status_canceled,
  ),
  online(
    key: 'online',
    color: AppColors.mbank,
    label: LocaleKeys.appointment_status_online,
  );

  final String key;
  final Color color;
  final String label;

  const AppointmentStatus({
    required this.key,
    required this.color,
    required this.label,
  });

  static AppointmentStatus fromKey(String key) {
    return AppointmentStatus.values.firstWhere(
      (status) => status.key.toUpperCase() == key,
      orElse: () => AppointmentStatus.notConfirmed,
    );
  }
}
