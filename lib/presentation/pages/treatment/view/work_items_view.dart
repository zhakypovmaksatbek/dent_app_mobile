import 'package:auto_route/annotations.dart';
import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/main.dart';
import 'package:dent_app_mobile/presentation/pages/patient/core/bloc/patient_tooth/patient_tooth_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/treatment/core/bloc/appointment_works/appointment_works_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/treatment/core/bloc/save_jobs/save_jobs_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/treatment/core/service/condition_service.dart';
import 'package:dent_app_mobile/presentation/pages/treatment/widgets/job_card.dart';
import 'package:dent_app_mobile/presentation/widgets/buttons/def_elevated_button.dart';
import 'package:dent_app_mobile/presentation/widgets/empty/empty_widget.dart';
import 'package:dent_app_mobile/presentation/widgets/loading/loading_widget.dart';
import 'package:dent_app_mobile/presentation/widgets/notification/app_bottom_sheet.dart';
import 'package:dent_app_mobile/presentation/widgets/notification/app_warning.dart';
import 'package:dent_app_mobile/presentation/widgets/text/app_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';

@RoutePage(name: "WorkItemsRoute")
class WorkItemsView extends StatelessWidget {
  const WorkItemsView({
    super.key,
    required this.appointmentId,
    required this.patientToothCubit,
    required this.patientId,
    required this.appointmentWorksCubit,
  });
  final int appointmentId;
  final int patientId;
  final PatientToothCubit patientToothCubit;
  final AppointmentWorksCubit appointmentWorksCubit;
  @override
  Widget build(BuildContext context) {
    return BlocListener<SaveJobsCubit, SaveJobsState>(
      listener: (context, state) {
        if (state is SaveJobsSuccess) {
          router.pop(true);
          context.read<ConditionService>().clearJobs();
          patientToothCubit.getToothList(patientId);
          appointmentWorksCubit.loadAppointmentWork(appointmentId);
        } else if (state is SaveJobsError) {
          AppWarning.showToastWarning(
            context,
            state.message,
            type: ToastificationType.error,
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: AppText(
            title: LocaleKeys.diagnosis_work_items.tr(),
            textType: TextType.title,
          ),
        ),
        bottomNavigationBar: Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).padding.bottom,
          ),
          child: BlocBuilder<SaveJobsCubit, SaveJobsState>(
            builder: (context, state) {
              if (state is SaveJobsLoading) {
                return SizedBox(
                  height: 40,
                  width: 40,
                  child: const LoadingWidget(),
                );
              }
              return DefElevatedButton(
                title: LocaleKeys.buttons_save.tr(),
                onPressed: () {
                  context.read<SaveJobsCubit>().saveJobs(
                    appointmentId,
                    context.read<ConditionService>().jobs,
                  );
                },
              );
            },
          ),
        ),
        body: Consumer<ConditionService>(
          builder: (context, workItemService, child) {
            final jobs = workItemService.jobs;
            if (jobs.isEmpty) {
              return EmptyWidget(
                icon: Icons.work_outline,
                title: LocaleKeys.diagnosis_no_work_items.tr(),
              );
            }
            return ListView.builder(
              itemCount: jobs.length,
              itemBuilder: (context, index) {
                final job = jobs[index];
                return JobCard(
                  conditionService: workItemService,
                  job: job,
                  onDelete: () {
                    AppBottomSheet.showBottomSheet(
                      context,
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          spacing: 12,
                          children: [
                            AppText(
                              title: LocaleKeys.buttons_delete.tr(),
                              textType: TextType.title,
                            ),
                            AppText(
                              title: LocaleKeys.alerts_delete_work_item.tr(
                                namedArgs: {
                                  "name": job.condition.name ?? "Не указано",
                                },
                              ),
                              textType: TextType.body,
                            ),
                            Row(
                              spacing: 12,
                              children: [
                                Expanded(
                                  child: DefElevatedButton(
                                    title: LocaleKeys.buttons_cancel.tr(),
                                    backgroundColor: Theme.of(
                                      context,
                                    ).hintColor,
                                    onPressed: () {
                                      router.maybePop();
                                    },
                                  ),
                                ),
                                Expanded(
                                  child: DefElevatedButton(
                                    title: LocaleKeys.buttons_delete.tr(),
                                    backgroundColor: Theme.of(
                                      context,
                                    ).colorScheme.error,
                                    onPressed: () {
                                      workItemService.removeJob(job);
                                      router.maybePop();
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
