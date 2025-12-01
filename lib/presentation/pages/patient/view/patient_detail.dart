import 'package:auto_route/auto_route.dart';
import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/models/appointment/appointment_detail_model.dart';
import 'package:dent_app_mobile/models/patient/patient_detail_model.dart';
import 'package:dent_app_mobile/models/patient/visit_model.dart';
import 'package:dent_app_mobile/presentation/pages/patient/core/bloc/patient_detail.dart/patient_detail_dart_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/patient/tabs/patient_info_details_tab.dart';
import 'package:dent_app_mobile/presentation/pages/patient/tabs/teeth_info_tab.dart';
import 'package:dent_app_mobile/presentation/pages/patient/tabs/x_ray_tab.dart';
import 'package:dent_app_mobile/presentation/pages/patient/widgets/appointment_comment_dialog.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/personal/core/util/appointment_status.dart';
import 'package:dent_app_mobile/presentation/theme/colors/color_constants.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage(name: 'PatientDetailRoute')
class PatientDetail extends StatefulWidget {
  const PatientDetail({super.key, required this.id});
  final int id;
  @override
  State<PatientDetail> createState() => _PatientDetailState();
}

class _PatientDetailState extends State<PatientDetail>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final PatientDetailCubit _patientDetailCubit;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _patientDetailCubit = PatientDetailCubit();
    _patientDetailCubit.getPatientDetail(widget.id);
  }

  final List<VisitModel> _visits = [];
  @override
  void dispose() {
    _tabController.dispose();
    _patientDetailCubit.close();
    super.dispose();
  }

  PatientDetailModel? _patientDetail;
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider(create: (context) => _patientDetailCubit)],
      child: BlocConsumer<PatientDetailCubit, PatientDetailState>(
        listener: (context, state) {
          if (state is PatientDetailLoaded) {
            _patientDetail = state.patientDetail;
          }
        },
        builder: (context, state) => Scaffold(
          appBar: AppBar(title: Text(LocaleKeys.patients_patients_info.tr())),
          body: Column(
            spacing: 8,
            children: [
              // Modern TabBar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: TabBar(
                  dividerColor: Colors.transparent,

                  // padding: EdgeInsets.symmetric(horizontal: 16),
                  indicatorSize: TabBarIndicatorSize.tab,
                  splashBorderRadius: BorderRadius.circular(10),
                  // isScrollable: true,
                  // tabAlignment: TabAlignment.start,
                  indicator: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: .1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  controller: _tabController,
                  tabs: [
                    Tab(
                      icon: Icon(Icons.person_outline),

                      child: Text(LocaleKeys.general_detail.tr()),
                    ),
                    Tab(
                      icon: Icon(Icons.tour_outlined),

                      child: Text(LocaleKeys.forms_tooth.tr()),
                    ),
                    Tab(
                      icon: Icon(Icons.image_outlined),

                      child: Text(LocaleKeys.general_x_ray.tr()),
                    ),
                  ],
                ),
              ),
              // TabBar Body
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return TabBarView(
      controller: _tabController,
      children: [
        PatientInfoDetailsTab(
          patientId: widget.id,
          appointment: AppointmentDetailModel(),
          onShowCommentDialog: _showCommentDialog,
          patientDetail: _patientDetail ?? PatientDetailModel(),
          visits: _visits,
        ),
        TeethInfoTab(patientId: widget.id),
        XRayTab(patientId: widget.id),
      ],
    );
  }

  // Show comment dialog
  void _showCommentDialog(
    BuildContext context,
    AppointmentDetailModel appointment,
  ) {
    final appointmentId = appointment.userResponse?.id;
    if (appointmentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot update: Missing appointment ID'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) => AppointmentCommentDialog(
        appointment: appointment,
        onSave: (comment, status, complaints, history, xRayDescription) {
          _updateAppointmentComment(
            appointmentId,
            comment,
            status,
            complaints: complaints,
            oldDiseases: history,
            xRayDescription: xRayDescription,
          );
        },
      ),
    );
  }

  // Add a method to update appointment comment
  void _updateAppointmentComment(
    int appointmentId,
    String comment,
    AppointmentStatus status, {
    String? complaints,
    String? oldDiseases,
    String? xRayDescription,
  }) {
    // _appointmentCubit.updateAppointmentComment(appointmentId, commentModel);
  }
}
