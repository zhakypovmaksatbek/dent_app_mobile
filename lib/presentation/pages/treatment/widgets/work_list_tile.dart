// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:dent_app_mobile/presentation/widgets/text/app_text.dart';
import 'package:flutter/material.dart';

class WorkListTile extends StatelessWidget {
  const WorkListTile({
    super.key,
    required this.navigateTo,
    required this.jobCount,
    required this.title,
    required this.iconData,
  });

  final VoidCallback navigateTo;
  final int jobCount;
  final String title;
  final IconData iconData;
  // Constants
  static const double _cardMargin = 16.0;
  static const double _cardVerticalMargin = 8.0;
  static const double _cardRadius = 16.0;
  static const double _cardElevation = 4.0;
  static const double _cardPadding = 20.0;
  static const double _iconSize = 24.0;
  static const double _iconPadding = 12.0;
  static const double _iconRadius = 12.0;
  static const double _iconShadowBlur = 8.0;
  static const double _iconShadowOffset = 4.0;
  static const double _badgeRadius = 20.0;
  static const double _badgeShadowBlur = 6.0;
  static const double _badgeShadowOffset = 2.0;
  static const double _arrowIconSize = 16.0;
  static const double _arrowContainerSize = 8.0;
  static const double _contentSpacing = 16.0;
  static const double _badgeSpacing = 12.0;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: _cardMargin,
        vertical: _cardVerticalMargin,
      ),
      child: Material(
        elevation: _cardElevation,
        borderRadius: BorderRadius.circular(_cardRadius),
        color: Colors.white,
        shadowColor: theme.colorScheme.primary.withValues(alpha: 0.1),
        child: InkWell(
          onTap: navigateTo,
          borderRadius: BorderRadius.circular(_cardRadius),
          child: Container(
            decoration: _buildCardDecoration(theme),
            child: Padding(
              padding: const EdgeInsets.all(_cardPadding),
              child: Row(
                children: [_buildCardContent(theme), _buildCardActions(theme)],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Creates card decoration with gradient
  BoxDecoration _buildCardDecoration(ThemeData theme) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(_cardRadius),
      gradient: LinearGradient(
        colors: [
          theme.colorScheme.primary.withValues(alpha: 0.05),
          theme.colorScheme.secondary.withValues(alpha: 0.08),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    );
  }

  /// Builds the main content of the card (icon + text)
  Widget _buildCardContent(ThemeData theme) {
    return Expanded(
      child: Row(
        children: [
          _buildCardIcon(theme),
          const SizedBox(width: _contentSpacing),
          _buildCardTitle(theme),
        ],
      ),
    );
  }

  /// Builds the card icon with styling
  Widget _buildCardIcon(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(_iconPadding),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(_iconRadius),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: _iconShadowBlur,
            offset: const Offset(0, _iconShadowOffset),
          ),
        ],
      ),
      child: Icon(iconData, color: Colors.white, size: _iconSize),
    );
  }

  /// Builds the card title
  Widget _buildCardTitle(ThemeData theme) {
    return Expanded(
      child: AppText(
        title: title,
        textType: TextType.header,
        color: theme.colorScheme.onSurface,
      ),
    );
  }

  /// Builds the card actions (badge + arrow)
  Widget _buildCardActions(ThemeData theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildJobCountBadge(theme),
        const SizedBox(width: _badgeSpacing),
        _buildArrowIcon(theme),
      ],
    );
  }

  /// Builds the job count badge
  Widget _buildJobCountBadge(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: _iconPadding,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(_badgeRadius),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: _badgeShadowBlur,
            offset: const Offset(0, _badgeShadowOffset),
          ),
        ],
      ),
      child: AppText(
        title: "$jobCount",
        textType: TextType.subtitle,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  /// Builds the arrow icon
  Widget _buildArrowIcon(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(_arrowContainerSize),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(_arrowContainerSize),
      ),
      child: Icon(
        Icons.arrow_forward_ios_rounded,
        color: theme.colorScheme.primary,
        size: _arrowIconSize,
      ),
    );
  }
}
