import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
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
                showCupertinoModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return Material(
                      child: SizedBox(
                        height: 300,
                        child: Column(
                          children: [
                            Text('Tooth Diagnosis ${selected.length}'),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
