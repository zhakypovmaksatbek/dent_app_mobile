import 'package:dent_app_mobile/core/utils/format_utils.dart';
import 'package:dent_app_mobile/presentation/pages/patient/core/util/patient_info_util.dart';
import 'package:flutter/material.dart';

class PhoneNumberText extends StatelessWidget {
  final String phoneNumber;
  final TextStyle? style;
  final TextAlign textAlign;
  final int? maxLines;
  final TextOverflow overflow;

  const PhoneNumberText({
    super.key,
    required this.phoneNumber,
    this.style,
    this.textAlign = TextAlign.start,
    this.maxLines,
    this.overflow = TextOverflow.clip,
  });

  @override
  Widget build(BuildContext context) {
    final formattedNumber = FormatUtils.formatPhoneNumber(phoneNumber);

    return FutureBuilder(
      future: PatientInfoUtil.getVisibilityPhoneNumber(),
      builder: (context, asyncSnapshot) {
        if (asyncSnapshot.hasData && asyncSnapshot.data == true) {
          return Text(
            formattedNumber,
            style: style,
            textAlign: textAlign,
            maxLines: maxLines,
            overflow: overflow,
          );
        } else {
          return Text(
            "**********",
            style: style,
            textAlign: textAlign,
            maxLines: maxLines,
            overflow: overflow,
          );
        }
      },
    );
  }
}
