import 'package:auto_route/auto_route.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:dent_app_mobile/core/bloc/upload/upload_image_cubit.dart';
import 'package:dent_app_mobile/core/utils/image_type.dart';
import 'package:dent_app_mobile/core/utils/salary_type.dart';
import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/main.dart';
import 'package:dent_app_mobile/models/users/personal_model.dart';
import 'package:dent_app_mobile/models/users/user_model.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/personal/core/bloc/personal/personal_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/personal/core/bloc/personal_action/personal_action_cubit.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/personal/core/util/gender.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/personal/core/util/roles.dart';
import 'package:dent_app_mobile/presentation/pages/settings/views/personal/core/util/text_extension.dart';
import 'package:dent_app_mobile/presentation/widgets/image/cashed_images.dart';
import 'package:dent_app_mobile/presentation/widgets/input/custom_phone_input.dart';
import 'package:dent_app_mobile/router/app_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

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
  late final UploadImageCubit uploadImageCubit;
  final ImagePicker _imagePicker = ImagePicker();

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

  // Phone number state
  String? _initialPhoneNumber;
  String? _initialPhoneNumber2;

  // Image upload state
  String? _uploadedImageUrl;
  int? _uploadedImageId;
  bool _isImageUploaded = false;

  // Determine if we're in edit mode
  bool get isEditMode => widget.user != null;

  @override
  void initState() {
    super.initState();
    cubit = PersonalActionCubit();
    uploadImageCubit = UploadImageCubit();
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
    _initialPhoneNumber = _getLocalPhoneNumber(user.phoneNumber);
    print('Initial phone number set to: $_initialPhoneNumber');
    _phone2Controller.text = user.phoneNumber2 ?? '';
    _initialPhoneNumber2 = _getLocalPhoneNumber(user.phoneNumber2);
    print('Initial phone number set to: $_initialPhoneNumber2');
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

  // Parse phone number to extract local number without country code
  String? _getLocalPhoneNumber(String? phoneNumber) {
    if (phoneNumber == null || phoneNumber.isEmpty) return null;

    // Remove all non-digit characters
    String digitsOnly = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    print('Original phone: $phoneNumber, Digits only: $digitsOnly');

    // If phone starts with +996 or 996 (Kyrgyzstan), remove country code
    if (digitsOnly.startsWith('996') && digitsOnly.length > 9) {
      String localNumber = digitsOnly.substring(3);
      print('Kyrgyzstan number detected, local: $localNumber');
      return localNumber;
    }

    // If phone starts with other country codes, try to detect and remove them
    // This is a simplified approach - you may need to add more country codes
    if (digitsOnly.length > 10) {
      // Assume it has a country code and take the last 9 digits for local number
      String localNumber = digitsOnly.substring(digitsOnly.length - 9);
      print('Long number detected, assuming local: $localNumber');
      return localNumber;
    }

    print('Returning original digits: $digitsOnly');
    return digitsOnly;
  }

  // Image upload methods
  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        uploadImageCubit.uploadImage(pickedFile, ImageType.avatar);
      }
    } catch (e) {
      CherryToast.error(
        title: Text(LocaleKeys.errors_something_went_wrong.tr()),
      ).show(context);
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        uploadImageCubit.uploadImage(pickedFile, ImageType.avatar);
      }
    } catch (e) {
      CherryToast.error(
        title: Text(LocaleKeys.errors_something_went_wrong.tr()),
      ).show(context);
    }
  }

  void _removeImage() {
    if (_uploadedImageId != null) {
      uploadImageCubit.deleteImage(_uploadedImageId.toString());
    }
    setState(() {
      _uploadedImageUrl = null;
      _uploadedImageId = null;
      _isImageUploaded = false;
    });
  }

  void _showImagePickerDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Фото профиля',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Выбрать из галереи'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Сделать фото'),
                onTap: () {
                  Navigator.pop(context);
                  _takePhoto();
                },
              ),
              if (_uploadedImageUrl != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text(
                    'Удалить фото',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _removeImage();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  // Build image section widget
  Widget _buildImageSection() {
    if (!isEditMode) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Фото профиля'),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Image preview
              if (_uploadedImageUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    height: 150,
                    width: 150,
                    child: CashedImages(
                      imageUrl: _uploadedImageUrl!,
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              else
                Container(
                  height: 150,
                  width: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.person, size: 60, color: Colors.grey[600]),
                ),
              const SizedBox(height: 16),
              // Upload button
              ElevatedButton.icon(
                onPressed: _showImagePickerDialog,
                icon: Icon(
                  _uploadedImageUrl != null ? Icons.edit : Icons.add_a_photo,
                ),
                label: Text(
                  _uploadedImageUrl != null
                      ? 'Изменить фото'
                      : 'Загрузить фото',
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
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
    uploadImageCubit.close();
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
      // In edit mode, call update with the user's ID and imageId if uploaded
      cubit.updatePerson(widget.user!.id!, model, imageId: _uploadedImageId);
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
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: cubit),
        BlocProvider.value(value: uploadImageCubit),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            isEditMode
                ? LocaleKeys.buttons_edit.tr()
                : LocaleKeys.buttons_create_personal.tr(),
          ),
        ),
        body: MultiBlocListener(
          listeners: [
            BlocListener<PersonalActionCubit, PersonalActionState>(
              listener: (context, state) {
                if (state is PersonalActionSuccess) {
                  // On success, show success message and navigate back
                  context.read<PersonalCubit>().getPersonalList(
                    1,
                    isRefresh: true,
                  );
                  router.back();
                } else if (state is PersonalActionError) {
                  // On error, show error message
                  CherryToast.error(title: Text(state.message)).show(context);
                }
              },
            ),
            BlocListener<UploadImageCubit, UploadImageState>(
              listener: (context, state) {
                if (state is UploadImageSuccess) {
                  setState(() {
                    _uploadedImageUrl = state.image.link;
                    _uploadedImageId = state.image.imageId;
                    _isImageUploaded = true;
                  });
                  CherryToast.success(
                    title: Text('Фото успешно загружено'),
                  ).show(context);
                } else if (state is UploadImageError) {
                  CherryToast.error(title: Text(state.message)).show(context);
                } else if (state is UploadImageDeleted) {
                  setState(() {
                    _uploadedImageUrl = null;
                    _uploadedImageId = null;
                    _isImageUploaded = false;
                  });
                  CherryToast.success(
                    title: Text('Фото успешно удалено'),
                  ).show(context);
                }
              },
            ),
          ],
          child: BlocBuilder<PersonalActionCubit, PersonalActionState>(
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
                            // Image upload section - only in edit mode
                            _buildImageSection(),

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
                                  return LocaleKeys.forms_email_is_required
                                      .tr();
                                }
                                final emailRegExp = RegExp(
                                  r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                                );
                                if (!emailRegExp.hasMatch(value)) {
                                  return LocaleKeys.forms_enter_valid_email
                                      .tr();
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),

                            // Phone field
                            CustomPhoneInput(
                              focusNode: FocusNode(),
                              initialValue: _initialPhoneNumber,
                              onChanged: (value) {
                                _phoneController.text = value;
                              },
                              decoration: InputDecoration(
                                labelText: LocaleKeys.forms_phone.tr(),
                                border: const OutlineInputBorder(),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                            ),

                            // Phone visibility toggle
                            Row(
                              children: [
                                Checkbox(
                                  value: _isPhoneVisible,
                                  visualDensity: VisualDensity.compact,
                                  onChanged: (value) {
                                    setState(() {
                                      _isPhoneVisible = value ?? true;
                                    });
                                  },
                                ),
                                Text(
                                  LocaleKeys.forms_make_phone_number_visible
                                      .tr(),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Phone2 field (optional)
                            CustomPhoneInput(
                              focusNode: FocusNode(),
                              initialValue: _initialPhoneNumber2,
                              onChanged: (value) {
                                _phone2Controller.text = value;
                              },
                              decoration: InputDecoration(
                                labelText: LocaleKeys.forms_phone.tr(),
                                border: const OutlineInputBorder(),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
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
                                  return LocaleKeys.forms_salary_is_required
                                      .tr();
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
                                  child: Text(
                                    SalaryType.fixed.displayName.tr(),
                                  ),
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
                                if ((value == null || value.isEmpty)) {
                                  return LocaleKeys
                                      .forms_password_is_required_for_new_users
                                      .tr();
                                }
                                if (value.isNotEmpty && value.length < 6) {
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
      ),
    );
  }
}
