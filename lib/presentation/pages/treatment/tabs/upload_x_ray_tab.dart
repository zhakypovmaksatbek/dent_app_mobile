import 'package:dent_app_mobile/core/bloc/upload/upload_image_cubit.dart';
import 'package:dent_app_mobile/core/utils/image_type.dart';
import 'package:dent_app_mobile/generated/locale_keys.g.dart';
import 'package:dent_app_mobile/models/appointment/calendar_appointment_model.dart';
import 'package:dent_app_mobile/models/work/upload_patient_rontgen_model.dart';
import 'package:dent_app_mobile/presentation/pages/treatment/core/bloc/upload_x_ray/upload_x_ray_cubit.dart';
import 'package:dent_app_mobile/presentation/theme/colors/color_constants.dart';
import 'package:dent_app_mobile/presentation/widgets/image/cashed_images.dart';
import 'package:dent_app_mobile/presentation/widgets/snack_bars/app_snack_bar.dart';
import 'package:dent_app_mobile/presentation/widgets/text/app_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';

class UploadXRayTab extends StatefulWidget {
  const UploadXRayTab({super.key, required this.calendarAppointment});
  final CalendarAppointmentModel calendarAppointment;
  @override
  State<UploadXRayTab> createState() => _UploadXRayTabState();
}

