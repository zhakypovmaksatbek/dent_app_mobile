import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/models/work/appointment_work_model.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/diagnosis/core/bloc/all_diagnosis/all_diagnosis_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DiagnosisSelectionSheet extends StatefulWidget {
  final List<DiagnosesResponse> initialSelected;
  final Function(List<DiagnosesResponse>) onSelectionChanged;

  const DiagnosisSelectionSheet({
    super.key,
    required this.initialSelected,
    required this.onSelectionChanged,
  });

  @override
  State<DiagnosisSelectionSheet> createState() =>
      _DiagnosisSelectionSheetState();
}

class _DiagnosisSelectionSheetState extends State<DiagnosisSelectionSheet> {
  late List<DiagnosesResponse> _selected;

  @override
  void initState() {
    super.initState();
    _selected = List.from(widget.initialSelected);
    // Cubit'i cagir
    context.read<AllDiagnosisCubit>().getDiagnosisList();
  }

  void _toggleDiagnosis(DiagnosesResponse diagnosis) {
    setState(() {
      if (_selected.any((e) => e.id == diagnosis.id)) {
        _selected.removeWhere((e) => e.id == diagnosis.id);
      } else {
        _selected.add(diagnosis);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.85,
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  LocaleKeys.forms_tooth_diagnosis.tr(),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton(
                  onPressed: () {
                    widget.onSelectionChanged(_selected);
                    Navigator.pop(context);
                  },
                  child: Text(LocaleKeys.buttons_save.tr()),
                ),
              ],
            ),
          ),

          // Search Bar (Istege bagli eklenebilir, Cubit filtrelemesi icin)
          Expanded(
            child: BlocBuilder<AllDiagnosisCubit, AllDiagnosisState>(
              builder: (context, state) {
                if (state is AllDiagnosisLoading)
                  return const Center(child: CircularProgressIndicator());
                if (state is AllDiagnosisError)
                  return Center(child: Text(state.message));
                if (state is AllDiagnosisLoaded) {
                  final list = state.diagnosisList;
                  return ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final item = list[index];
                      final responseItem = DiagnosesResponse(
                        id: item.id ?? 0,
                        name: item.name ?? '',
                      );

                      final isSelected = _selected.any(
                        (e) => e.id == responseItem.id,
                      );

                      return ListTile(
                        title: Text(item.name ?? ''),
                        trailing: isSelected
                            ? Icon(
                                Icons.check_circle,
                                color: Theme.of(context).colorScheme.primary,
                              )
                            : Icon(Icons.circle_outlined, color: Colors.grey),
                        onTap: () => _toggleDiagnosis(responseItem),
                      );
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
