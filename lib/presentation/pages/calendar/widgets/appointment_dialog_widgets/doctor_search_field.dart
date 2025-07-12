import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/models/appointment/doctor_model.dart';
import 'package:dent_app_mobile/presentation/pages/calendar/bloc/doctor/doctor_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/calendar/widgets/custom_search_field.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DoctorSearchField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final int? doctorId;
  final Function(DoctorModel) onDoctorSelected;
  final VoidCallback onDoctorCleared;

  const DoctorSearchField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.doctorId,
    required this.onDoctorSelected,
    required this.onDoctorCleared,
  });

  @override
  State<DoctorSearchField> createState() => _DoctorSearchFieldState();
}

class _DoctorSearchFieldState extends State<DoctorSearchField> {
  List<DoctorModel> _allDoctors = [];
  List<DoctorModel> _filteredDoctors = [];

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onSearchChanged);
    super.dispose();
  }

  void _onSearchChanged() {
    final query = widget.controller.text.toLowerCase();
    if (query.isEmpty) {
      setState(() {
        _filteredDoctors = _allDoctors;
      });
    } else {
      setState(() {
        _filteredDoctors =
            _allDoctors.where((doctor) {
              final fullName = doctor.fullName?.toLowerCase() ?? '';
              return fullName.contains(query);
            }).toList();
      });
    }
  }

  void _updateDoctorsList(List<DoctorModel> doctors) {
    final activeDoctors =
        doctors.where((doctor) => doctor.table == true).toList();
    setState(() {
      _allDoctors = activeDoctors;
      _filteredDoctors = activeDoctors;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DoctorCubit, DoctorState>(
      listener: (context, state) {
        if (state is DoctorLoaded) {
          _updateDoctorsList(state.doctors);
        }
      },
      builder: (context, state) {
        final suggestionItems =
            _filteredDoctors
                .map(
                  (doctor) => CustomSearchItem<DoctorModel>(
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
                          if (doctor.specialities != null &&
                              doctor.specialities!.isNotEmpty)
                            Text(
                              doctor.specialities!.join(', '),
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
            CustomSearchField<DoctorModel>(
              controller: widget.controller,
              focusNode: widget.focusNode,
              hint: LocaleKeys.report_doctor.tr(),
              suggestions: suggestionItems,
              onSearchTextChanged: (_) {
                // Search is handled locally in _onSearchChanged
              },
              onSuggestionTap: (suggestion) {
                if (suggestion.item != null) {
                  widget.onDoctorSelected(suggestion.item!);
                }
              },
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.medical_services),
                labelText: "* ${LocaleKeys.report_doctor.tr()}",
                border: const OutlineInputBorder(),
                suffixIcon:
                    widget.doctorId != null
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: widget.onDoctorCleared,
                        )
                        : state is DoctorLoading
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : null,
              ),
              validator: (value) {
                if (widget.doctorId == null) {
                  return LocaleKeys.errors_required_field.tr();
                }
                return null;
              },
              readOnly: widget.doctorId != null,
            ),
            if (state is DoctorError)
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
