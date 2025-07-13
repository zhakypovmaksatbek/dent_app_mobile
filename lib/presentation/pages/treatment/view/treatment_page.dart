import 'package:auto_route/annotations.dart';
import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/models/appointment/calendar_appointment_model.dart';
import 'package:dent_app_mobile/presentation/pages/treatment/tabs/tooth_diagnosis_tab.dart';
import 'package:dent_app_mobile/presentation/pages/treatment/tabs/treatment_info_tab.dart';
import 'package:dent_app_mobile/presentation/pages/treatment/tabs/upload_x_ray_tab.dart';
import 'package:dent_app_mobile/presentation/theme/colors/color_constants.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

@RoutePage(name: 'TreatmentRoute')
class TreatmentPage extends StatefulWidget {
  final CalendarAppointmentModel? calendarAppointment;

  const TreatmentPage({super.key, this.calendarAppointment});
  @override
  State<TreatmentPage> createState() => _TreatmentPageState();
}

class _TreatmentPageState extends State<TreatmentPage>
    with TickerProviderStateMixin {
  late final TabController tabController;
  @override
  void initState() {
    tabController = TabController(length: 3, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.forms_treatment.tr()),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(40),
          child: TabBar(
            controller: tabController,
            dividerColor: Colors.transparent,
            padding: EdgeInsets.symmetric(horizontal: 16),
            indicatorSize: TabBarIndicatorSize.tab,
            splashBorderRadius: BorderRadius.circular(10),
            indicator: BoxDecoration(
              color: AppColors.primary.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(10),
            ),
            tabs: [
              Tab(text: LocaleKeys.forms_tooth.tr()),
              Tab(text: LocaleKeys.forms_treatment.tr()),
              Tab(text: LocaleKeys.forms_x_ray.tr()),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: [
          ToothDiagnosisTab(
            appointmentId: widget.calendarAppointment!.appointmentId!,
          ),
          TreatmentInfoTab(calendarAppointment: widget.calendarAppointment),
          UploadXRayTab(calendarAppointment: widget.calendarAppointment!),
        ],
      ),
    );
  }
}
