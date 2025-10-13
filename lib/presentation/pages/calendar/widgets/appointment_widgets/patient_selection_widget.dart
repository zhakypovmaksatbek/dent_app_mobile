import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/models/patient/patient_data_model.dart';
import 'package:dent_app_mobile/models/patient/patient_short_model.dart';
import 'package:dent_app_mobile/presentation/pages/calendar/bloc/search_patient/search_patient_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/calendar/widgets/new_custom_search_field.dart';
import 'package:dent_app_mobile/presentation/pages/patient/view/create_patient.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class PatientSelectionWidget extends StatefulWidget {
  const PatientSelectionWidget({
    super.key,
    required this.onPatientSelected,
    required this.onSelectionCleared,
    required this.scrollController,
    this.initialValue,
    this.enabled = true,
  });
  final Function(PatientShortModel) onPatientSelected;
  final Function() onSelectionCleared;
  final ScrollController scrollController;
  final PatientShortModel? initialValue;
  final bool enabled;
  @override
  State<PatientSelectionWidget> createState() => _PatientSelectionWidgetState();
}

class _PatientSelectionWidgetState extends State<PatientSelectionWidget> {
  String? _pendingSearchAndSelect;
  final GlobalKey<NewCustomSearchInputState<PatientShortModel>>
  _searchInputKey = GlobalKey<NewCustomSearchInputState<PatientShortModel>>();

  void _onAddPatient(BuildContext context, String patientName) async {
    // Önce overlay'i kapat
    _searchInputKey.currentState?.deactivate();

    // Focus'u kaldır
    FocusScope.of(context).unfocus();

    // Overlay'in kapanması için kısa bir bekleme
    await Future.delayed(const Duration(milliseconds: 100));

    final result = await showCupertinoModalBottomSheet<PatientModel>(
      context: context,
      builder:
          (context) =>
              CreatePatientPage(isEdit: false, patientName: patientName),
    );

    if (result != null && context.mounted) {
      final patientShortModel = PatientShortModel(
        dateOfBirthday: result.birthDate,
        fullName: result.fullName,
        id: result.id,
      );

      context.read<SearchPatientCubit>().addNewPatient(patientShortModel);
      widget.onPatientSelected(patientShortModel);

      _searchInputKey.currentState?.selectItemProgrammatically(
        patientShortModel,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _searchUsers('');
  }

  Future<List<PatientShortModel>> _searchUsers(String query) async {
    final List<PatientShortModel> results = await context
        .read<SearchPatientCubit>()
        .searchPatients(query);
    return results;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SearchPatientCubit, SearchPatientState>(
      listener: (context, state) {
        if (state is SearchPatientLoaded && _pendingSearchAndSelect != null) {
          if (state.patients.isNotEmpty) {
            final newPatient = state.patients.first;

            widget.onPatientSelected(newPatient);
          }

          setState(() {
            _pendingSearchAndSelect = null;
          });
        }
      },
      child: NewCustomSearchInput<PatientShortModel>(
        key: _searchInputKey,
        onSearch: _searchUsers,
        debounceDuration: const Duration(milliseconds: 500),
        resultBuilder: (item) => ListTile(title: Text(item.fullName ?? '')),
        onItemSelected: widget.onPatientSelected,
        displayStringForItem: (item) => item.fullName ?? '',
        hintText: LocaleKeys.patients_search_patient.tr(),
        onSelectionCleared: widget.onSelectionCleared,
        scrollController: widget.scrollController,
        initialValue: widget.initialValue,
        prefixIconPath: 'user',
        enabled: widget.enabled,
        noResultsFoundBuilder:
            (query) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(LocaleKeys.notifications_no_search_results_found.tr()),
                TextButton(
                  onPressed: () => _onAddPatient(context, query),
                  child: Text(LocaleKeys.patients_add_patient.tr()),
                ),
              ],
            ),
      ),
    );
  }
}