class _UploadXRayTabState extends State<UploadXRayTab>
    with AutomaticKeepAliveClientMixin {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _teethController = TextEditingController();
  final FocusNode _teethFocusNode = FocusNode();

  String? _uploadedImage;
  String? _imageId; // Track image ID for professional deletion
  bool _isSavedToAppointment = false; // Track if X-ray is saved to appointment

  @override
  void dispose() {
    _descriptionController.dispose();
    _teethController.dispose();
    _teethFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return MultiBlocListener(
      listeners: [
        BlocListener<UploadImageCubit, UploadImageState>(
          listener: (context, state) {
            if (state is UploadImageSuccess) {
              if (state.image.link != null) {
                setState(() {
                  _uploadedImage = state.image.link!;
                  _imageId = state.image.imageId?.toString(); // Store image ID
                  _isSavedToAppointment = false; // Reset save status
                });
                // Clear text fields for new image
                _descriptionController.clear();
                _teethController.clear();
                AppSnackBar.showSuccessSnackBar(
                  context,
                  LocaleKeys.alerts_operation_successful.tr(),
                );
              }
            } else if (state is UploadImageDeleted) {
              setState(() {
                _uploadedImage = null;
                _imageId = null;
                _isSavedToAppointment = false;
              });
              // Clear text fields when image is deleted
              _descriptionController.clear();
              _teethController.clear();
              AppSnackBar.showSuccessSnackBar(
                context,
                "Рентген успешно удален",
              );
            } else if (state is UploadImageError) {
              AppSnackBar.showErrorSnackBar(context, state.message);
            }
          },
        ),
        BlocListener<UploadXRayCubit, UploadXRayState>(
          listener: (context, state) {
            if (state is UploadXRaySuccess) {
              setState(() {
                _isSavedToAppointment = true;
              });
              AppSnackBar.showSuccessSnackBar(
                context,
                "Рентген успешно сохранен в запись",
              );
            } else if (state is UploadXRayError) {
              AppSnackBar.showErrorSnackBar(context, state.message);
            }
          },
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Simple header
              AppText(title: "Загрузить рентген", textType: TextType.title),
              const SizedBox(height: 16),

              // Upload area or uploaded image
              _uploadedImage != null
                  ? _buildUploadedImage()
                  : _buildUploadArea(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUploadArea() {
    return BlocBuilder<UploadImageCubit, UploadImageState>(
      builder: (context, state) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!, width: 2),
          ),
          child: Column(
            children: [
              if (state is UploadImageLoading)
                const CircularProgressIndicator()
              else ...[
                Icon(
                  Icons.cloud_upload_outlined,
                  size: 48,
                  color: Colors.grey[600],
                ),
                const SizedBox(height: 12),
                AppText(
                  title: "Загрузите рентгеновский снимок",
                  textType: TextType.body,
                ),
                const SizedBox(height: 8),
                AppText(
                  title: "Поддерживаются форматы JPG, PNG",
                  textType: TextType.subtitle,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _pickImage(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt, size: 18),
                        label: const Text("Камера"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorConstants.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _pickImage(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library, size: 18),
                        label: const Text("Галерея"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: ColorConstants.primary,
                          side: BorderSide(color: ColorConstants.primary),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildUploadedImage() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: SizedBox(
              height: 200,
              width: double.infinity,
              child: CashedImages(imageUrl: _uploadedImage!, fit: BoxFit.cover),
            ),
          ),

          // Status and Actions
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(12),
              ),
            ),
            child: Column(
              children: [
                // Upload Status
                Row(
                  children: [
                    Icon(
                      _isSavedToAppointment
                          ? Icons.check_circle
                          : Icons.cloud_upload,
                      color: _isSavedToAppointment ? Colors.green : Colors.blue,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AppText(
                        title:
                            _isSavedToAppointment
                                ? "Рентген сохранен в запись"
                                : "Рентген загружен",
                        textType: TextType.body,
                      ),
                    ),
                  ],
                ),

                // Input Fields for Description and Teeth
                if (!_isSavedToAppointment && _imageId != null) ...[
                  const SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Description Field
                      AppText(title: "Описание", textType: TextType.body),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _descriptionController,
                        onTapOutside: (event) {
                          FocusScope.of(context).unfocus();
                        },
                        decoration: InputDecoration(
                          hintText: "Введите описание рентгена",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: ColorConstants.primary,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),

                      // Teeth Field (Required)
                      Row(
                        children: [
                          AppText(title: "Номер зуба", textType: TextType.body),
                          AppText(
                            title: " *",
                            textType: TextType.body,
                            color: Colors.red,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _teethController,
                        focusNode: _teethFocusNode,
                        onTapOutside: (event) {
                          FocusScope.of(context).unfocus();
                        },
                        decoration: InputDecoration(
                          hintText: "Введите номер зуба (например: 21)",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: ColorConstants.primary,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.red),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.red),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        keyboardType: TextInputType.text,
                      ),
                    ],
                  ),
                ],

                // Save to Appointment Button
                if (!_isSavedToAppointment && _imageId != null) ...[
                  const SizedBox(height: 12),
                  BlocBuilder<UploadXRayCubit, UploadXRayState>(
                    builder: (context, state) {
                      final isLoading = state is UploadXRayLoading;
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: isLoading ? null : _saveToAppointment,
                          icon:
                              isLoading
                                  ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                  : const Icon(Icons.save, size: 18),
                          label: Text(
                            isLoading ? "Сохранение..." : "Сохранить в запись",
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorConstants.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],

                // Action Buttons
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showImagePreview(_uploadedImage!),
                        icon: const Icon(Icons.visibility, size: 18),
                        label: const Text("Просмотр"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: ColorConstants.primary,
                          side: BorderSide(color: ColorConstants.primary),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _showChangeDialog,
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text("Изменить"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.orange,
                          side: const BorderSide(color: Colors.orange),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _removeImage,
                        icon: const Icon(Icons.delete, size: 18),
                        label: const Text("Удалить"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                  ],
                ),

                // Add Another Image Button (show after saving to appointment)
                if (_isSavedToAppointment) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _uploadAnotherImage,
                      icon: const Icon(Icons.add_photo_alternate, size: 18),
                      label: const Text("Загрузить еще один рентген"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showChangeDialog() {
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

              AppText(title: "Изменить изображение", textType: TextType.title),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          _isSavedToAppointment = false;
                        });
                        _descriptionController.clear();
                        _teethController.clear();
                        _pickImage(ImageSource.camera);
                      },
                      icon: const Icon(Icons.camera_alt),
                      label: const Text("Камера"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorConstants.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          _isSavedToAppointment = false;
                        });
                        _descriptionController.clear();
                        _teethController.clear();
                        _pickImage(ImageSource.gallery);
                      },
                      icon: const Icon(Icons.photo_library),
                      label: const Text("Галерея"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: ColorConstants.primary,
                        side: BorderSide(color: ColorConstants.primary),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        if (!mounted) return;
        context.read<UploadImageCubit>().uploadImage(
          pickedFile,
          ImageType.snapshots,
        );
      }
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.showErrorSnackBar(
        context,
        LocaleKeys.errors_something_went_wrong.tr(),
      );
    }
  }

  void _removeImage() {
    if (_imageId != null) {
      // Professional deletion via API when image ID is available
      context.read<UploadImageCubit>().deleteImage(_imageId!);
    } else {
      // Fallback to simple state removal for local-only changes
      setState(() {
        _uploadedImage = null;
        _imageId = null;
        _isSavedToAppointment = false;
      });
    }
  }

  void _saveToAppointment() {
    if (_imageId == null ||
        widget.calendarAppointment.appointmentId == null ||
        widget.calendarAppointment.patientId == null) {
      AppSnackBar.showErrorSnackBar(context, "Недостаточно данных");
      return;
    }

    final description = _descriptionController.text.trim();
    final teeth = _teethController.text.trim();

    // Validate required teeth field
    if (teeth.isEmpty) {
      AppSnackBar.showErrorSnackBar(
        context,
        "Номер зуба обязателен для заполнения",
      );
      // Focus on teeth field to highlight the error
      _teethFocusNode.requestFocus();
      return;
    }

    final uploadXRayModel = UploadXRayModel(
      patientId: widget.calendarAppointment.patientId!,
      appointmentId: widget.calendarAppointment.appointmentId!,
      imageId: int.tryParse(_imageId!),
      description: description.isEmpty ? null : description,
      teeth: teeth,
    );

    context.read<UploadXRayCubit>().uploadXRay(uploadXRayModel);
  }

  void _uploadAnotherImage() {
    // Reset current image state to allow uploading another image
    setState(() {
      _uploadedImage = null;
      _imageId = null;
      _isSavedToAppointment = false;
    });

    // Clear text fields
    _descriptionController.clear();
    _teethController.clear();

    // Show upload options dialog
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

              AppText(
                title: "Загрузить новый рентген",
                textType: TextType.title,
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.camera);
                      },
                      icon: const Icon(Icons.camera_alt),
                      label: const Text("Камера"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorConstants.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.gallery);
                      },
                      icon: const Icon(Icons.photo_library),
                      label: const Text("Галерея"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: ColorConstants.primary,
                        side: BorderSide(color: ColorConstants.primary),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _showImagePreview(String imageUrl) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog.fullscreen(
          backgroundColor: Colors.black,
          child: Stack(
            children: [
              // Photo View with zoom and pan
              PhotoView(
                imageProvider: NetworkImage(imageUrl),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 3.0,
                initialScale: PhotoViewComputedScale.contained,
                heroAttributes: PhotoViewHeroAttributes(tag: imageUrl),
                backgroundDecoration: const BoxDecoration(color: Colors.black),
                loadingBuilder:
                    (context, event) => const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                errorBuilder:
                    (context, error, stackTrace) => const Center(
                      child: Icon(Icons.error, color: Colors.white, size: 50),
                    ),
              ),

              // Close button
              Positioned(
                top: 60,
                right: 20,
                child: SafeArea(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),

              // Info overlay (optional)
              Positioned(
                bottom: 60,
                left: 20,
                right: 20,
                child: SafeArea(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppText(
                          title: "Рентгеновский снимок",
                          textType: TextType.body,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 8),
                        AppText(
                          title:
                              "Щипните для увеличения • Перетащите для перемещения",
                          textType: TextType.subtitle,
                          color: Colors.white70,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
