// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dent_app_mobile/presentation/constants/asset_constants.dart';
import 'package:dent_app_mobile/presentation/theme/colors/color_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class CashedImages extends StatelessWidget {
  const CashedImages({
    super.key,
    required this.imageUrl,
    this.localImage,
    this.width,
    this.height,
    this.fit,
    this.imageRadius,
    this.borderRadius,
    this.isSvg = false,
    this.isUser = false,
  });
  final String imageUrl;
  final String? localImage;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final double? imageRadius;
  final BorderRadiusGeometry? borderRadius;
  final bool isSvg;
  final bool isUser;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(imageRadius ?? 10),
      child:
          imageUrl.isNotEmpty
              ? CachedNetworkImage(
                fit: fit ?? BoxFit.cover,
                errorListener: (value) {
                  print("----------Image-------------");
                  print(value.toString());
                },
                imageUrl: imageUrl,
                height: height,
                alignment: Alignment.center,
                memCacheHeight: 500,

                // memCacheWidth: 300,
                width: width,
                placeholder:
                    (context, url) => SizedBox(
                      width: width,
                      height: height,
                      child: Center(
                        child: LoadingAnimationWidget.flickr(
                          size: 40,
                          leftDotColor: ColorConstants.darkGrey,
                          rightDotColor: ColorConstants.primary,
                        ),
                      ),
                    ),
                filterQuality: FilterQuality.low,
                fadeOutDuration: const Duration(milliseconds: 300),
                fadeInDuration: const Duration(milliseconds: 300),
                errorWidget:
                    (context, url, error) =>
                        isSvg
                            ? SvgPicture.asset(
                              AssetConstants.toothLogo.svg,
                              width: width,
                              height: height,
                              fit: fit ?? BoxFit.cover,
                              alignment: Alignment.center,
                              colorFilter: ColorFilter.mode(
                                theme.iconTheme.color!,
                                BlendMode.srcIn,
                              ),
                            )
                            : Image.asset(
                              localImage ?? AssetConstants.toothLogo.png,
                              width: width,
                              alignment: Alignment.center,
                              height: height,
                              fit: fit ?? BoxFit.cover,
                            ),
              )
              : isSvg
              ? SvgPicture.asset(
                AssetConstants.toothLogo.svg,
                width: width,
                height: height,
                alignment: Alignment.center,
                fit: fit ?? BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  theme.iconTheme.color!,
                  BlendMode.srcIn,
                ),
              )
              : Image.asset(
                localImage ?? AssetConstants.toothLogo.png,
                width: width,
                height: height,
                fit: fit ?? BoxFit.cover,
                alignment: Alignment.center,
              ),
    );
  }
}

class CustomImageWidget extends StatelessWidget {
  const CustomImageWidget({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit,
  });
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit? fit;
  @override
  Widget build(BuildContext context) {
    return Image.network(
      imageUrl,
      fit: fit,
      height: height ?? 171,
      width: width ?? 151,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        } else {
          return SizedBox(
            height: height ?? 171,
            width: width ?? 151,
            child: const Center(child: CircularProgressIndicator.adaptive()),
          );
        }
      },
      errorBuilder:
          (context, error, stackTrace) => Image.asset(
            AssetConstants.toothLogo.png,
            height: height ?? 171,
            fit: BoxFit.cover,
            width: width ?? 151,
          ),
    );
  }
}
