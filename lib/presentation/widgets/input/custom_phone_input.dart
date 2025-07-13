import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class CustomPhoneInput extends StatelessWidget {
  const CustomPhoneInput({
    super.key,
    required this.focusNode,
    this.errorText,
    this.onChanged,
    this.decoration,
    this.initialValue,
  });

  final FocusNode focusNode;
  final String? errorText;
  final void Function(String)? onChanged;
  final InputDecoration? decoration;
  final String? initialValue;

  @override
  Widget build(BuildContext context) {
    print('CustomPhoneInput initialValue: $initialValue');
    return IntlPhoneField(
      focusNode: focusNode,
      initialValue: initialValue,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      showDropdownIcon: true,
      dropdownTextStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      dropdownDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      invalidNumberMessage: LocaleKeys.validation_invalid_phone_number.tr(),
      pickerDialogStyle: PickerDialogStyle(
        searchFieldInputDecoration: InputDecoration(
          hintText: LocaleKeys.buttons_search.tr(),
        ),
      ),
      decoration:
          decoration ??
          InputDecoration(hintText: '(xxx) xxx-xxx', errorText: errorText),
      dropdownIconPosition: IconPosition.trailing,
      showCountryFlag: false,
      languageCode: "ru",
      initialCountryCode: "KG",
      textInputAction: TextInputAction.next,
      onChanged: (phone) {
        onChanged?.call(phone.completeNumber);
        // debugPrint(phone.completeNumber);
      },
      onCountryChanged: (country) {
        // debugPrint('Country changed to: ${country.name}');
      },
    );
  }
}
