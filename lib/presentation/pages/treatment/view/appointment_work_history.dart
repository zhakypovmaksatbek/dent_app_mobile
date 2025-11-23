import 'package:auto_route/annotations.dart';
import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/main.dart';
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
    required this.works,
    required this.appointmentId,
    required this.appointmentWorkHistory,
  });
  final List<AppointmentWorkModel> works;
  final int appointmentId;
  final AppointmentWorksCubit appointmentWorkHistory;
  @override
  State<AppointmentWorkHistory> createState() => _AppointmentWorkHistoryState();
}

class _AppointmentWorkHistoryState extends State<AppointmentWorkHistory> {
  late final ManageWorkCubit manageWorkCubit;
  List<AppointmentWorkModel> works = [];
  @override
  void initState() {
    super.initState();
    manageWorkCubit = getIt<ManageWorkCubit>();
    initWork();
  }

  void initWork() {
    if (widget.works.isNotEmpty) {
      works = widget.works;
    } else {
      widget.appointmentWorkHistory.loadAppointmentWork(widget.appointmentId);
    }
  }

  @override
  void dispose() {
    manageWorkCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: BlocListener<ManageWorkCubit, ManageWorkState>(
        bloc: manageWorkCubit,
        listener: (context, state) {
          state.maybeWhen(
            success: (message, isDeleted, workId) {
              if (isDeleted) {
                widget.appointmentWorkHistory.loadAppointmentWork(
                  widget.appointmentId,
                );
              }
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
        child: BlocBuilder<AppointmentWorksCubit, AppointmentWorksState>(
          bloc: widget.appointmentWorkHistory,
          builder: (context, state) {
            works = state.maybeWhen(
              orElse: () => widget.works,
              loaded: (works) => works,
            );
            if (works.isEmpty) {
              return Center(
                child: Text(LocaleKeys.notifications_no_works_found.tr()),
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
                              manageWorkCubit.deleteWork(work.workId);
                              Navigator.pop(context);
                            },
                            onCancel: () {
                              Navigator.pop(context);
                            },
                          );
                        },
                      );
                    },
                    onSave: (updatedWork) => manageWorkCubit.updateWork(
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
