import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/main.dart';
import 'package:dent_app_mobile/models/patient/patient_create_model.dart';
import 'package:dent_app_mobile/models/patient/patient_data_model.dart';
import 'package:dent_app_mobile/presentation/pages/patient/core/bloc/create_patient/create_patient_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/patient/core/bloc/patient_bloc/patient_bloc.dart';
import 'package:dent_app_mobile/presentation/widgets/buttons/def_elevated_button.dart';
import 'package:dent_app_mobile/presentation/widgets/input/form_text_field.dart';
import 'package:dent_app_mobile/presentation/widgets/text/app_text.dart';
import 'package:dent_app_mobile/router/app_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreatePatientPage extends StatefulWidget {
  const CreatePatientPage({super.key, this.isEdit = false, this.patient});
  final bool isEdit;
  final PatientModel? patient;
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
  @override
  void initState() {
    super.initState();
    _createPatientCubit = CreatePatientCubit();
    if (widget.isEdit) {
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
    }
  }

  Gender _selectedGender = Gender.male;
  FromWhere _selectedFromWhere = FromWhere.other;
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

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final router = getIt<AppRouter>();

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _createPatientCubit,
      child: BlocListener<CreatePatientCubit, CreatePatientState>(
        listener: (context, state) {
          if (state is CreatePatientSuccess) {
            context.read<PatientBloc>().add(
              GetPatients(page: 1, isRefresh: true),
            );
            router.maybePop();
          }
        },
        child: Material(
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
                    spacing: 12,
                    children: [
                      AppText(
                        title: LocaleKeys.patients_add_patient.tr(),
                        textType: TextType.body,
                      ),
                      FormTextField(
                        hintText: LocaleKeys.forms_name.tr(),
                        controller: _nameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return LocaleKeys.errors_required_field.tr();
                          }
                          return null;
                        },

                        keyboardType: TextInputType.name,
                        textInputAction: TextInputAction.next,
                      ),
                      FormTextField(
                        hintText: LocaleKeys.forms_surname.tr(),
                        controller: _surnameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return LocaleKeys.errors_required_field.tr();
                          }
                          return null;
                        },
                        keyboardType: TextInputType.name,
                        textInputAction: TextInputAction.next,
                      ),
                      FormTextField(
                        hintText: LocaleKeys.forms_patronymic.tr(),
                        controller: _patronymicController,
                        keyboardType: TextInputType.name,
                        textInputAction: TextInputAction.next,
                      ),
                      FormTextField(
                        hintText: LocaleKeys.forms_phone.tr(),
                        controller: _phoneController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return LocaleKeys.errors_required_field.tr();
                          }
                          return null;
                        },
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                      ),
                      FormTextField(
                        hintText: LocaleKeys.forms_secondary_phone_number.tr(),
                        controller: _secondaryPhoneController,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
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
                      DropdownButtonFormField<Gender>(
                        items:
                            Gender.values
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e.title.tr()),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            _selectedGender = value;
                          }
                        },
                        decoration: InputDecoration(
                          labelText: LocaleKeys.forms_gender.tr(),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        value: _selectedGender,
                      ),
                      DropdownButtonFormField<FromWhere>(
                        items:
                            FromWhere.values
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e.title.tr()),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            _selectedFromWhere = value;
                          }
                        },
                        decoration: InputDecoration(
                          labelText: LocaleKeys.forms_from_where.tr(),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        value: _selectedFromWhere,
                      ),
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
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
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

enum Gender {
  male(LocaleKeys.forms_male_m),
  female(LocaleKeys.forms_female_f);

  const Gender(this.title);

  final String title;
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
          border: Border.all(color: theme.colorScheme.outline.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            AppText(
              title: LocaleKeys.forms_birthday.tr(),
              textType: TextType.subtitle,
              color: theme.colorScheme.onSurface.withOpacity(0.7),
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
      initialDate:
          _selectedDate != null
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
