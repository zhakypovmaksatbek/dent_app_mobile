import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/main.dart';
import 'package:dent_app_mobile/models/patient/patient_create_model.dart';
import 'package:dent_app_mobile/models/patient/patient_data_model.dart';
import 'package:dent_app_mobile/presentation/pages/patient/core/bloc/create_patient/create_patient_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/patient/core/bloc/patient_bloc/patient_bloc.dart';
import 'package:dent_app_mobile/presentation/pages/patient/core/util/upper_case_first_letter_formatter.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/personal/core/util/gender.dart';
import 'package:dent_app_mobile/presentation/widgets/buttons/def_elevated_button.dart';
import 'package:dent_app_mobile/presentation/widgets/input/custom_phone_input.dart';
import 'package:dent_app_mobile/presentation/widgets/input/form_text_field.dart';
import 'package:dent_app_mobile/presentation/widgets/loading/loading_widget.dart';
import 'package:dent_app_mobile/presentation/widgets/text/app_text.dart';
import 'package:dent_app_mobile/router/app_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreatePatientPage extends StatefulWidget {
  const CreatePatientPage({
    super.key,
    this.isEdit = false,
    this.patient,
    this.patientName,
  });
  final bool isEdit;
  final PatientModel? patient;
  final String? patientName;
  @override
  State<CreatePatientPage> createState() => _CreatePatientPageState();
}

