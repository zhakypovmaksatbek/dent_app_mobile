import 'package:animate_do/animate_do.dart';
import 'package:auto_route/auto_route.dart';
import 'package:dent_app_mobile/core/data/app_data_service.dart';
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
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
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
                        AppText(
                          title: "Aksoft",
                          textType: TextType.title,
                          color: ColorConstants.white,
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
