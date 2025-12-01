import 'package:dent_app_mobile/models/diagnosis/tooth_model.dart';
import 'package:dent_app_mobile/presentation/pages/patient/core/bloc/patient_appointments/patient_appointments_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/patient/core/bloc/patient_tooth/patient_tooth_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/patient/widgets/teeth_detail_dialog.dart';
import 'package:dent_app_mobile/presentation/pages/patient/widgets/teeth_selector_widget.dart';
import 'package:dent_app_mobile/presentation/pages/treatment/widgets/permanent_tab_widget.dart';
import 'package:dent_app_mobile/presentation/theme/colors/color_constants.dart';
import 'package:dent_app_mobile/presentation/widgets/loading/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Page that displays the dental chart with teeth selection functionality
class TeethInfoTab extends StatefulWidget {
  final int patientId;

  const TeethInfoTab({super.key, required this.patientId});

  @override
  State<TeethInfoTab> createState() => _TeethInfoTabState();
}

class _TeethInfoTabState extends State<TeethInfoTab> {
  late PatientToothCubit _patientToothCubit;
  List<ToothModel> _teeth = [];
  final ValueNotifier<bool> showPermanent = ValueNotifier<bool>(true);
  @override
  void initState() {
    super.initState();
    _patientToothCubit = PatientToothCubit();
    _patientToothCubit.getToothList(widget.patientId);
  }

  @override
  void dispose() {
    showPermanent.dispose();
    super.dispose();
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
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          spacing: 16,
          children: [
            PermanentTabWidget(showPermanent: showPermanent),
            ValueListenableBuilder(
              valueListenable: showPermanent,
              builder: (context, value, child) {
                return TeethSelectorWidget(
                  onTeethSelected: _handleTeethSelection,
                  teethColorMap: _getTeethColorMap(),
                  showPermanent: value,
                );
              },
            ),
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
      // Sadece diş numarasının olması yeterli.
      // Rengi var mı yok mu diye bakmadan, listedeyse boyuyoruz.
      if (tooth.toothNumber != null) {
        final String toothId = tooth.toothNumber.toString();

        // Listede olan her dişi kırmızı yap
        // (AppColors.red yoksa Colors.red kullanabilirsiniz)
        map[toothId] = AppColors.red;
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
      builder: (context) =>
          TeethDetailDialog(toothId: toothId, toothInfo: toothInfo),
    );
  }
}
