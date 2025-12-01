import 'package:auto_route/annotations.dart';
import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/models/work/appointment_work_model.dart';
import 'package:dent_app_mobile/presentation/pages/treatment/core/bloc/appointment_works/appointment_works_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/treatment/core/bloc/manage_work/manage_work_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/treatment/widgets/appointment_work_card.dart';
import 'package:dent_app_mobile/presentation/widgets/notification/app_warning.dart';
import 'package:dent_app_mobile/presentation/widgets/notification/confirmation_bottom_sheet.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toastification/toastification.dart';

@RoutePage(name: "AppointmentWorkHistoryRoute")
class AppointmentWorkHistory extends StatefulWidget {
  const AppointmentWorkHistory({
    super.key,
    required this.appointmentId,
    required this.appointmentWorkHistory,
    required this.manageWorkCubit,
  });
  final int appointmentId;
  final AppointmentWorksCubit appointmentWorkHistory;
  final ManageWorkCubit manageWorkCubit;
  @override
  State<AppointmentWorkHistory> createState() => _AppointmentWorkHistoryState();
}

class _AppointmentWorkHistoryState extends State<AppointmentWorkHistory> {
  List<AppointmentWorkModel> works = [];
  @override
  void initState() {
    super.initState();

    initWork();
  }

  void initWork() {
    widget.appointmentWorkHistory.loadAppointmentWork(widget.appointmentId);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: BlocListener<ManageWorkCubit, ManageWorkState>(
        bloc: widget.manageWorkCubit,
        listener: (context, state) {
          state.maybeWhen(
            success: (message, isDeleted, workId) {
              // if (isDeleted) {
              widget.appointmentWorkHistory.loadAppointmentWork(
                widget.appointmentId,
              );
              // }
            },
            error: (message) {
              AppWarning.showToastWarning(
                context,
                message.message!,
                type: ToastificationType.error,
              );
            },
            orElse: () {},
          );
        },
        child: BlocConsumer<AppointmentWorksCubit, AppointmentWorksState>(
          bloc: widget.appointmentWorkHistory,
          listener: (context, state) {
            state.maybeWhen(
              orElse: () {},
              loaded: (works) {
                this.works = works;
              },
            );
          },
          builder: (context, state) {
            final bool isLoading = state.maybeWhen(
              loading: () => true,
              orElse: () => false,
            );
            if (isLoading && works.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (works.isEmpty) {
              return RefreshIndicator(
                onRefresh: () async {
                  widget.appointmentWorkHistory.loadAppointmentWork(
                    widget.appointmentId,
                  );
                },
                child: SingleChildScrollView(
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: Center(
                      child: Text(LocaleKeys.notifications_no_works_found.tr()),
                    ),
                  ),
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () async {
                widget.appointmentWorkHistory.loadAppointmentWork(
                  widget.appointmentId,
                );
              },
              child: ListView.builder(
                itemCount: works.length,
                itemBuilder: (BuildContext context, int index) {
                  final work = works[index];
                  return AppointmentWorkCard(
                    work: work,
                    onDelete: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return ConfirmationBottomSheet(
                            title: LocaleKeys.notifications_warning.tr(),
                            description: LocaleKeys
                                .notifications_confirm_delete_work
                                .tr(
                                  namedArgs: {
                                    "name":
                                        (work.toothResponse?.toothNumber
                                            .toString()) ??
                                        '-',
                                  },
                                ),
                            confirmButtonText: LocaleKeys.buttons_delete.tr(),
                            cancelButtonText: LocaleKeys.buttons_cancel.tr(),
                            onConfirm: () {
                              widget.manageWorkCubit.deleteWork(work.workId);
                              Navigator.pop(context);
                            },
                            onCancel: () {
                              Navigator.pop(context);
                            },
                          );
                        },
                      );
                    },
                    onSave: (updatedWork) => widget.manageWorkCubit.updateWork(
                      workId: work.workId,
                      workModel: updatedWork,
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