class _CreatePatientPageState extends State<CreatePatientPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _secondaryPhoneController =
      TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passportNumberController =
      TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _patronymicController = TextEditingController();

  late final CreatePatientCubit _createPatientCubit;
  String? _birthday;
  bool _showAdditionalFields = false;
  Gender _selectedGender = Gender.male;
  FromWhere _selectedFromWhere = FromWhere.other;

  @override
  void initState() {
    super.initState();
    _createPatientCubit = CreatePatientCubit();

    // Handle patientName parameter regardless of isEdit
    if (widget.patientName != null) {
      final nameParts = widget.patientName!.split(' ');
      if (nameParts.length >= 2) {
        _nameController.text = nameParts[0];
        _surnameController.text = nameParts[1];
      } else {
        _nameController.text = widget.patientName!;
        _surnameController.text = '';
      }
    }

    // Handle edit mode
    if (widget.isEdit && widget.patient != null) {
      if (widget.patient?.fullName != null) {
        final nameParts = widget.patient!.fullName!.split(' ');
        if (nameParts.length >= 2) {
          _nameController.text = nameParts[0];
          _surnameController.text = nameParts[1];
        } else {
          _nameController.text = widget.patient!.fullName ?? '';
          _surnameController.text = '';
        }
      }
      _phoneController.text = widget.patient!.phoneNumber ?? "";
      _emailController.text = widget.patient!.email ?? "";
      _birthday = widget.patient!.birthDate ?? "";
      _showAdditionalFields = true; // Show all fields in edit mode
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _secondaryPhoneController.dispose();
    _emailController.dispose();
    _passportNumberController.dispose();
    _surnameController.dispose();
    _patronymicController.dispose();
    super.dispose();
  }

  bool _validate() {
    return _formKey.currentState!.validate();
  }

  final FocusNode _phoneFocusNode = FocusNode();
  final FocusNode _secondaryPhoneFocusNode = FocusNode();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final router = getIt<AppRouter>();

  Widget _buildRequiredFields() {
    return Column(
      spacing: 12,
      children: [
        FormTextField(
          hintText: LocaleKeys.forms_name.tr(),
          controller: _nameController,

          validator: (value) {
            if (value == null || value.isEmpty) {
              return LocaleKeys.errors_required_field.tr();
            }
            return null;
          },
          inputFormatters: [UpperCaseFirstLetterFormatter()],
          keyboardType: TextInputType.name,
          textInputAction: TextInputAction.next,
        ),
        FormTextField(
          hintText: LocaleKeys.forms_surname.tr(),
          controller: _surnameController,
          inputFormatters: [UpperCaseFirstLetterFormatter()],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return LocaleKeys.errors_required_field.tr();
            }
            return null;
          },
          keyboardType: TextInputType.name,
          textInputAction: TextInputAction.next,
        ),
        CustomPhoneInput(
          focusNode: _phoneFocusNode,
          onChanged: (value) {
            setState(() {
              _phoneController.text = value.replaceAll(' ', '');
            });
          },
          decoration: InputDecoration(
            hintText: LocaleKeys.forms_phone.tr(),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),

        GestureDetector(
          onTap: () => _showGenderPicker(context),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.outline.withValues(alpha: 0.5),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                AppText(
                  title: LocaleKeys.forms_gender.tr(),
                  textType: TextType.subtitle,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppText(
                      title: _selectedGender.displayName.tr(),
                      textType: TextType.body,
                    ),
                    Icon(
                      Icons.arrow_drop_down,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAdditionalFields() {
    return Column(
      spacing: 12,
      children: [
        FormTextField(
          hintText: LocaleKeys.forms_patronymic.tr(),
          controller: _patronymicController,
          keyboardType: TextInputType.name,
          textInputAction: TextInputAction.next,
          inputFormatters: [UpperCaseFirstLetterFormatter()],
        ),

        CustomPhoneInput(
          focusNode: _secondaryPhoneFocusNode,
          onChanged: (value) {
            setState(() {
              _secondaryPhoneController.text = value.replaceAll(' ', '');
            });
          },
          decoration: InputDecoration(
            hintText: LocaleKeys.forms_phone.tr(),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        FormTextField(
          hintText: LocaleKeys.forms_email.tr(),
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
        ),
        BirthdayPickerField(
          initialValue: _birthday,
          onChanged: (newDate) {
            _birthday = newDate;
          },
        ),
        FormTextField(
          hintText: LocaleKeys.forms_passport_number.tr(),
          controller: _passportNumberController,
        ),
        GestureDetector(
          onTap: () => _showFromWherePicker(context),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.outline.withValues(alpha: 0.5),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                AppText(
                  title: LocaleKeys.forms_from_where.tr(),
                  textType: TextType.subtitle,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppText(
                      title: _selectedFromWhere.title.tr(),
                      textType: TextType.body,
                    ),
                    Icon(
                      Icons.arrow_drop_down,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showGenderPicker(BuildContext context) async {
    // Close keyboard first
    FocusScope.of(context).unfocus();

    final selectedGender = await showModalBottomSheet<Gender>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 4,
                width: 40,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      title: LocaleKeys.forms_gender.tr(),
                      textType: TextType.subtitle,
                    ),
                    const SizedBox(height: 16),
                    ...Gender.values.map(
                      (gender) => ListTile(
                        title: Text(gender.displayName.tr()),
                        leading: Radio<Gender>(
                          value: gender,
                          groupValue: _selectedGender,
                          onChanged: (value) {
                            if (value != null) {
                              Navigator.of(context).pop(value);
                            }
                          },
                        ),
                        onTap: () {
                          Navigator.of(context).pop(gender);
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (selectedGender != null) {
      setState(() {
        _selectedGender = selectedGender;
      });
    }
  }

  Future<void> _showFromWherePicker(BuildContext context) async {
    // Close keyboard first
    FocusScope.of(context).unfocus();

    final selectedFromWhere = await showModalBottomSheet<FromWhere>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 4,
                width: 40,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      title: LocaleKeys.forms_from_where.tr(),
                      textType: TextType.subtitle,
                    ),
                    const SizedBox(height: 16),
                    ...FromWhere.values.map(
                      (fromWhere) => ListTile(
                        title: Text(fromWhere.title.tr()),
                        leading: Radio<FromWhere>(
                          value: fromWhere,
                          groupValue: _selectedFromWhere,
                          onChanged: (value) {
                            if (value != null) {
                              Navigator.of(context).pop(value);
                            }
                          },
                        ),
                        onTap: () {
                          Navigator.of(context).pop(fromWhere);
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (selectedFromWhere != null) {
      setState(() {
        _selectedFromWhere = selectedFromWhere;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _createPatientCubit,
      child: BlocConsumer<CreatePatientCubit, CreatePatientState>(
        listener: (context, state) {
          if (state is CreatePatientSuccess) {
            context.read<PatientBloc>().add(
              GetPatients(page: 1, isRefresh: true),
            );
            router.maybePop<PatientModel>(state.patientModel);
          }
        },
        builder: (context, state) {
          return Material(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          title: LocaleKeys.patients_add_patient.tr(),
                          textType: TextType.body,
                        ),
                        const SizedBox(height: 16),
                        _buildRequiredFields(),
                        const SizedBox(height: 16),
                        if (!_showAdditionalFields)
                          Center(
                            child: TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  _showAdditionalFields = true;
                                });
                              },
                              icon: const Icon(Icons.add),
                              label: Text(LocaleKeys.buttons_show_more.tr()),
                            ),
                          )
                        else
                          _buildAdditionalFields(),
                        const SizedBox(height: 16),
                        if (state is CreatePatientLoading)
                          const LoadingWidget()
                        else
                          SizedBox(
                            width: double.infinity,
                            child: DefElevatedButton(
                              title: LocaleKeys.buttons_save.tr(),
                              onPressed: () {
                                if (_validate()) {
                                  _onSave();
                                }
                              },
                            ),
                          ),
                        SizedBox(height: MediaQuery.of(context).padding.bottom),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _onSave() {
    if (widget.isEdit) {
      context.read<PatientBloc>().add(
        UpdatePatient(
          id: widget.patient!.id!,
          patient: PatientCreateModel(
            firstName: _nameController.text,
            lastName: _surnameController.text,
            patronymic: _patronymicController.text,
            phoneNumber: _phoneController.text,
            phoneNumber2: _secondaryPhoneController.text,
            email: _emailController.text,
            birthDate: _birthday,
            gender: _selectedGender.name.toUpperCase(),
            passportNumber: _passportNumberController.text,
            fromWhere: _selectedFromWhere.name.toUpperCase(),
          ),
        ),
      );
      router.maybePop();
    } else {
      _createPatientCubit.createPatient(
        PatientCreateModel(
          firstName: _nameController.text,
          lastName: _surnameController.text,
          patronymic: _patronymicController.text,
          phoneNumber: _phoneController.text,
          phoneNumber2: _secondaryPhoneController.text,
          email: _emailController.text,
          birthDate: _birthday,
          gender: _selectedGender.name.toUpperCase(),
          passportNumber: _passportNumberController.text,
          fromWhere: _selectedFromWhere.name.toUpperCase(),
        ),
      );
    }
  }
}

enum FromWhere {
  instagram(LocaleKeys.forms_instagram),
  tv(LocaleKeys.forms_tv),
  radio(LocaleKeys.forms_radio),
  stock(LocaleKeys.forms_stock),
  mail(LocaleKeys.forms_mail),
  whatsapp(LocaleKeys.forms_whatsapp),
  twoGis(LocaleKeys.forms_twoGis),
  advised(LocaleKeys.forms_advised),
  relatives(LocaleKeys.forms_relatives),
  other(LocaleKeys.forms_another);

  const FromWhere(this.title);

  final String title;
}

class BirthdayPickerField extends StatefulWidget {
  final String? initialValue;
  final ValueChanged<String>? onChanged;

  const BirthdayPickerField({super.key, this.initialValue, this.onChanged});

  @override
  State<BirthdayPickerField> createState() => _BirthdayPickerFieldState();
}

class _BirthdayPickerFieldState extends State<BirthdayPickerField> {
  String? _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => _showDatePicker(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.5),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            AppText(
              title: LocaleKeys.forms_birthday.tr(),
              textType: TextType.subtitle,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 4),
            AppText(
              title: _formatBirthday(_selectedDate),
              textType: TextType.body,
            ),
          ],
        ),
      ),
    );
  }

  String _formatBirthday(String? date) {
    if (date == null || date.isEmpty) {
      return LocaleKeys.forms_select_date.tr();
    }
    try {
      final DateTime parsedDate = DateTime.parse(date);
      return DateFormat('dd.MM.yyyy').format(parsedDate);
    } catch (e) {
      return LocaleKeys.forms_select_date.tr();
    }
  }

  Future<void> _showDatePicker(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate != null
          ? DateTime.parse(_selectedDate!)
          : DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: context.locale,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final newDate = picked.toIso8601String().split('T')[0];
      setState(() {
        _selectedDate = newDate;
      });
      widget.onChanged?.call(newDate);
    }
  }
}
