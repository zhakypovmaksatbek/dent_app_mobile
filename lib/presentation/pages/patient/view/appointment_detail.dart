import 'package:auto_route/auto_route.dart';
import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/models/appointment/appointment_comment_model.dart';
import 'package:dent_app_mobile/models/appointment/appointment_model.dart';
import 'package:dent_app_mobile/presentation/pages/patient/widgets/appointment_comment_dialog.dart';
import 'package:dent_app_mobile/presentation/pages/patient/widgets/appointment_details_tab.dart';
import 'package:dent_app_mobile/presentation/pages/patient/widgets/delete_appointment_dialog.dart';
import 'package:dent_app_mobile/presentation/pages/patient/widgets/placeholder_tab.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/personal/core/bloc/appointment/appointment_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/personal/core/util/appointment_status.dart';
import 'package:dent_app_mobile/presentation/widgets/loading/loading_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Constant values
const double A40 = 40.0;

@RoutePage(name: 'AppointmentDetailRoute')
class AppointmentDetail extends StatefulWidget {
  const AppointmentDetail({super.key, required this.id});
  final int id;
  @override
  State<AppointmentDetail> createState() => _AppointmentDetailState();
}

class _AppointmentDetailState extends State<AppointmentDetail>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final AppointmentCubit _appointmentCubit;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _appointmentCubit = AppointmentCubit();
    _loadAppointment();
  }

  void _loadAppointment() {
    _appointmentCubit.getAppointmentById(widget.id);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _appointmentCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _appointmentCubit,
      child: BlocConsumer<AppointmentCubit, AppointmentState>(
        listener: (context, state) {
          if (state is AppointmentDeleted) {
            // Navigate back if appointment is deleted
            context.router.pop();
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: Text(LocaleKeys.routes_appointment_detail.tr()),
              actions: [
                if (state is AppointmentLoaded)
                  IconButton(
                    icon: const Icon(Icons.edit),
                    tooltip: 'Edit Appointment',
                    onPressed:
                        () => _editAppointment(context, state.appointment),
                  ),
                if (state is AppointmentLoaded)
                  IconButton(
                    icon: const Icon(Icons.delete),
                    tooltip: 'Delete Appointment',
                    onPressed:
                        () => _confirmDeleteAppointment(
                          context,
                          state.appointment,
                        ),
                  ),
              ],
              bottom: TabBar(
                controller: _tabController,
                tabs: [
                  Tab(icon: const Icon(Icons.info_outline), text: 'Details'),
                  Tab(icon: const Icon(Icons.tour), text: 'Teeth'),
                  Tab(icon: const Icon(Icons.image), text: 'X-Rays'),
                ],
              ),
            ),
            body: _buildBody(state),
          );
        },
      ),
    );
  }

  Widget _buildBody(AppointmentState state) {
    if (state is AppointmentLoading) {
      return const Center(child: LoadingWidget());
    } else if (state is AppointmentError) {
      return _buildErrorView(state.message);
    } else if (state is AppointmentLoaded) {
      return TabBarView(
        controller: _tabController,
        children: [
          AppointmentDetailsTab(
            appointment: state.appointment,
            onShowCommentDialog: _showCommentDialog,
          ),
          PlaceholderTab(
            icon: Icons.tour,
            title: 'Teeth diagram coming soon',
            description:
                'This section will display an interactive teeth diagram\nshowing the condition of each tooth',
          ),
          PlaceholderTab(
            icon: Icons.image,
            title: 'X-Ray images coming soon',
            description:
                'This section will display X-Ray images\nand other dental imagery',
          ),
        ],
      );
    }
    return const SizedBox.shrink();
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
            onPressed: _loadAppointment,
            icon: const Icon(Icons.refresh),
            label: Text(LocaleKeys.buttons_retry.tr()),
          ),
        ],
      ),
    );
  }

  // Edit appointment function - You will implement this when you create an edit screen
  void _editAppointment(BuildContext context, AppointmentModel appointment) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Edit appointment functionality coming soon'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _confirmDeleteAppointment(
    BuildContext context,
    AppointmentModel appointment,
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
    _appointmentCubit.deleteAppointment(id);
  }

  // Show comment dialog
  void _showCommentDialog(BuildContext context, AppointmentModel appointment) {
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
    _appointmentCubit.updateAppointmentComment(appointmentId, commentModel);
  }
}
