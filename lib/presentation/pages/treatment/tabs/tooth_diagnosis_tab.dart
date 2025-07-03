import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/main.dart';
import 'package:dent_app_mobile/presentation/pages/treatment/core/service/condition_service.dart';
import 'package:dent_app_mobile/presentation/pages/treatment/widgets/job_card.dart';
import 'package:dent_app_mobile/router/app_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
      body: Consumer<ConditionService>(
        builder: (context, conditionService, child) {
          return SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 10,
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
                        conditionService.setToothId(selected.first);
                        router.push(const TeethConditionActionRoute());
                      }
                    },
                  ),
                ),
                ListView.builder(
                  itemCount: conditionService.jobs.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return JobCard(
                      job: conditionService.jobs[index],
                      onDelete: () {},
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
