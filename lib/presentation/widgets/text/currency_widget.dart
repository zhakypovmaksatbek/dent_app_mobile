import 'package:dent_app_mobile/core/data/app_data_service.dart';
import 'package:dent_app_mobile/core/utils/currency.dart';
import 'package:flutter/material.dart';

class CurrencyWidget extends StatelessWidget {
  const CurrencyWidget({super.key, this.textStyle});
  final TextStyle? textStyle;
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Currency>(
      future: AppDataService.instance.getCurrency(),
      builder: (context, snapshot) {
        return Text(snapshot.data?.symbol ?? 'сом', style: textStyle);
      },
    );
  }
}
