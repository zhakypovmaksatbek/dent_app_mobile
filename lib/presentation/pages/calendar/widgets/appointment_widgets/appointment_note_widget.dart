import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class AppointmentNoteWidget extends StatefulWidget {
  const AppointmentNoteWidget({
    super.key,
    required this.onNoteChanged,
    this.initialValue,
  });
  final ValueChanged<String> onNoteChanged;
  final String? initialValue;
  @override
  State<AppointmentNoteWidget> createState() => _AppointmentNoteWidgetState();
}

class _AppointmentNoteWidgetState extends State<AppointmentNoteWidget> {
  late final TextEditingController _noteController;
  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController();
    _noteController.text = widget.initialValue ?? '';
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: widget.onNoteChanged,
      controller: _noteController,
      minLines: 1,
      maxLines: 2,
      onTapOutside: (event) {
        FocusScope.of(context).unfocus();
      },
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        labelText: LocaleKeys.appointment_notes.tr(),
        prefixIcon: const Icon(Icons.note_alt_outlined),
      ),
    );
  }
}
