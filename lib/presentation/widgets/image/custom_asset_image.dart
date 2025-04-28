// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CustomAssetImage extends StatelessWidget {
  const CustomAssetImage({
    super.key,
    this.fit,
    this.borderRadius,
    this.height,
    this.width,
    required this.path,
    this.isSvg = false,
    this.svgColor,
  });
  final BoxFit? fit;
  final BorderRadiusGeometry? borderRadius;
  final double? height;
  final double? width;
  final String path;
  final bool? isSvg;
  final Color? svgColor;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(0),
        child: isSvg!
            ? SvgPicture.asset(path,
                colorFilter: svgColor != null
                    ? ColorFilter.mode(
                        theme.iconTheme.color!,
                        BlendMode.srcIn,
                      )
                    : null,
                fit: fit ?? BoxFit.contain,
                height: height,
                width: width)
            : Image.asset(
                path,
                fit: fit ?? BoxFit.contain,
                height: height,
                width: width,
              ));
  }
}
