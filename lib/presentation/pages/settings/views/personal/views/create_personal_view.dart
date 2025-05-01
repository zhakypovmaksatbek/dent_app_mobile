import 'package:auto_route/auto_route.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/main.dart';
import 'package:dent_app_mobile/models/users/personal_model.dart';
import 'package:dent_app_mobile/models/users/user_model.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/personal/core/bloc/personal/personal_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/personal/core/bloc/personal_action/personal_action_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/personal/core/util/gender.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/personal/core/util/roles.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/personal/core/util/text_extension.dart';
import 'package:dent_app_mobile/router/app_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage(name: 'CreatePersonalRoute')
class CreatePersonalView extends StatefulWidget {
  // For editing, we need user ID rather than the full model
  final UserModel? user;

  const CreatePersonalView({super.key, this.user});

  @override
  State<CreatePersonalView> createState() => _CreatePersonalViewState();
}

class _CreatePersonalViewState extends State<CreatePersonalView> {
  // Form key for validation
  final _formKey = GlobalKey<FormState>();
  late final PersonalActionCubit cubit;

  // Text editing controllers for form fields
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _patronymicController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _phone2Controller = TextEditingController();
  final _salaryController = TextEditingController();
  final _passwordController = TextEditingController();

  // Dropdown values
  Gender _selectedGender = Gender.male; // Default value
  Role _selectedRole = Role.doctor; // Default value
  SalaryType _selectedSalaryType = SalaryType.fixed; // Default value
  bool _isPhoneVisible = true; // Default value

  // Determine if we're in edit mode
  bool get isEditMode => widget.user != null;

  @override
  void initState() {
    super.initState();
    cubit = PersonalActionCubit();
    // If we're in edit mode, populate the form with user data
    if (isEditMode) {
      _populateFormWithUserData();
    }
  }

