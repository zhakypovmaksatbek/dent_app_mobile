import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/presentation/theme/colors/color_constants.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:teeth_selector/teeth_selector.dart';

/// Widget that displays the dental chart with teeth selection functionality
class TeethSelectorWidget extends StatelessWidget {
  final Function(List<String>) onTeethSelected;
  final Map<String, Color> teethColorMap;

  const TeethSelectorWidget({
    super.key,
    required this.onTeethSelected,
    required this.teethColorMap,
  });

  @override
  Widget build(BuildContext context) {
    return TeethSelector(
      onChange: onTeethSelected,
      // Show permanent teeth
      showPermanent: true,
      // Show primary (child) teeth
      showPrimary: true,
      // Allow selection of multiple teeth
      multiSelect: false,
      // Color for selected teeth
      selectedColor: ColorConstants.primary,
      // Color for unselected teeth
      unselectedColor: Colors.white,
      // Color for tooltip
      tooltipColor: ColorConstants.primary,
      // Colorize teeth based on treatment data
      StrokedColorized: teethColorMap,
      // Default stroke color for teeth outline
      defaultStrokeColor: Colors.grey.withValues(alpha: .3),
      // Width of stroke for specific teeth
      strokeWidth: const {},
      // Default stroke width
      defaultStrokeWidth: 1.0,
      // Text for left side
      leftString: LocaleKeys.general_left.tr(),
      // Text for right side
      rightString: LocaleKeys.general_right.tr(),
    );
  }
}
