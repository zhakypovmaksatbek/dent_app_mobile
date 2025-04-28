import 'dart:ui';

import 'package:dent_app_mobile/generated/codegen_loader.g.dart';
import 'package:easy_localization/easy_localization.dart';

final class AppLocalization extends EasyLocalization {
  AppLocalization({super.key, required super.child})
    : super(
        path: localePath,
        fallbackLocale: Locales.ru.locale,
        startLocale: Locales.ru.locale,
        useOnlyLangCode: true,
        supportedLocales: _supportedLocales,
        assetLoader: const CodegenLoader(),
      );

  static const String localePath = 'assets/translations';
  static final List<Locale> _supportedLocales = [
    // Locales.en.locale,
    // Locales.ky.locale,
    Locales.ru.locale,
  ];
}

enum Locales {
  // en(Locale('en')),
  ru(Locale('ru'));

  final Locale locale;
  const Locales(this.locale);
}
