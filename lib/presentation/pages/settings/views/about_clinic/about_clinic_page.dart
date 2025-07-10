import 'package:auto_route/auto_route.dart';
import 'package:dent_app_mobile/core/bloc/settings_cubit/settings_cubit.dart';
import 'package:dent_app_mobile/core/utils/currency.dart';
import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/models/clinic/clinic_model.dart';
import 'package:dent_app_mobile/presentation/theme/colors/color_constants.dart';
import 'package:dent_app_mobile/presentation/widgets/image/cashed_images.dart';
import 'package:dent_app_mobile/presentation/widgets/text/app_text.dart';
import 'package:dent_app_mobile/presentation/widgets/text/phone_number_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

@RoutePage(name: 'AboutClinicRoute')
class AboutClinicPage extends StatefulWidget {
  const AboutClinicPage({super.key});

  @override
  State<AboutClinicPage> createState() => _AboutClinicPageState();
}

class _AboutClinicPageState extends State<AboutClinicPage>
    with TickerProviderStateMixin {
  late final SettingsCubit settingsCubit;
  late final AnimationController _fadeController;
  late final AnimationController _scaleController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    settingsCubit = SettingsCubit();
    settingsCubit.getSettings();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _fadeController.forward();
    _scaleController.forward(from: 0.8);
  }

  @override
  void dispose() {
    settingsCubit.close();
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: ColorConstants.background,
      appBar: AppBar(
        title: Text(LocaleKeys.routes_about_clinic.tr()),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        bloc: settingsCubit,
        builder: (context, state) {
          if (state is SettingsLoading) {
            return const _LoadingView();
          }

          if (state is SettingsError) {
            return _ErrorView(error: state.error);
          }

          if (state is SettingsSuccess) {
            return _ClinicInfoView(
              clinic: state.clinic,
              fadeAnimation: _fadeAnimation,
              scaleAnimation: _scaleAnimation,
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(ColorConstants.primary),
          ),
          const SizedBox(height: 16),
          AppText(
            title: "Загрузка информации о клинике...",
            textType: TextType.body,
            color: ColorConstants.textSecondary,
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;

  const _ErrorView({required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: ColorConstants.error),
            const SizedBox(height: 16),
            AppText(
              title: "Ошибка загрузки",
              textType: TextType.header,
              color: ColorConstants.textPrimary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            AppText(
              title: error,
              textType: TextType.body,
              color: ColorConstants.textSecondary,
              textAlign: TextAlign.center,
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back),
              label: const Text("Вернуться"),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorConstants.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClinicInfoView extends StatelessWidget {
  final ClinicModel clinic;
  final Animation<double> fadeAnimation;
  final Animation<double> scaleAnimation;

  const _ClinicInfoView({
    required this.clinic,
    required this.fadeAnimation,
    required this.scaleAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: fadeAnimation.value,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero Section
                _HeroSection(clinic: clinic, scaleAnimation: scaleAnimation),

                const SizedBox(height: 32),

                // Information Cards
                _InfoCardsSection(clinic: clinic),

                const SizedBox(height: 24),

                // Working Hours
                _WorkingHoursSection(clinic: clinic),

                const SizedBox(height: 24),

                // Contact Information
                _ContactSection(clinic: clinic),

                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HeroSection extends StatelessWidget {
  final ClinicModel clinic;
  final Animation<double> scaleAnimation;

  const _HeroSection({required this.clinic, required this.scaleAnimation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: scaleAnimation.value,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  ColorConstants.primary.withValues(alpha: 0.1),
                  ColorConstants.secondary.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: ColorConstants.primary.withValues(alpha: 0.1),
              ),
            ),
            child: Column(
              children: [
                // Clinic Logo
                if (clinic.imageResponse?.link != null)
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: ColorConstants.primary.withValues(alpha: 0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: CashedImages(
                        imageUrl: clinic.imageResponse!.link!,
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                if (clinic.imageResponse?.link == null)
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: ColorConstants.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.local_hospital,
                      size: 60,
                      color: ColorConstants.primary,
                    ),
                  ),

                const SizedBox(height: 20),

                // Clinic Name
                AppText(
                  title: clinic.name ?? "Dental Clinic",
                  textType: TextType.title24,
                  fontWeight: FontWeight.bold,
                  color: ColorConstants.textPrimary,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                // Clinic Description
                AppText(
                  title: LocaleKeys.general_about_clinic_description.tr(),
                  textType: TextType.body,
                  color: ColorConstants.textSecondary,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _InfoCardsSection extends StatelessWidget {
  final ClinicModel clinic;

  const _InfoCardsSection({required this.clinic});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          title: "Информация",
          textType: TextType.title20,
          fontWeight: FontWeight.w600,
          color: ColorConstants.textPrimary,
        ),

        const SizedBox(height: 16),

        Row(
          children: [
            // Address Card
            Expanded(
              child: _InfoCard(
                icon: Icons.location_on,
                title: "Адрес",
                value: clinic.address ?? "Не указан",
                color: ColorConstants.error,
              ),
            ),

            const SizedBox(width: 12),

            // Currency Card
            Expanded(
              child: _InfoCard(
                icon: Icons.currency_exchange,
                title: "Валюта",
                value: Currency.fromCode(clinic.currency ?? "SOM").name.tr(),
                color: ColorConstants.success,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),

          const SizedBox(height: 12),

          AppText(
            title: title,
            textType: TextType.subtitle,
            color: ColorConstants.textSecondary,
          ),

          const SizedBox(height: 4),

          AppText(
            title: value,
            textType: TextType.body,
            fontWeight: FontWeight.w600,
            color: ColorConstants.textPrimary,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _WorkingHoursSection extends StatelessWidget {
  final ClinicModel clinic;

  const _WorkingHoursSection({required this.clinic});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          title: "Режим работы",
          textType: TextType.title20,
          fontWeight: FontWeight.w600,
          color: ColorConstants.textPrimary,
        ),

        const SizedBox(height: 16),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: ColorConstants.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  Icons.access_time,
                  color: ColorConstants.primary,
                  size: 24,
                ),
              ),

              const SizedBox(height: 16),

              AppText(
                title: "Время работы",
                textType: TextType.body,
                color: ColorConstants.textSecondary,
              ),

              const SizedBox(height: 8),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _TimeChip(
                    time: clinic.startWorkTime ?? "09:00",
                    label: "Открытие",
                    color: ColorConstants.success,
                  ),

                  const SizedBox(width: 12),

                  Container(
                    width: 30,
                    height: 2,
                    decoration: BoxDecoration(
                      color: ColorConstants.primary.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),

                  const SizedBox(width: 12),

                  _TimeChip(
                    time: clinic.endWorkTime ?? "18:00",
                    label: "Закрытие",
                    color: ColorConstants.error,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TimeChip extends StatelessWidget {
  final String time;
  final String label;
  final Color color;

  const _TimeChip({
    required this.time,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          AppText(
            title: time.substring(0, 5), // Remove seconds
            textType: TextType.body,
            fontWeight: FontWeight.bold,
            color: color,
          ),

          const SizedBox(height: 2),

          AppText(
            title: label,
            textType: TextType.description,
            color: ColorConstants.textSecondary,
          ),
        ],
      ),
    );
  }
}

class _ContactSection extends StatelessWidget {
  final ClinicModel clinic;

  const _ContactSection({required this.clinic});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          title: "Контакты",
          textType: TextType.title20,
          fontWeight: FontWeight.w600,
          color: ColorConstants.textPrimary,
        ),

        const SizedBox(height: 16),

        if (clinic.phoneNumber != null)
          _ContactCard(
            icon: Icons.phone,
            title: "Телефон",
            value: clinic.phoneNumber!,
            color: ColorConstants.primary,
            onTap: () => _makePhoneCall(clinic.phoneNumber!),
          ),

        if (clinic.address != null) ...[
          const SizedBox(height: 12),

          _ContactCard(
            icon: Icons.location_on,
            title: "Адрес",
            value: clinic.address!,
            color: ColorConstants.error,
            onTap: () => _openMap(clinic.address!),
          ),
        ],
      ],
    );
  }

  void _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  void _openMap(String address) async {
    final Uri mapUri = Uri(
      scheme: 'https',
      host: 'maps.google.com',
      path: '/search/',
      query: 'api=1&query=${Uri.encodeComponent(address)}',
    );
    if (await canLaunchUrl(mapUri)) {
      await launchUrl(mapUri, mode: LaunchMode.externalApplication);
    }
  }
}

class _ContactCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  final VoidCallback onTap;

  const _ContactCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: color, size: 24),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    title: title,
                    textType: TextType.subtitle,
                    color: ColorConstants.textSecondary,
                  ),

                  const SizedBox(height: 4),

                  if (icon == Icons.phone)
                    PhoneNumberText(
                      phoneNumber: value,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: ColorConstants.textPrimary,
                      ),
                    )
                  else
                    AppText(
                      title: value,
                      textType: TextType.body,
                      fontWeight: FontWeight.w600,
                      color: ColorConstants.textPrimary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),

            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: ColorConstants.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
