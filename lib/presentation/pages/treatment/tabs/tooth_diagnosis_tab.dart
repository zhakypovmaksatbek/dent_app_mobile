import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/main.dart';
import 'package:dent_app_mobile/presentation/pages/treatment/core/service/condition_service.dart';
import 'package:dent_app_mobile/presentation/widgets/text/app_text.dart';
import 'package:dent_app_mobile/router/app_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teeth_selector/teeth_selector.dart';

class ToothDiagnosisTab extends StatefulWidget {
  const ToothDiagnosisTab({super.key, required this.appointmentId});
  final int appointmentId;
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
                if (conditionService.jobs.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Material(
                      elevation: 4,
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.white,
                      shadowColor: theme.colorScheme.primary.withValues(
                        alpha: 0.1,
                      ),
                      child: InkWell(
                        onTap: () {
                          router.push(
                            WorkItemsRoute(appointmentId: widget.appointmentId),
                          );
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              colors: [
                                theme.colorScheme.primary.withValues(
                                  alpha: 0.05,
                                ),
                                theme.colorScheme.secondary.withValues(
                                  alpha: 0.08,
                                ),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              children: [
                                // Sol taraf - İkon ve metin
                                Expanded(
                                  child: Row(
                                    children: [
                                      // İkon container
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.primary,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: theme.colorScheme.primary
                                                  .withValues(alpha: 0.3),
                                              blurRadius: 8,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          Icons.work_outline,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      // Metin kısmı
                                      Expanded(
                                        child: AppText(
                                          title:
                                              LocaleKeys.general_work_items
                                                  .tr(),
                                          textType: TextType.header,
                                          color: theme.colorScheme.onSurface,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Sağ taraf - Sayı rozeti ve ok
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Sayı rozeti
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.secondary,
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: theme.colorScheme.secondary
                                                .withValues(alpha: 0.3),
                                            blurRadius: 6,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: AppText(
                                        title:
                                            "${conditionService.jobs.length}",
                                        textType: TextType.subtitle,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    // Ok ikonu
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.surface,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        color: theme.colorScheme.primary,
                                        size: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
