import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/models/appointment/appointment_comment_model.dart';
import 'package:dent_app_mobile/models/appointment/calendar_appointment_model.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/personal/core/bloc/appointment/appointment_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/personal/core/util/appointment_status.dart';
import 'package:dent_app_mobile/presentation/pages/treatment/core/bloc/pattern/pattern_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/treatment/core/data/pattern_type.dart';
import 'package:dent_app_mobile/presentation/pages/treatment/utils/pattern_utils.dart';
import 'package:dent_app_mobile/presentation/pages/treatment/utils/treatment_form_controller.dart';
import 'package:dent_app_mobile/presentation/pages/treatment/widgets/doctor_info_widget.dart';
import 'package:dent_app_mobile/presentation/pages/treatment/widgets/expandable_text_field_widget.dart';
import 'package:dent_app_mobile/presentation/pages/treatment/widgets/pattern_selection_bottom_sheet.dart';
import 'package:dent_app_mobile/presentation/pages/treatment/widgets/status_section_widget.dart';
import 'package:dent_app_mobile/presentation/pages/treatment/widgets/treatment_header_widget.dart';
import 'package:dent_app_mobile/presentation/widgets/buttons/def_elevated_button.dart';
import 'package:dent_app_mobile/presentation/widgets/snack_bars/app_snack_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ComplaintsTab extends StatefulWidget {
  const ComplaintsTab({super.key, this.calendarAppointment});
  final CalendarAppointmentModel? calendarAppointment;

  @override
  State<ComplaintsTab> createState() => _ComplaintsTabState();
}

class _ComplaintsTabState extends State<ComplaintsTab> {
  // Cubits
  late final AppointmentCubit _appointmentCubit;
  late final PatternCubit _patternCubit;

  // Controllers
  late final TreatmentFormController _formController;

  AppointmentStatus? _appointmentStatus;

  @override
  void initState() {
    super.initState();
    _initializeCubits();
    _initializeFormController();
    _initializeData();
  }

  void _initializeCubits() {
    _appointmentCubit = AppointmentCubit();
    _patternCubit = PatternCubit();
  }

  void _initializeFormController() {
    _formController = TreatmentFormController();
    _formController.setupTextControllerListeners(_onTextChanged);
    _formController.setupFocusNodeListeners(_onFocusChanged);
  }

  void _initializeData() {
    _appointmentStatus = AppointmentStatus.fromKey(
      widget.calendarAppointment?.appointmentStatus ?? '',
    );
  }

  void _onTextChanged(String searchText) {
    _searchPatterns(searchText);
  }

  void _onFocusChanged(PatternType patternType) {
    setState(() {
      // Update UI if needed
    });
    // Load initial patterns with empty search
    _searchPatterns('');
  }

  Future<void> _searchPatterns(String searchText) async {
    final activeType = _formController.activePatternType;
    if (activeType != null) {
      // Only search if the text has at least 2 characters or is empty (show all)
      if (searchText.isEmpty || searchText.length >= 2) {
        // Set loading state
        if (!_formController.isSearching) {
          _formController.setSearching(true);
          if (mounted) setState(() {});
        }

        try {
          await _patternCubit.getPatternList(
            activeType,
            search: searchText.isEmpty ? null : searchText,
          );
        } finally {
          // Reset loading state
          if (mounted) {
            _formController.setSearching(false);
            setState(() {});
          }
        }
      }
    }
  }

