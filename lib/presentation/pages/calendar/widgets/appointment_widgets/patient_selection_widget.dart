import 'package:dent_app_mobile/generated/locale_keys.g.dart';
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
  });
  final Function(PatientShortModel) onPatientSelected;
  final Function() onSelectionCleared;
  final ScrollController scrollController;
  @override
  State<PatientSelectionWidget> createState() => _PatientSelectionWidgetState();
}

class _PatientSelectionWidgetState extends State<PatientSelectionWidget> {
  String? _pendingSearchAndSelect;

  void _onAddPatient(BuildContext context, String patientName) async {
    final searchCubit = context.read<SearchPatientCubit>();

    final result = await showCupertinoModalBottomSheet<String>(
      context: context,
      builder:
          (context) =>
              CreatePatientPage(isEdit: false, patientName: patientName),
    );

    if (result != null && mounted) {
      setState(() {
        _pendingSearchAndSelect = result;
      });

      searchCubit.searchPatients(result);
    }
  }

  @override
  void initState() {
    super.initState();
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
        onSearch: _searchUsers,
        debounceDuration: const Duration(milliseconds: 500),
        resultBuilder: (item) => ListTile(title: Text(item.fullName ?? '')),
        onItemSelected: widget.onPatientSelected,
        displayStringForItem: (item) => item.fullName ?? '',
        hintText: LocaleKeys.patients_search_patient.tr(),
        onSelectionCleared: widget.onSelectionCleared,
        scrollController: widget.scrollController,
        prefixIconPath: 'user',
        noResultsFoundBuilder:
            (query) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Sonuç bulunamadı: $query'),
                TextButton(
                  onPressed: () => _onAddPatient(context, query),
                  child: Text('Yeni hasta ekle'),
                ),
              ],
            ),
      ),
    );
  }
}
