import 'package:dent_app_mobile/core/utils/format_utils.dart';
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

    return Text(
      formattedNumber,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
