import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/models/appointment/doctor_model.dart';
import 'package:dent_app_mobile/presentation/pages/calendar/bloc/doctor/doctor_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/calendar/widgets/new_custom_search_field.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DoctorSelectionWidget extends StatefulWidget {
  final ScrollController? scrollController;
  final DoctorModel? initialValue;
  final Function(DoctorModel doctor) onDoctorSelected;
  final VoidCallback onSelectionCleared;
  final bool enabled;
  const DoctorSelectionWidget({
    super.key,
    this.scrollController,
    this.initialValue,
    required this.onDoctorSelected,
    required this.onSelectionCleared,
    this.enabled = true,
  });
  @override
  State<DoctorSelectionWidget> createState() => _DoctorSelectionWidgetState();
}

class _DoctorSelectionWidgetState extends State<DoctorSelectionWidget> {
  List<DoctorModel> _doctors = [];
  @override
  void initState() {
    super.initState();
    _fetchDoctors();
  }

  void _fetchDoctors() {
    context.read<DoctorCubit>().getDoctors();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DoctorCubit, DoctorState>(
      listener: (context, state) {
        if (state is DoctorLoaded) {
          _doctors = state.doctors;
        }
      },
      builder: (context, state) {
        return NewCustomSearchInput<DoctorModel>(
          prefixIconPath: "doctor",
          scrollController: widget.scrollController,
          resultBuilder:
              (item) => ListTile(
                title: Text(item.fullName ?? ''),
                subtitle:
                    item.specialities?.isNotEmpty == true
                        ? Text(item.specialities?.join(', ') ?? '')
                        : null,
              ),
          displayStringForItem: (item) => item.fullName ?? '',
          onSearch: (query) {
            return _searchUsers(query);
          },
          onItemSelected: (item) {
            widget.onDoctorSelected(item);
          },
          hintText: LocaleKeys.report_doctor.tr(),
          initialValue: widget.initialValue,
          enabled: widget.enabled,
          onSelectionCleared: widget.onSelectionCleared,
        );
      },
    );
  }

  Future<List<DoctorModel>> _searchUsers(String query) async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (query.isEmpty) {
      return _doctors;
    }
    final lowerCaseQuery = query.toLowerCase();
    return _doctors
        .where(
          (user) =>
              user.fullName?.toLowerCase().contains(lowerCaseQuery) ?? false,
        )
        .toList();
  }
}
