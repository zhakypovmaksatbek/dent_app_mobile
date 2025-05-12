import 'package:dent_app_mobile/presentation/constants/asset_constants.dart';
import 'package:dent_app_mobile/presentation/theme/colors/color_constants.dart';
import 'package:dent_app_mobile/presentation/widgets/image/custom_asset_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PlaceholderTab extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color? iconColor;

  const PlaceholderTab({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            TeethAssetConstants.tooth18.svg,
            colorFilter: ColorFilter.mode(ColorConstants.red, BlendMode.srcIn),
            height: 80,
          ),
          CustomAssetImage(
            path: TeethAssetConstants.tooth18.svg,
            isSvg: true,
            svgColor: ColorConstants.lightGrey,
            height: 80,
          ),
          Icon(
            icon,
            size: 64,
            color:
                iconColor ??
                Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            description,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
