import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/presentation/widgets/text/app_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class SelectDoctorMessage extends StatelessWidget {
  const SelectDoctorMessage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Icon(
            Icons.medical_services_outlined,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          AppText(
            title: LocaleKeys.appointment_select_doctor_first.tr(),
            textType: TextType.body,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
