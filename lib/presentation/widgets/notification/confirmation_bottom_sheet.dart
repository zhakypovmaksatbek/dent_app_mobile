import 'package:dent_app_mobile/presentation/theme/colors/color_constants.dart';
import 'package:dent_app_mobile/presentation/widgets/buttons/custom_close_button.dart';
import 'package:dent_app_mobile/presentation/widgets/buttons/def_elevated_button.dart';
import 'package:dent_app_mobile/presentation/widgets/text/app_text.dart';
import 'package:flutter/material.dart';

class ConfirmationBottomSheet extends StatelessWidget {
  final String title;
  final String description;
  final String confirmButtonText;
  final String cancelButtonText;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const ConfirmationBottomSheet({
    super.key,
    required this.title,
    required this.description,
    required this.confirmButtonText,
    required this.cancelButtonText,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      margin: const EdgeInsets.only(bottom: 16, right: 8, left: 8),
      decoration: BoxDecoration(
        color: theme.appBarTheme.backgroundColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Close button
          Align(alignment: Alignment.topRight, child: CustomCloseButton()),

          const SizedBox(height: 8),

          // Warning icon
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: theme.disabledColor),
            ),
            child: Icon(
              Icons.sentiment_dissatisfied_outlined,
              color: AppColors.red,
              size: 32,
            ),
          ),

          const SizedBox(height: 24),

          // Title
          AppText(
            title: title,
            textType: TextType.title20,
            fontWeight: FontWeight.w600,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Description
          AppText(
            title: description,
            textType: TextType.body,
            color: theme.textTheme.bodySmall?.color,
            textAlign: TextAlign.center,
            maxLines: 4,
          ),

          const SizedBox(height: 32),

          // Confirm button
          DefElevatedButton(
            title: confirmButtonText,
            onPressed: onConfirm,
            backgroundColor: theme.colorScheme.error,
          ),

          const SizedBox(height: 12),
          DefElevatedButton(
            title: cancelButtonText,
            onPressed: onCancel,
            backgroundColor: AppColors.grey,
          ),

          // Cancel button
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
