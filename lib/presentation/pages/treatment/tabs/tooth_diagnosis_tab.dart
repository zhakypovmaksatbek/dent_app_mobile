import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/main.dart';
import 'package:dent_app_mobile/router/app_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:teeth_selector/teeth_selector.dart';

class ToothDiagnosisTab extends StatefulWidget {
  const ToothDiagnosisTab({super.key});

  @override
  State<ToothDiagnosisTab> createState() => _ToothDiagnosisTabState();
}

class _ToothDiagnosisTabState extends State<ToothDiagnosisTab> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 10),
          Center(
            child: TeethSelector(
              showPrimary: true,
              multiSelect: false,
              selectedColor: theme.colorScheme.primary,
              rightString: LocaleKeys.general_right.tr(),
              leftString: LocaleKeys.general_left.tr(),

              onChange: (selected) {
                if (selected.isNotEmpty) {
                  router.push(const TeethConditionActionRoute());
                  // showCupertinoModalBottomSheet(
                  //   context: context,
                  //   backgroundColor: Colors.transparent,
                  //   builder:
                  //       (context) => ToothDiagnosisModal(
                  //         selectedDiagnosis: null,
                  //         onDiagnosisSelected: (diagnosis) {
                  //           // Handle diagnosis selection
                  //           AppSnackBar.showSuccessSnackBar(
                  //             context,
                  //             'Diagnosis selected: ${diagnosis.title}',
                  //           );

                  //           router.maybePop();
                  //         },
                  //       ),
                  // );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
