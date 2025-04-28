import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/models/diagnosis/diagnosis_model.dart';
import 'package:dent_app_mobile/presentation/widgets/text/app_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

// Callback to handle form submission. Passes the entered name.
typedef DiagnosisSubmitCallback = void Function(String name);

class DiagnosisFormModal extends StatefulWidget {
  final DiagnosisModel? initialDiagnosis; // For editing
  final DiagnosisSubmitCallback onSubmit;

  const DiagnosisFormModal({
    super.key,
    this.initialDiagnosis,
    required this.onSubmit,
  });

  @override
  State<DiagnosisFormModal> createState() => _DiagnosisFormModalState();
}

class _DiagnosisFormModalState extends State<DiagnosisFormModal> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  bool get _isEditing => widget.initialDiagnosis != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.initialDiagnosis?.name ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      widget.onSubmit(_nameController.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Adjust padding for keyboard overlap
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 16,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SingleChildScrollView(
          // Ensure content scrolls if needed
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Modal Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: AppText(
                          title:
                              _isEditing
                                  ? LocaleKeys.buttons_edit_diagnosis
                                      .tr() // ADD THIS LOCALE KEY
                                  : LocaleKeys.buttons_add_new_diagnosis
                                      .tr(), // ADD THIS LOCALE KEY
                          textType: TextType.title20,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                        tooltip:
                            MaterialLocalizations.of(
                              context,
                            ).closeButtonTooltip,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Diagnosis Name Field
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText:
                          LocaleKeys.general_diagnosis_name
                              .tr(), // ADD THIS LOCALE KEY
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.edit_note), // Example icon
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return LocaleKeys.validation_enter_diagnosis_name
                            .tr(); // ADD THIS LOCALE KEY
                      }
                      return null;
                    },
                    textCapitalization:
                        TextCapitalization
                            .sentences, // Optional: Capitalize sentences
                  ),
                  const SizedBox(height: 32),

                  // Submit Button
                  ElevatedButton(
                    onPressed: _submit,
                    child: Text(
                      _isEditing
                          ? LocaleKeys.buttons_save.tr()
                          : LocaleKeys.buttons_add.tr(),
                    ),
                  ),
                  const SizedBox(height: 10), // Bottom padding
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
