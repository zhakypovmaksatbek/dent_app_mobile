import 'package:auto_route/auto_route.dart';
import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/models/appointment/appointment_comment_model.dart';
import 'package:dent_app_mobile/models/appointment/appointment_detail_model.dart';
import 'package:dent_app_mobile/models/patient/patient_detail_model.dart';
import 'package:dent_app_mobile/models/patient/visit_model.dart';
import 'package:dent_app_mobile/presentation/pages/patient/content/patient_info_details_tab.dart';
import 'package:dent_app_mobile/presentation/pages/patient/content/teeth_page.dart';
import 'package:dent_app_mobile/presentation/pages/patient/core/bloc/patient_detail.dart/patient_detail_dart_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/patient/widgets/appointment_comment_dialog.dart';
import 'package:dent_app_mobile/presentation/pages/patient/widgets/delete_appointment_dialog.dart';
import 'package:dent_app_mobile/presentation/pages/patient/widgets/placeholder_tab.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/personal/core/util/appointment_status.dart';
import 'package:dent_app_mobile/presentation/widgets/tabs/modern_tab_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Constant values
const double A40 = 40.0;

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
        builder:
            (context, state) => Scaffold(
              appBar: AppBar(
                title: Text(LocaleKeys.routes_appointment_detail.tr()),
                backgroundColor: Colors.transparent,
                elevation: 0,
                scrolledUnderElevation: 0,
              ),
              body: Column(
                children: [
                  // Modern TabBar
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(
                            context,
                          ).colorScheme.shadow.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ModernTabBar(
                      controller: _tabController,
                      tabs: [
                        ModernTab(
                          icon: Icons.person_outline,
                          activeIcon: Icons.person,
                          label: 'Details',
                        ),
                        ModernTab(
                          icon: Icons.tour_outlined,
                          activeIcon: Icons.tour,
                          label: 'Teeth',
                        ),
                        ModernTab(
                          icon: Icons.image_outlined,
                          activeIcon: Icons.image,
                          label: 'X-Rays',
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
        TeethPage(patientId: widget.id),
        PlaceholderTab(
          icon: Icons.image,
          title: 'X-Ray images coming soon',
          description:
              'This section will display X-Ray images\nand other dental imagery',
        ),
      ],
    );
  }

  Widget _buildErrorView(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: A40,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.refresh),
            label: Text(LocaleKeys.buttons_retry.tr()),
          ),
        ],
      ),
    );
  }

  // Edit appointment function - You will implement this when you create an edit screen
  void _editAppointment(
    BuildContext context,
    AppointmentDetailModel appointment,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Edit appointment functionality coming soon'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _confirmDeleteAppointment(
    BuildContext context,
    AppointmentDetailModel appointment,
  ) {
    final appointmentId = appointment.userResponse?.id;

    if (appointmentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot delete: Missing appointment ID'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder:
          (dialogContext) => DeleteAppointmentDialog(
            appointment: appointment,
            onConfirm: () => _deleteAppointment(appointmentId),
          ),
    );
  }

  // Delete appointment
  void _deleteAppointment(int id) {
    // _appointmentCubit.deleteAppointment(id);
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
      builder:
          (dialogContext) => AppointmentCommentDialog(
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
    final commentModel = AppointmentCommentModel(
      appointmentStatus: status.key.toUpperCase(),
      description: comment,
      complaints: complaints,
      oldDiseases: oldDiseases,
      xRayAndLaboratoryDescription: xRayDescription,
    );
    // _appointmentCubit.updateAppointmentComment(appointmentId, commentModel);
  }
}
