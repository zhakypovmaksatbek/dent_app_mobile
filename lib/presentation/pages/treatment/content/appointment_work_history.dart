import 'package:auto_route/annotations.dart';
import 'package:dent_app_mobile/main.dart';
import 'package:dent_app_mobile/models/work/appointment_work_model.dart';
import 'package:dent_app_mobile/presentation/pages/treatment/core/bloc/appointment_works/appointment_works_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/treatment/widgets/appointment_work_card.dart';
import 'package:flutter/material.dart';

@RoutePage(name: "AppointmentWorkHistoryRoute")
class AppointmentWorkHistory extends StatefulWidget {
  const AppointmentWorkHistory({
    super.key,
    required this.works,
    required this.appointmentId,
  });
  final List<AppointmentWorkModel> works;
  final int appointmentId;
  @override
  State<AppointmentWorkHistory> createState() => _AppointmentWorkHistoryState();
}

class _AppointmentWorkHistoryState extends State<AppointmentWorkHistory> {
  late final AppointmentWorksCubit appointmentWorkHistory;
  @override
  void initState() {
    super.initState();
    appointmentWorkHistory = getIt<AppointmentWorksCubit>();
  }

  @override
  void dispose() {
    appointmentWorkHistory.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView.builder(
        itemCount: widget.works.length,
        itemBuilder: (BuildContext context, int index) {
          final work = widget.works[index];
          return AppointmentWorkCard(work: work, onDelete: () {});
        },
      ),
    );
  }
}
