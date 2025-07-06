import 'package:dent_app_mobile/core/utils/currency.dart';
import 'package:dent_app_mobile/presentation/widgets/text/app_text.dart';
import 'package:flutter/material.dart';

class PriceConvertWidget extends StatelessWidget {
  const PriceConvertWidget({
    super.key,
    required this.price,
    this.textType = TextType.description,
    this.color,
    this.fontWeight,
  });
  final TextType textType;
  final Color? color;
  final FontWeight? fontWeight;
  final double price;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: price.toCurrency(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return AppText(
            title: snapshot.data!,
            textType: textType,
            color: color,
            fontWeight: fontWeight,
          );
        }
        return AppText(
          title: '${price.toStringAsFixed(0)} ...',
          textType: textType,
          color: color,
          fontWeight: fontWeight,
        );
      },
    );
  }
}
