// lib/presentation/pages/splash/splash_page.dart

import 'dart:async';

import 'package:animate_do/animate_do.dart';
import 'package:auto_route/auto_route.dart';
import 'package:dent_app_mobile/core/config/environment_config.dart';
import 'package:dent_app_mobile/core/data/app_data_service.dart';
import 'package:dent_app_mobile/core/locator/locator.dart';
import 'package:dent_app_mobile/core/manager/test_mode_manager.dart';
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
  late final TestModeManager _testModeManager;
  bool _isNavigating = false;
  Timer? _navigationTimer; // ✅ Timer reference

  @override
  void initState() {
    super.initState();
    _testModeManager = getIt<TestModeManager>();
    _startNavigationTimer();
  }

  @override
  void dispose() {
    _navigationTimer?.cancel(); // ✅ Clean up timer
    super.dispose();
  }

  // ✅ Start navigation timer
  void _startNavigationTimer() {
    _navigationTimer = Timer(const Duration(seconds: 4), () {
      if (mounted && !_isNavigating) {
        _route();
      }
    });
  }

  // ✅ Cancel navigation timer
  void _cancelNavigationTimer() {
    _navigationTimer?.cancel();
    _navigationTimer = null;
  }

  // ✅ Restart navigation timer
  void _restartNavigationTimer() {
    _cancelNavigationTimer();
    _startNavigationTimer();
  }

  Future<void> _route() async {
    if (_isNavigating) return;

    setState(() => _isNavigating = true);

    // ✅ Reset tap counter when navigating away
    _testModeManager.resetTapCounter();

    final bool isLoggedIn = await AppDataService.instance.getIsLogin();

    if (!mounted) return;

    if (isLoggedIn) {
      router.replace(const MainRoute());
    } else {
      router.replace(const LoginRoute());
    }
  }

  Future<void> _handleTap() async {
    if (_isNavigating) return;

    // ✅ Use TestModeManager
    final modeChanged = await _testModeManager.handleTap();

    if (!mounted) return;

    // ✅ Show bottom sheet only when mode changes
    if (modeChanged) {
      // ✅ CRITICAL: Cancel timer when bottom sheet opens
      _cancelNavigationTimer();

      await _showTestModeConfirmation();

      // ✅ Restart timer after bottom sheet closes
      if (mounted && !_isNavigating) {
        _restartNavigationTimer();
      }
    }
  }

  Future<void> _showTestModeConfirmation() async {
    final isTestMode = _testModeManager.kTestMode;

    final result = await showModalBottomSheet(
      context: context,
      isDismissible: false, // ✅ Prevent accidental dismiss
      enableDrag: false, // ✅ Prevent swipe dismiss
      backgroundColor: ColorConstants.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return PopScope(
          canPop: false, // ✅ Prevent back button dismiss
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ✅ Handle indicator
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),

                // ✅ Icon
                Icon(
                  Icons.science_outlined,
                  size: 48,
                  color: isTestMode ? Colors.orange[700] : Colors.blue[700],
                ),
                const SizedBox(height: 16),

                // ✅ Title
                AppText(
                  title: isTestMode
                      ? "🧪 Test Mode Enabled"
                      : "🚀 Production Mode",
                  textType: TextType.title,
                ),
                const SizedBox(height: 12),

                // ✅ Subtitle with environment info
                Column(
                  children: [
                    AppText(
                      title: "Environment changed successfully!",
                      textType: TextType.body,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    AppText(
                      title: "Base URL: ${EnvironmentConfig.baseUrl}",
                      textType: TextType.description,
                      textAlign: TextAlign.center,
                      color: Colors.grey[600],
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ✅ Info box
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isTestMode ? Colors.orange[50] : Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isTestMode
                          ? Colors.orange[200]!
                          : Colors.blue[200]!,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 20,
                        color: isTestMode
                            ? Colors.orange[700]
                            : Colors.blue[700],
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: AppText(
                          title: isTestMode
                              ? "All API calls will use TEST server"
                              : "All API calls will use PRODUCTION server",
                          textType: TextType.description,
                          color: isTestMode
                              ? Colors.orange[900]
                              : Colors.blue[900],
                        ),
                      ),
                    ],
                  ),
                ),

                // ✅ Warning box for token clearing
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        size: 20,
                        color: Colors.red[700],
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: AppText(
                          title:
                              "Your session will be cleared and you'll be logged out",
                          textType: TextType.description,
                          color: Colors.red[900],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ✅ Action buttons
                Row(
                  children: [
                    // Undo button (revert and continue splash)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          // ✅ Revert test mode
                          Navigator.pop(context, false);
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(color: ColorConstants.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: const Icon(Icons.undo, size: 18),
                        label: const AppText(
                          title: "Undo",
                          textType: TextType.body,
                          color: ColorConstants.primary,
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Continue button (clear tokens and go to login)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          Navigator.pop(context, true);
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: ColorConstants.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: const Icon(Icons.check, size: 18),
                        label: const AppText(
                          title: "Continue",
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
          ),
        );
      },
    );
    if (!mounted) return;

    if (result == true) {
      // ✅ User clicked "Continue" - clear tokens and go to login
      await _handleTestModeAccepted(isTestMode);
    } else if (result == false) {
      // ✅ User clicked "Undo" - show undo message
      _showUndoMessage(isTestMode);
    }
  }

  Future<void> _handleTestModeAccepted(bool wasTestMode) async {
    if (!mounted) return;

    // Show loading
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            SizedBox(width: 12),
            Text('Clearing session...'),
          ],
        ),
        duration: Duration(seconds: 2),
      ),
    );

    // ✅ Clear tokens
    await AppDataService.instance.clearTokens();

    // Small delay for UX
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    // ✅ Navigate to login
    setState(() => _isNavigating = true);
    _testModeManager.resetTapCounter();

    router.replace(const LoginRoute());

    // ✅ Show success message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            wasTestMode
                ? '🧪 Test Mode active - Logged out'
                : '🚀 Production Mode active - Logged out',
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  // ✅ Separate method for showing undo message
  void _showUndoMessage(bool wasTestMode) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          wasTestMode
              ? '✅ Reverted to Production mode'
              : '✅ Reverted to Test mode',
        ),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(color: ColorConstants.primary),
        child: Stack(
          children: [
            // ✅ Background decorations
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.1),
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
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
            ),

            // ✅ Main content
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
                          const SizedBox(height: 30),
                          const Text(
                            "DentApp",
                            style: TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                              color: ColorConstants.white,
                            ),
                          ),
                          const SizedBox(height: 15),

                          // ✅ Test mode indicator
                          if (kTestMode)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.orange,
                                  width: 2,
                                ),
                              ),
                              child: const Text(
                                '🧪 TEST MODE',
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  // ✅ Footer with tap counter indicator
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).padding.bottom + 10,
                    ),
                    child: Column(
                      children: [
                        // ✅ Tap progress indicator
                        if (_testModeManager.tapCount > 0 && !_isNavigating)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(5, (index) {
                                return Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: index < _testModeManager.tapCount
                                        ? Colors.orange
                                        : Colors.white.withValues(alpha: 0.3),
                                  ),
                                );
                              }),
                            ),
                          ),

                        const AppText(
                          title: "from",
                          textType: TextType.body,
                          color: ColorConstants.white,
                        ),
                        const SizedBox(height: 5),

                        // ✅ Tap target
                        GestureDetector(
                          onTap: _handleTap,
                          child: const AppText(
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
