import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/models/patient/patient_short_model.dart';
import 'package:dent_app_mobile/presentation/pages/calendar/bloc/search_patient/search_patient_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/calendar/widgets/custom_search_field.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PatientSearchField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final List<PatientShortModel> suggestions;
  final int? patientId;
  final bool enabled;
  final Function(PatientShortModel) onPatientSelected;
  final VoidCallback onPatientCleared;
  final VoidCallback onAddPatient;
  final bool showNoPatientResults;

  const PatientSearchField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.suggestions,
    required this.patientId,
    required this.enabled,
    required this.onPatientSelected,
    required this.onPatientCleared,
    required this.onAddPatient,
    required this.showNoPatientResults,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SearchPatientCubit, SearchPatientState>(
      listener: (context, state) {
        // Listener managed in the parent
      },
      builder: (context, state) {
        final suggestionItems =
            suggestions
                .map(
                  (patient) => CustomSearchItem<PatientShortModel>(
                    text: patient.fullName ?? '',
                    item: patient,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal: 16.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            patient.fullName ?? '',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          if (patient.dateOfBirthday != null)
                            Text(
                              DateFormat.yMd(
                                context.locale.languageCode,
                              ).format(DateTime.parse(patient.dateOfBirthday!)),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                )
                .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomSearchField<PatientShortModel>(
              controller: controller,
              focusNode: focusNode,
              hint: LocaleKeys.appointment_patient.tr(),
              suggestions: suggestionItems,
              enabled: enabled,
              onSearchTextChanged: (query) {
                if (query.length >= 2) {
                  context.read<SearchPatientCubit>().searchPatients(query);
                }
              },
              onSuggestionTap: (suggestion) {
                if (suggestion.item != null) {
                  onPatientSelected(suggestion.item!);
                }
              },
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.person),
                labelText: LocaleKeys.appointment_patient.tr(),
                border: const OutlineInputBorder(),
                enabled: enabled,
                suffixIcon:
                    patientId != null
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: onPatientCleared,
                        )
                        : state is SearchPatientLoading
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : null,
              ),
              validator: (value) {
                if (patientId == null) {
                  return LocaleKeys.errors_required_field.tr();
                }
                return null;
              },
              readOnly: patientId != null,
            ),
            if (state is SearchPatientError)
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 8),
                child: Text(
                  state.message,
                  style: TextStyle(color: Colors.red[700], fontSize: 12),
                ),
              ),
            if (showNoPatientResults)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        LocaleKeys.notifications_no_data_found.tr(),
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: onAddPatient,
                      icon: const Icon(Icons.add),
                      label: Text(LocaleKeys.buttons_add.tr()),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}
