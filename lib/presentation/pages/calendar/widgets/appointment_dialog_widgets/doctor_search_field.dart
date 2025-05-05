import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/models/users/user_model.dart';
import 'package:dent_app_mobile/presentation/pages/calendar/widgets/custom_search_field.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/personal/core/bloc/personal/personal_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DoctorSearchField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final List<UserModel> suggestions;
  final int? doctorId;
  final Function(UserModel) onDoctorSelected;
  final VoidCallback onDoctorCleared;

  const DoctorSearchField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.suggestions,
    required this.doctorId,
    required this.onDoctorSelected,
    required this.onDoctorCleared,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PersonalCubit, PersonalState>(
      listener: (context, state) {
        // Listener managed in the parent
      },
      builder: (context, state) {
        final suggestionItems =
            suggestions
                .map(
                  (doctor) => CustomSearchItem<UserModel>(
                    text: doctor.fullName ?? '',
                    item: doctor,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal: 16.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doctor.fullName ?? '',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            doctor.email ?? '',
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
            CustomSearchField<UserModel>(
              controller: controller,
              focusNode: focusNode,
              hint: LocaleKeys.report_doctor.tr(),
              suggestions: suggestionItems,
              onSearchTextChanged: (query) {
                if (query.length >= 2) {
                  context.read<PersonalCubit>().getPersonalList(
                    1,
                    search: query,
                  );
                }
              },
              onSuggestionTap: (suggestion) {
                if (suggestion.item != null) {
                  onDoctorSelected(suggestion.item!);
                }
              },
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.medical_services),
                labelText: LocaleKeys.report_doctor.tr(),
                border: const OutlineInputBorder(),
                suffixIcon:
                    doctorId != null
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: onDoctorCleared,
                        )
                        : state is PersonalLoading
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : null,
              ),
              validator: (value) {
                if (doctorId == null) {
                  return LocaleKeys.errors_required_field.tr();
                }
                return null;
              },
              readOnly: doctorId != null,
            ),
            if (state is PersonalError)
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 8),
                child: Text(
                  state.message,
                  style: TextStyle(color: Colors.red[700], fontSize: 12),
                ),
              ),
          ],
        );
      },
    );
  }
}
