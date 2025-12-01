import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/presentation/theme/colors/color_constants.dart';
import 'package:dent_app_mobile/presentation/theme/extension/card_style_extension.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class PermanentTabWidget extends StatelessWidget {
  const PermanentTabWidget({super.key, required this.showPermanent});

  final ValueNotifier<bool> showPermanent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardStyle = theme.extension<CardStyleExtension>();
    final decoration =
        cardStyle?.customCardDecoration ??
        CardStyleExtension.defaultCardDecoration;
    return ValueListenableBuilder<bool>(
      valueListenable: showPermanent,
      builder: (context, isPermanent, child) {
        return Container(
          height: 45,
          padding: const EdgeInsets.all(4),
          decoration: decoration.copyWith(color: AppColors.background),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => showPermanent.value = true,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isPermanent ? Colors.white : null,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      LocaleKeys.general_adult.tr(),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isPermanent
                            ? Colors.black
                            : Colors.grey.shade600,
                      ),
                    ),
                  ),
                ),
              ),

              Expanded(
                child: GestureDetector(
                  onTap: () => showPermanent.value = false,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: !isPermanent ? Colors.white : null,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      LocaleKeys.general_pediatric.tr(),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: !isPermanent
                            ? Colors.black
                            : Colors.grey.shade600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