  void _showPatternSelectionDialog(PatternType patternType) {
    final title = PatternUtils.getTitleForPatternType(patternType);

    _formController.setActivePatternType(patternType, _onFocusChanged);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => PatternSelectionBottomSheet(
        patternType: patternType,
        title: title,
        patternCubit: _patternCubit,
        onPatternSelected: (pattern) {
          final controller = _getControllerForPatternType(patternType);
          _formController.insertPattern(controller, pattern);
        },
      ),
    );
  }

  TextEditingController _getControllerForPatternType(PatternType patternType) {
    switch (patternType) {
      case PatternType.complaints:
        return _formController.complaintsController;
      case PatternType.descriptionAndComments:
        return _formController.descriptionController;
      case PatternType.previousAndConcomitantDiseases:
        return _formController.historyController;
      case PatternType.xRayAndLaboratoryData:
        return _formController.labDataController;
      default:
        return _formController.descriptionController;
    }
  }

  void _saveAppointment() {
    _appointmentCubit.updateAppointmentComment(
      widget.calendarAppointment?.appointmentId ?? 0,
      AppointmentCommentModel(
        description: _formController.descriptionController.text,
        appointmentStatus: _appointmentStatus?.key.toUpperCase() ?? '',
        complaints: _formController.complaintsController.text,
        oldDiseases: _formController.historyController.text,
        xRayAndLaboratoryDescription: _formController.labDataController.text,
      ),
    );
  }

  @override
  void dispose() {
    _formController.dispose();
    _appointmentCubit.close();
    _patternCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _appointmentCubit,
      child: BlocProvider(
        create: (context) => _patternCubit,
        child: BlocListener<AppointmentCubit, AppointmentState>(
          listener: (context, state) {
            if (state is AppointmentCommentUpdated) {
              AppSnackBar.showSuccessSnackBar(context, state.message);
            }
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 24,
              children: [
                TreatmentHeaderWidget(
                  calendarAppointment: widget.calendarAppointment,
                ),
                DoctorInfoWidget(
                  calendarAppointment: widget.calendarAppointment,
                ),
                StatusSectionWidget(
                  appointmentStatus: _appointmentStatus,
                  onChanged: (value) => _appointmentStatus = value,
                ),
                _buildTextFields(),
                DefElevatedButton(
                  title: LocaleKeys.buttons_save.tr(),
                  onPressed: _saveAppointment,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFields() {
    return Column(
      spacing: 24,
      children: [
        ExpandableTextFieldWidget(
          key: const Key('complaints_text_field'),
          title: PatternUtils.getTitleForPatternType(PatternType.complaints),
          hintText: PatternUtils.getHintTextForPatternType(
            PatternType.complaints,
          ),
          controller: _formController.complaintsController,
          focusNode: _formController.complaintsFocusNode,
          patternType: PatternType.complaints,
          onPatternTap: () =>
              _showPatternSelectionDialog(PatternType.complaints),
        ),
        ExpandableTextFieldWidget(
          key: const Key('description_text_field'),
          title: PatternUtils.getTitleForPatternType(
            PatternType.descriptionAndComments,
          ),
          hintText: PatternUtils.getHintTextForPatternType(
            PatternType.descriptionAndComments,
          ),
          controller: _formController.descriptionController,
          focusNode: _formController.descriptionFocusNode,
          patternType: PatternType.descriptionAndComments,
          onPatternTap: () =>
              _showPatternSelectionDialog(PatternType.descriptionAndComments),
        ),
        ExpandableTextFieldWidget(
          key: const Key('history_text_field'),
          title: PatternUtils.getTitleForPatternType(
            PatternType.previousAndConcomitantDiseases,
          ),
          hintText: PatternUtils.getHintTextForPatternType(
            PatternType.previousAndConcomitantDiseases,
          ),
          controller: _formController.historyController,
          focusNode: _formController.historyFocusNode,
          patternType: PatternType.previousAndConcomitantDiseases,
          onPatternTap: () => _showPatternSelectionDialog(
            PatternType.previousAndConcomitantDiseases,
          ),
        ),
        ExpandableTextFieldWidget(
          key: const Key('lab_data_text_field'),
          title: PatternUtils.getTitleForPatternType(
            PatternType.xRayAndLaboratoryData,
          ),
          hintText: PatternUtils.getHintTextForPatternType(
            PatternType.xRayAndLaboratoryData,
          ),
          controller: _formController.labDataController,
          focusNode: _formController.labDataFocusNode,
          patternType: PatternType.xRayAndLaboratoryData,
          onPatternTap: () =>
              _showPatternSelectionDialog(PatternType.xRayAndLaboratoryData),
        ),
      ],
    );
  }
}
