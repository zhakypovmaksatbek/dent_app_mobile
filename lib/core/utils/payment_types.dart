import 'dart:ui';

import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/presentation/constants/asset_constants.dart';
import 'package:dent_app_mobile/presentation/theme/colors/color_constants.dart';
import 'package:easy_localization/easy_localization.dart';

enum PaymentType { cash, card, mbank, optima }

extension PaymentTypeExtension on PaymentType {
  String get title {
    switch (this) {
      case PaymentType.cash:
        return LocaleKeys.report_cash.tr();
      case PaymentType.card:
        return LocaleKeys.general_card.tr();
      case PaymentType.mbank:
        return LocaleKeys.report_mbank.tr();
      case PaymentType.optima:
        return LocaleKeys.report_optima.tr();
    }
  }

  String get icon {
    switch (this) {
      case PaymentType.cash:
        return AssetConstants.cash.png;
      case PaymentType.card:
        return AssetConstants.card.png;
      case PaymentType.mbank:
        return AssetConstants.mbank.png;
      case PaymentType.optima:
        return AssetConstants.optima.png;
    }
  }

  Color get color {
    switch (this) {
      case PaymentType.cash:
        return AppColors.cash;
      case PaymentType.card:
        return AppColors.card;
      case PaymentType.mbank:
        return AppColors.mbank;
      case PaymentType.optima:
        return AppColors.optima;
    }
  }

  // from string
  static PaymentType fromString(String value) {
    switch (value) {
      case 'CASH':
        return PaymentType.cash;
      case 'CARD':
        return PaymentType.card;
      case 'MBANK':
        return PaymentType.mbank;
      case 'OPTIMA':
        return PaymentType.optima;
      default:
        return PaymentType.cash;
    }
  }
}
