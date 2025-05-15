import 'package:dent_app_mobile/models/diagnosis/tooth_model.dart';
import 'package:dent_app_mobile/presentation/pages/patient/core/bloc/patient_appointments/patient_appointments_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/patient/core/bloc/patient_tooth/patient_tooth_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/patient/widgets/page_title_widget.dart';
import 'package:dent_app_mobile/presentation/pages/patient/widgets/teeth_detail_dialog.dart';
import 'package:dent_app_mobile/presentation/pages/patient/widgets/teeth_selector_widget.dart';
import 'package:dent_app_mobile/presentation/theme/colors/color_constants.dart';
import 'package:dent_app_mobile/presentation/widgets/loading/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Page that displays the dental chart with teeth selection functionality
class TeethPage extends StatefulWidget {
  final int patientId;

  const TeethPage({super.key, required this.patientId});

  @override
  State<TeethPage> createState() => _TeethPageState();
}

class _TeethPageState extends State<TeethPage> {
  late PatientToothCubit _patientToothCubit;
  List<ToothModel> _teeth = [];

  @override
  void initState() {
    super.initState();
    _patientToothCubit = PatientToothCubit();
    _patientToothCubit.getToothList(widget.patientId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PatientToothCubit, PatientToothState>(
      bloc: _patientToothCubit,
      listener: (context, state) {
        if (state is PatientToothLoaded) {
          _teeth = state.teeth;
        }
      },
      builder: (context, state) {
        if (state is PatientAppointmentsLoading) {
          return const LoadingWidget();
        }

        return _buildPageContent();
      },
    );
  }

  /// Builds the main page content
  Widget _buildPageContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const PageTitleWidget(title: 'Стоматологическая карта'),
            const SizedBox(height: 20),
            TeethSelectorWidget(
              onTeethSelected: _handleTeethSelection,
              teethColorMap: _getTeethColorMap(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// Handles the selection of teeth in the selector
  void _handleTeethSelection(List<String> selected) {
    if (selected.isNotEmpty) {
      _showToothDetails(selected.last);
    }
  }

  /// Gets the color map for teeth based on diagnosis data
  Map<String, Color> _getTeethColorMap() {
    final map = <String, Color>{};

    for (final tooth in _teeth) {
      if (tooth.toothNumber != null &&
          tooth.main?.color != null &&
          tooth.main!.color!.isNotEmpty) {
        final String toothId = tooth.toothNumber.toString();
        map[toothId] = _hexToColor(tooth.main!.color!);
      }
    }

    return map;
  }

  /// Shows details dialog for the selected tooth
  void _showToothDetails(String toothId) {
    int? toothNumber;
    try {
      toothNumber = int.parse(toothId);
    } catch (e) {
      // Ignore parsing error
      return;
    }

    // Find information about the tooth
    final toothInfo = _teeth.firstWhere(
      (tooth) => tooth.toothNumber == toothNumber,
      orElse: () => ToothModel(toothNumber: toothNumber),
    );

    showDialog(
      context: context,
      builder:
          (context) =>
              TeethDetailDialog(toothId: toothId, toothInfo: toothInfo),
    );
  }

  /// Converts a hex string to Color
  Color _hexToColor(String hexString) {
    try {
      final String colorStr = hexString.replaceFirst('#', 'FF');
      return Color(int.parse(colorStr, radix: 16));
    } catch (e) {
      // Return default color on error
      return ColorConstants.primary;
    }
  }
}
