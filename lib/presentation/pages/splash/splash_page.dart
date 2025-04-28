import 'package:auto_route/auto_route.dart';
import 'package:dent_app_mobile/core/data/app_data_service.dart';
import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/main.dart';
import 'package:dent_app_mobile/presentation/constants/asset_constants.dart';
import 'package:dent_app_mobile/presentation/theme/colors/color_constants.dart';
import 'package:dent_app_mobile/presentation/widgets/text/app_text.dart';
import 'package:dent_app_mobile/router/app_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

@RoutePage(name: 'SplashRoute')
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), () {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [ColorConstants.primary, ColorConstants.black],
          ),
        ),
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
                  // color: const Color(0xFF6770CC).withOpacity(0.1),
                  color: const Color.fromARGB(
                    255,
                    255,
                    255,
                    255,
                  ).withValues(alpha: .1),
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 130,
                          height: 130,
                          decoration: BoxDecoration(
                            color: const Color(0xFF6770CC),
                            // color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                // color:
                                //     const Color(0xFF6770CC).withOpacity(0.3),
                                color: const Color.fromARGB(
                                  255,
                                  255,
                                  255,
                                  255,
                                ).withValues(alpha: .4),
                                blurRadius: 30,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Image.asset(
                              AssetConstants.toothLogo.png,
                              width: 90,
                              height: 90,
                              fit: BoxFit.contain,
                              color: ColorConstants.white,
                            ),
                          ),
                        ),
                        SizedBox(height: 30),
                        AppText(
                          title: "DentApp Mobile",
                          textType: TextType.title,
                          color: ColorConstants.white,
                        ),
                        SizedBox(height: 15),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: ColorConstants.white.withValues(alpha: .1),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: AppText(
                            title: LocaleKeys.general_splash.tr(),
                            textType: TextType.body,
                            color: ColorConstants.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 40),
                  child: Column(
                    children: [
                      AppText(
                        title: "from",
                        textType: TextType.body,
                        color: ColorConstants.white,
                      ),
                      SizedBox(height: 5),
                      AppText(
                        title: "Aksoft",
                        textType: TextType.body,
                        color: ColorConstants.white,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
