import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/presentation/pages/treatment/utils/tooth_type.dart';
import 'package:dent_app_mobile/presentation/widgets/image/custom_asset_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class ToothTypeCard extends StatelessWidget {
  final ToothType toothType;
  final bool isSelected;
  final VoidCallback onTap;

  const ToothTypeCard({
    super.key,
    required this.toothType,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient:
              isSelected
                  ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.primaryColor,
                      theme.primaryColor.withValues(alpha: 0.8),
                    ],
                  )
                  : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.surface,
                      theme.colorScheme.surface.withValues(alpha: 0.8),
                    ],
                  ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                isSelected
                    ? theme.primaryColor.withValues(alpha: 0.5)
                    : theme.dividerColor.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            if (isSelected) ...[
              BoxShadow(
                color: theme.primaryColor.withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 6),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: theme.primaryColor.withValues(alpha: 0.2),
                blurRadius: 24,
                offset: const Offset(0, 12),
                spreadRadius: 0,
              ),
            ] else ...[
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
                spreadRadius: 0,
              ),
            ],
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background pattern for selected state
            if (isSelected)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: RadialGradient(
                      center: Alignment.topRight,
                      radius: 1.2,
                      colors: [
                        Colors.white.withValues(alpha: 0.1),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

            // Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // SVG Icon with background
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? Colors.white.withValues(alpha: 0.25)
                              : theme.primaryColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: CustomAssetImage(
                        path: _getToothTypeSvgPath(toothType),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Title
                  Text(
                    toothType.title,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color:
                          isSelected
                              ? Colors.white
                              : theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 2),

                  // Subtitle
                  Text(
                    _getToothTypeSubtitle(toothType),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color:
                          isSelected
                              ? Colors.white.withValues(alpha: 0.8)
                              : theme.colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                      fontSize: 10,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Selection indicator
            if (isSelected)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(Icons.check, color: theme.primaryColor, size: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getToothTypeSvgPath(ToothType toothType) {
    switch (toothType) {
      case ToothType.main:
        return 'assets/svg/tooth_main.svg';
      case ToothType.right:
        return 'assets/svg/tooth_right.svg';
      case ToothType.left:
        return 'assets/svg/tooth_left.svg';
      case ToothType.top:
        return 'assets/svg/tooth_top.svg';
      case ToothType.bottom:
        return 'assets/svg/tooth_bottom.svg';
      case ToothType.jaw:
        return 'assets/svg/tooth_jaw.svg';
      case ToothType.centerRight:
        return 'assets/svg/tooth_center_right.svg';
      case ToothType.centerLeft:
        return 'assets/svg/tooth_center_left.svg';
      case ToothType.all:
        return 'assets/svg/tooth_all.svg';
    }
  }

  String _getToothTypeSubtitle(ToothType toothType) {
    switch (toothType) {
      case ToothType.main:
        return LocaleKeys.tooth_main_treatment.tr();
      case ToothType.right:
        return LocaleKeys.tooth_right_treatment.tr();
      case ToothType.left:
        return LocaleKeys.tooth_left_treatment.tr();
      case ToothType.top:
        return LocaleKeys.tooth_top_treatment.tr();
      case ToothType.bottom:
        return LocaleKeys.tooth_bottom_treatment.tr();
      case ToothType.jaw:
        return LocaleKeys.tooth_jaw_treatment.tr();
      case ToothType.centerRight:
        return LocaleKeys.tooth_center_right_treatment.tr();
      case ToothType.centerLeft:
        return LocaleKeys.tooth_center_left_treatment.tr();
      case ToothType.all:
        return LocaleKeys.tooth_all_treatment.tr();
    }
  }
}
