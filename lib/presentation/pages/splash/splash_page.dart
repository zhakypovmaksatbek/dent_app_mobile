import 'package:animate_do/animate_do.dart';
import 'package:auto_route/auto_route.dart';
import 'package:dent_app_mobile/core/data/app_data_service.dart';
import 'package:dent_app_mobile/core/service/dio_settings.dart';
import 'package:dent_app_mobile/core/service/environment_service.dart';
import 'package:dent_app_mobile/main.dart';
import 'package:dent_app_mobile/presentation/constants/asset_constants.dart';
import 'package:dent_app_mobile/presentation/theme/colors/color_constants.dart';
import 'package:dent_app_mobile/presentation/widgets/text/app_text.dart';
import 'package:dent_app_mobile/router/app_router.dart';
import 'package:flutter/material.dart';

@RoutePage(name: 'SplashRoute')
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  int _tapCount = 0;
  DateTime? _lastTapTime;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 4), () {
      route();
    });
  }

  void route() async {
    final bool isLoggedIn = await AppDataService.instance.getIsLogin();
    if (isLoggedIn) {
      getIt<AppRouter>().replace(const MainRoute());
    } else {
      getIt<AppRouter>().replace(const LoginRoute());
    }
  }

  void _handleTap() {
    final now = DateTime.now();

    if (_lastTapTime == null ||
        now.difference(_lastTapTime!) > const Duration(seconds: 2)) {
      _tapCount = 1;
    } else {
      _tapCount++;
    }

    _lastTapTime = now;

    if (_tapCount >= 5) {
      _tapCount = 0;
      _showTestModeBottomSheet();
    }
  }

  // splash_page.dart
  void _showTestModeBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: ColorConstants.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final environmentService = getIt<EnvironmentService>();

        return FutureBuilder<bool>(
          future: AppDataService.instance.isTestMode(),
          builder: (context, snapshot) {
            final isCurrentlyTestMode = snapshot.data ?? false;

            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Icon(
                    Icons.science_outlined,
                    size: 48,
                    color: isCurrentlyTestMode
                        ? Colors.orange[700]
                        : Colors.blue[700],
                  ),
                  const SizedBox(height: 16),
                  AppText(
                    title: isCurrentlyTestMode
                        ? "Test Mode Active"
                        : "Production Mode",
                    textType: TextType.title,
                  ),
                  const SizedBox(height: 12),
                  AppText(
                    title: isCurrentlyTestMode
                        ? "Switch to production mode?"
                        : "Switch to test mode?",
                    textType: TextType.body,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: const BorderSide(
                              color: ColorConstants.primary,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const AppText(
                            title: "Cancel",
                            textType: TextType.body,
                            color: ColorConstants.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            await environmentService.toggleTestMode();

                            // DioService'i güncelle
                            getIt<DioService>().updateBaseUrl();

                            if (mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    isCurrentlyTestMode
                                        ? 'Production mode enabled'
                                        : 'Test mode enabled',
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            backgroundColor: ColorConstants.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const AppText(
                            title: "Switch",
                            textType: TextType.body,
                            color: ColorConstants.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).padding.bottom),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(color: ColorConstants.primary),
        child: Stack(
          children: [
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color.fromARGB(
                    255,
                    255,
                    255,
                    255,
                  ).withValues(alpha: .1),
                ),
              ),
            ),
            Positioned(
              bottom: -50,
              left: -50,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color.fromARGB(
                    255,
                    255,
                    255,
                    255,
                  ).withValues(alpha: .1),
                ),
              ),
            ),
            FadeIn(
              duration: const Duration(seconds: 3),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 130,
                            height: 130,
                            child: Center(
                              child: Image.asset(
                                AssetConstants.toothLogo.png,
                                width: 120,
                                height: 120,
                                fit: BoxFit.contain,
                                color: ColorConstants.white,
                              ),
                            ),
                          ),
                          SizedBox(height: 30),
                          Text(
                            "DentApp",
                            style: TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                              color: ColorConstants.white,
                            ),
                          ),
                          SizedBox(height: 15),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).padding.bottom + 10,
                    ),
                    child: Column(
                      children: [
                        AppText(
                          title: "from",
                          textType: TextType.body,
                          color: ColorConstants.white,
                        ),
                        SizedBox(height: 5),
                        GestureDetector(
                          onTap: _handleTap,
                          child: AppText(
                            title: "Aksoft",
                            textType: TextType.title,
                            color: ColorConstants.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
