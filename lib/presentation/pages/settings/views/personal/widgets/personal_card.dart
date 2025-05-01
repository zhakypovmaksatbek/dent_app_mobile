import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/main.dart';
import 'package:dent_app_mobile/models/users/user_model.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/personal/core/util/text_extension.dart';
import 'package:dent_app_mobile/presentation/widgets/text/app_text.dart';
import 'package:dent_app_mobile/router/app_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class PersonalCard extends StatelessWidget {
  const PersonalCard({
    super.key,
    required this.decoration,
    required this.user,
    required this.theme,
    this.onEditPressed,
    this.onDeletePressed,
  });

  final BoxDecoration decoration;
  final UserModel user;
  final ThemeData theme;
  final VoidCallback? onEditPressed;
  final VoidCallback? onDeletePressed;

  // --- Constants for Styling ---
  static const double _cardPadding = 12.0;
  static const double _popupMenuIconSize = 20.0;
  static const double _popupMenuSplashRadius = 20.0;
  static const Offset _popupMenuOffset = Offset(0, 25);
  static const double _interItemSpacing = 4.0; // Consistent spacing
  static const double _popupMenuLeftPadding = 8.0;
  static const double _secondaryTextAlpha = 0.7;
  static final router = getIt<AppRouter>();
  @override
  Widget build(BuildContext context) {
    // Helper to build the secondary info lines consistently
    Widget buildInfoLine(String text) {
      return AppText(
        title: text,
        textType: TextType.subtitle,
        // Use a slightly subdued color for secondary info
        color: theme.textTheme.bodySmall?.color?.withOpacity(
          _secondaryTextAlpha,
        ),
      );
    }

    // Build the PopupMenuButton only if there are actions
    final Widget? trailingActions = _buildPopupMenuButton(context);

    return GestureDetector(
      onTap: () {
        router.push(PersonalDetailRoute(userId: user.id!));
      },
      child: Container(
        decoration: decoration,
        padding: const EdgeInsets.all(_cardPadding),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User information section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min, // Take minimum vertical space
                children: [
                  // User's Full Name
                  AppText(
                    // Provide a fallback, maybe from locale keys if appropriate
                    title:
                        user.fullName?.isNotEmpty ?? false
                            ? user.fullName!
                            : "-", // Example fallback
                    textType: TextType.body,
                    fontWeight: FontWeight.w600,
                  ),

                  // Consistent spacing using SizedBox
                  const SizedBox(
                    height: _interItemSpacing * 1.5,
                  ), // Slightly more space after name
                  // Email (if available)
                  if (user.email?.isNotEmpty ?? false) ...[
                    buildInfoLine(user.email!),
                    const SizedBox(height: _interItemSpacing),
                  ],

                  // Phone Number (if visible and available)
                  if (user.isVisibilityPhoneNumber == true &&
                      user.phoneNumber?.isNotEmpty == true) ...[
                    buildInfoLine(user.phoneNumber!),
                    const SizedBox(height: _interItemSpacing),
                  ],

                  // Salary (if available)
                  if (user.salary != null) _buildSalaryInfo(context),
                ],
              ),
            ),

            // Actions menu (if available)
            if (trailingActions != null)
              Padding(
                padding: const EdgeInsets.only(left: _popupMenuLeftPadding),
                child: trailingActions,
              ),
          ],
        ),
      ),
    );
  }

  // Helper method to build the salary information line
  Widget _buildSalaryInfo(BuildContext context) {
    final String salaryType =
        user.percentOrFixed == 'PERCENT'
            ? '%'
            : LocaleKeys.forms_fixed
                .tr(); // Assuming a key like 'general_fixed' exists

    return AppText(
      title:
          "${LocaleKeys.general_salary.tr()}: ${user.salary?.toIntString()} ($salaryType)",
      textType: TextType.subtitle,
      color: theme.colorScheme.primary, // Highlight salary info
      fontWeight: FontWeight.w500,
    );
  }

  // Helper method to build the PopupMenuButton
  Widget? _buildPopupMenuButton(BuildContext context) {
    // Only build the button if there's at least one action
    if (onEditPressed == null && onDeletePressed == null) {
      return null;
    }

    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, size: _popupMenuIconSize),
      tooltip: LocaleKeys.general_general_options.tr(), // Localized tooltip
      onSelected: (String result) {
        switch (result) {
          case 'edit':
            onEditPressed?.call();
            break;
          case 'delete':
            onDeletePressed?.call();
            break;
        }
      },
      itemBuilder:
          (BuildContext context) => <PopupMenuEntry<String>>[
            // Edit Action
            if (onEditPressed != null)
              PopupMenuItem<String>(
                value: 'edit',
                child: Text(LocaleKeys.buttons_edit.tr()), // Localized text
              ),
            // Delete Action
            if (onDeletePressed != null)
              PopupMenuItem<String>(
                value: 'delete',
                child: Text(
                  LocaleKeys.buttons_delete.tr(), // Localized text
                  style: TextStyle(
                    color: theme.colorScheme.error, // Use theme's error color
                  ),
                ),
              ),
          ],
      // Use constants for styling
      padding: EdgeInsets.zero,
      splashRadius: _popupMenuSplashRadius,
      constraints:
          const BoxConstraints(), // Keep default constraints unless needed
      offset: _popupMenuOffset,
    );
  }
}

// --- Helper Extension for Color Opacity (Optional but Cleaner) ---
// Consider adding this to a general utility file if used elsewhere
extension ColorOpacity on Color {
  Color withOpacity(double opacity) {
    assert(opacity >= 0.0 && opacity <= 1.0);
    return withAlpha((255.0 * opacity).round());
  }
}