  void _populateFormWithUserData() {
    final user = widget.user!;

    // Split the fullName if available
    if (user.fullName != null) {
      final nameParts = user.fullName!.split(' ');
      if (nameParts.isNotEmpty) {
        _firstNameController.text = nameParts.first;
        if (nameParts.length > 1) {
          _lastNameController.text = nameParts.last;
        }
        if (nameParts.length > 2) {
          _patronymicController.text = nameParts[1];
        }
      }
    }

    _emailController.text = user.email ?? '';
    _phoneController.text = user.phoneNumber ?? '';

    if (user.salary != null) {
      _salaryController.text = user.salary!.toIntString();
    }

    if (user.percentOrFixed != null) {
      _selectedSalaryType =
          user.percentOrFixed == 'PERCENT'
              ? SalaryType.percent
              : SalaryType.fixed;
    }

    if (user.isVisibilityPhoneNumber != null) {
      _isPhoneVisible = user.isVisibilityPhoneNumber!;
    }
  }

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
    _firstNameController.dispose();
    _lastNameController.dispose();
    _patronymicController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _phone2Controller.dispose();
    _salaryController.dispose();
    _passwordController.dispose();
    cubit.close();
    super.dispose();
  }

  // Build the form model from form values
  PersonalModel _buildPersonalModel() {
    final model = PersonalModel(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      patronymic: _patronymicController.text.trim(),
      email: _emailController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      phoneNumber2:
          _phone2Controller.text.isEmpty ? null : _phone2Controller.text.trim(),
      gender: _selectedGender.name.toUpperCase(),
      role: _selectedRole.name.toUpperCase(),
      isVisibilityPhoneNumber: _isPhoneVisible,
      payrollCalculationsRequest: PayrollCalculationsRequest(
        salary:
            _salaryController.text.isEmpty
                ? null
                : double.parse(_salaryController.text),
        percentOrFixed: _selectedSalaryType,
      ),
    );

    // Only set password if it's not empty and we're not in edit mode
    // or if we're in edit mode and a new password was entered
    if (_passwordController.text.isNotEmpty) {
      model.password = _passwordController.text;
    }

    return model;
  }

  void _savePersonal() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final model = _buildPersonalModel();

    if (isEditMode) {
      // In edit mode, call update with the user's ID
      cubit.updatePerson(widget.user!.id!, model);
    } else {
      // In create mode, call create
      cubit.createPerson(model);
    }
  }

  // Helper method to create a consistent text input field
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool isRequired = false,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator:
          validator ??
          (isRequired
              ? (value) {
                if (value == null || value.isEmpty) {
                  return '$label is required';
                }
                return null;
              }
              : null),
    );
  }

  // Helper method to create a consistent dropdown
  Widget _buildDropdown<T>({
    required T value,
    required String label,
    required List<DropdownMenuItem<T>> items,
    required Function(T?) onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      items: items,

      onChanged: onChanged,
    );
  }

  // Helper method to create consistent section headers
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 16),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  final router = getIt<AppRouter>();
  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: cubit,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            isEditMode
                ? LocaleKeys.buttons_edit.tr()
                : LocaleKeys.buttons_create_personal.tr(),
          ),
        ),
        body: BlocConsumer<PersonalActionCubit, PersonalActionState>(
          listener: (context, state) {
            if (state is PersonalActionSuccess) {
              // On success, show success message and navigate back
              context.read<PersonalCubit>().getPersonalList(1, isRefresh: true);
              router.back();
            } else if (state is PersonalActionError) {
              // On error, show error message
              CherryToast.error(title: Text(state.message)).show(context);
            }
          },
          builder: (context, state) {
            // Show loading indicator during operations
            final isLoading = state is PersonalActionLoading;

            return Stack(
              children: [
                // Main form content with padding
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Personal Information section
                          _buildSectionHeader(
                            LocaleKeys.forms_personal_info.tr(),
                          ),

                          // First Name field
                          _buildTextField(
                            controller: _firstNameController,
                            label: LocaleKeys.forms_name.tr(),
                            isRequired: true,
                          ),
                          const SizedBox(height: 12),

                          // Last Name field
                          _buildTextField(
                            controller: _lastNameController,
                            label: LocaleKeys.forms_surname.tr(),
                            isRequired: true,
                          ),
                          const SizedBox(height: 12),

                          // Patronymic field (optional)
                          _buildTextField(
                            controller: _patronymicController,
                            label: LocaleKeys.forms_patronymic.tr(),
                          ),
                          const SizedBox(height: 12),

                          // Gender dropdown
                          _buildDropdown<Gender>(
                            value: _selectedGender,
                            label: LocaleKeys.general_gender.tr(),
                            items:
                                Gender.values
                                    .map(
                                      (e) => DropdownMenuItem(
                                        value: e,
                                        child: Text(e.displayName.tr()),
                                      ),
                                    )
                                    .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _selectedGender = value;
                                });
                              }
                            },
                          ),

                          // Contact Information section
                          _buildSectionHeader(
                            LocaleKeys.forms_contact_info.tr(),
                          ),

                          // Email field
                          _buildTextField(
                            controller: _emailController,
                            label: LocaleKeys.forms_email.tr(),
                            keyboardType: TextInputType.emailAddress,
                            isRequired: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return LocaleKeys.forms_email_is_required.tr();
                              }
                              final emailRegExp = RegExp(
                                r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                              );
                              if (!emailRegExp.hasMatch(value)) {
                                return LocaleKeys.forms_enter_valid_email.tr();
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),

                          // Phone field
                          _buildTextField(
                            controller: _phoneController,
                            label: LocaleKeys.forms_phone.tr(),
                            keyboardType: TextInputType.phone,
                            isRequired: true,
                          ),
                          const SizedBox(height: 4),

                          // Phone visibility toggle
                          Row(
                            children: [
                              Checkbox(
                                value: _isPhoneVisible,
                                onChanged: (value) {
                                  setState(() {
                                    _isPhoneVisible = value ?? true;
                                  });
                                },
                              ),
                              Text(
                                LocaleKeys.forms_make_phone_number_visible.tr(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Phone2 field (optional)
                          _buildTextField(
                            controller: _phone2Controller,
                            label: LocaleKeys.forms_alternative_phone.tr(),
                            keyboardType: TextInputType.phone,
                          ),

                          // Role & Salary section
                          _buildSectionHeader(
                            LocaleKeys.forms_role_salary.tr(),
                          ),

                          // Role dropdown
                          _buildDropdown<Role>(
                            value: _selectedRole,
                            label: LocaleKeys.forms_role.tr(),
                            items:
                                Role.values
                                    .map(
                                      (e) => DropdownMenuItem(
                                        value: e,
                                        child: Text(e.displayName.tr()),
                                      ),
                                    )
                                    .toList(),

                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _selectedRole = value;
                                });
                              }
                            },
                          ),
                          const SizedBox(height: 12),

                          // Salary field
                          _buildTextField(
                            controller: _salaryController,
                            label: LocaleKeys.forms_salary.tr(),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return LocaleKeys.forms_salary_is_required.tr();
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),

                          // Salary type dropdown
                          _buildDropdown<SalaryType>(
                            value: _selectedSalaryType,
                            label: LocaleKeys.forms_salary_type.tr(),
                            items: [
                              DropdownMenuItem(
                                value: SalaryType.fixed,
                                child: Text(SalaryType.fixed.displayName.tr()),
                              ),
                              DropdownMenuItem(
                                value: SalaryType.percent,
                                child: Text(
                                  SalaryType.percent.displayName.tr(),
                                ),
                              ),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _selectedSalaryType = value;
                                });
                              }
                            },
                          ),

                          // Password section - conditional based on mode
                          _buildSectionHeader(
                            LocaleKeys.forms_security_info.tr(),
                          ),

                          // Password field
                          _buildTextField(
                            controller: _passwordController,
                            label: LocaleKeys.forms_enter_password.tr(),
                            obscureText: true,
                            validator: (value) {
                              if (!isEditMode &&
                                  (value == null || value.isEmpty)) {
                                return LocaleKeys
                                    .forms_password_is_required_for_new_users
                                    .tr();
                              }
                              if (value != null &&
                                  value.isNotEmpty &&
                                  value.length < 6) {
                                return LocaleKeys
                                    .forms_password_must_be_at_least_6_characters
                                    .tr();
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 32),

                          // Save button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : _savePersonal,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                              child: Text(
                                isEditMode
                                    ? LocaleKeys.buttons_update_personal.tr()
                                    : LocaleKeys.buttons_create_personal.tr(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ),

                // Loading overlay
                if (isLoading)
                  const Positioned.fill(
                    child: ColoredBox(
                      color: Color(0x80000000),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
